import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

/// Global navigator key — shared with GoRouter so interceptors
/// can push routes (e.g. /suspended) without a BuildContext.
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

class ApiConfig {
  // static const String baseUrl = '';
  static const String baseUrl = 'http://192.168.0.222:8000';
  // static const String baseUrl = 'http://192.168.31.107:8000';
  // static const String baseUrl = 'https://appbackenddemo.naiyo24.com';

  /// Debug-only feature flag.
  /// Enable with: flutter run --dart-define=DEMO_OTP_BYPASS=true
  static const bool demoOtpBypass = bool.fromEnvironment(
    'DEMO_OTP_BYPASS',
    defaultValue: false,
  );

  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.add(_FirebaseAuthInterceptor())
        ..interceptors.add(_SuspensionInterceptor())
        ..interceptors.add(
          PrettyDioLogger(
            requestHeader: true,
            requestBody: true,
            responseBody: true,
            responseHeader: false,
            error: true,
            compact: true,
          ),
        );

  /// Returns the shared Dio instance.
  static Dio get dio => _dio;

  /// Returns the WebSocket base URL derived from the HTTP base URL.
  static String get wsBaseUrl {
    return baseUrl
        .replaceFirst('http://', 'ws://')
        .replaceFirst('https://', 'wss://');
  }
}

/// Interceptor that automatically attaches the Firebase ID token
/// as a Bearer token to every request if a user is signed in.
class _FirebaseAuthInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final token = await user.getIdToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
      }
    } catch (_) {
      // Safe catch for concurrent sign-out throws like [firebase_auth/no-current-user]
    }
    handler.next(options);
  }
}

/// Global interceptor that catches 403 responses (account suspension)
/// and navigates the driver to the Suspended Screen automatically.
///
/// To make a request that should NOT trigger the suspension redirect
/// (e.g. the "Check Status" ping from the Suspended Screen itself),
/// add the header `X-Skip-Ban-Redirect: true` to the request.
class _SuspensionInterceptor extends Interceptor {
  static bool _isNavigating = false; // Prevent double-navigation

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final skipRedirect =
        err.requestOptions.headers['X-Skip-Ban-Redirect'] == 'true';

    if (err.response?.statusCode == 403 && !_isNavigating && !skipRedirect) {
      _isNavigating = true;

      // Extract detail message from backend
      String message =
          'Your account has been temporarily suspended due to excessive cancellations.';
      String? banType;
      final data = err.response?.data;
      if (data is Map) {
        message = data['detail']?.toString() ?? message;
        banType = data['ban_type']?.toString();
      }

      final ctx = rootNavigatorKey.currentContext;

      bool hasActiveOrder = false;
      if (ctx != null) {
        try {
          final container = ProviderScope.containerOf(ctx, listen: false);
          hasActiveOrder = container.read(activeDeliveryProvider) != null;
        } catch (e) {
          // ignore if provider scope not available
        }
      }

      // If the driver is currently completing an active order, do not interrupt them
      // with the suspension screen. It will show up after they finish or cancel the order.
      if (!hasActiveOrder) {
        if (ctx != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final params = <String, String>{'message': message};
            if (banType != null) params['banType'] = banType;

            GoRouter.of(
              ctx,
            ).go(Uri(path: '/suspended', queryParameters: params).toString());
            // Reset the guard after a delay so future 403s still trigger
            Future.delayed(const Duration(seconds: 2), () {
              _isNavigating = false;
            });
          });
        } else {
          _isNavigating = false;
        }
      } else {
        _isNavigating = false;
      }
    }

    handler.next(err); // Always forward so local catch blocks still fire
  }
}
