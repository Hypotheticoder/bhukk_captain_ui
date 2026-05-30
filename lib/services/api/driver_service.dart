import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'api_config.dart';

class DriverService {
  static final Dio _dio = ApiConfig.dio;

  /// Check if a driver with the given phone number exists.
  /// GET /drivers/exists?phone_number=`phone`
  /// Returns the response map if exists, null if not.
  static Future<Map<String, dynamic>?> checkDriverExists(String phone) async {
    try {
      final response = await _dio.get(
        '/drivers/exists',
        queryParameters: {'phone_number': phone},
      );
      if (response.statusCode == 200 && response.data != null) {
        final data = Map<String, dynamic>.from(response.data);
        if (data['exists'] == true) {
          return data;
        }
        return null;
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  /// Create a new driver (requires Firebase auth).
  /// POST /drivers/create
  static Future<Map<String, dynamic>> createDriver(
    Map<String, dynamic> data,
  ) async {
    // 1. Tiny delay to allow Firebase auth state to fully propagate
    await Future.delayed(const Duration(milliseconds: 500));

    // 2. Explicitly grab the token so we don't rely only on the interceptor's timing
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception(
        "Firebase user not logged in. Cannot create driver profile.",
      );
    }
    final token = await user.getIdToken(true); // force refresh

    // 3. Attach it to the Headers! The interceptor will fire, but explicitly setting
    // it ensures the bouncer gets the VIP pass if the interceptor cached a premature state.
    final response = await _dio.post(
      '/drivers/create',
      data: data,
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
    return Map<String, dynamic>.from(response.data);
  }

  /// Get driver by ID.
  /// GET /drivers/{driver_id}
  static Future<Map<String, dynamic>> getDriver(String driverId) async {
    final response = await _dio.get('/drivers/$driverId');
    return Map<String, dynamic>.from(response.data);
  }

  /// Get driver by phone number.
  /// Uses the /drivers/exists endpoint and extracts the full driver data,
  /// then re-fetches via /drivers/{id} for the complete profile.
  static Future<Map<String, dynamic>?> getDriverByPhone(String phone) async {
    try {
      // Strip +91 prefix for backend compatibility
      String cleanPhone = phone.replaceAll(RegExp(r'^\+91'), '');

      final existsData = await checkDriverExists(cleanPhone);
      if (existsData == null) {
        // Try with the full international format too
        final existsData2 = await checkDriverExists(phone);
        if (existsData2 == null) return null;
        return existsData2;
      }

      // If exists response includes the driver ID, fetch full profile
      final driverId =
          existsData['id']?.toString() ?? existsData['driver_id']?.toString();
      if (driverId != null && driverId.isNotEmpty) {
        try {
          return await getDriver(driverId);
        } catch (_) {
          // Full fetch failed, return the exists data as-is
        }
      }

      return existsData;
    } catch (_) {
      return null;
    }
  }

  /// Update the firebase_uid on the backend after re-authentication.
  /// PATCH /drivers/{driver_id}
  static Future<void> syncFirebaseUid(String driverId, String newUid, String token) async {
    try {
      // Fire the PATCH request WITH the Authorization header included
      final response = await _dio.patch(
        '/drivers/$driverId',
        data: {
          'firebase_uid': newUid,
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
        ),
      );
      debugPrint("✅ Successfully synced Firebase UID to backend: ${response.data}");
    } on DioException catch (e) {
      debugPrint("❌ Failed to sync UID: ${e.response?.data ?? e.message}");
    }
  }

  /// Update driver by ID (requires Firebase auth).
  /// PATCH /drivers/{driver_id}
  static Future<Map<String, dynamic>> updateDriver(
    String driverId,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch('/drivers/$driverId', data: data);
    return Map<String, dynamic>.from(response.data);
  }

  /// Delete driver by ID (requires Firebase auth).
  /// DELETE /drivers/{driver_id}
  static Future<void> deleteDriver(String driverId) async {
    await _dio.delete('/drivers/$driverId');
  }

  /// Upload a document for a driver (requires Firebase auth).
  /// POST /drivers/{driver_id}/documents?doc_type=xxx
  static Future<Map<String, dynamic>> uploadDocument(
    String driverId,
    String docType,
    String filePath,
  ) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
    });
    final response = await _dio.post(
      '/drivers/$driverId/documents',
      data: formData,
      queryParameters: {'doc_type': docType},
      options: Options(headers: {'Content-Type': 'multipart/form-data'}),
    );
    return Map<String, dynamic>.from(response.data);
  }

  /// Log out a driver on the backend (takes them offline and clears FCM token).
  /// POST /drivers/me/logout
  static Future<void> logoutDriver() async {
    try {
      await _dio.post('/drivers/me/logout');
    } catch (_) {
      // Best-effort backend logout: if server/network fails, we still log out locally.
    }
  }
}
