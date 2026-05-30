import 'package:bhukkdelivery/services/api/auth_service.dart';
import 'package:bhukkdelivery/services/api/driver_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum LoginStep { phone, otp }

class LoginState {
  final LoginStep step;
  final String phoneNumber;
  final List<String> otpDigits;
  final bool isSendingOtp;
  final bool isVerifyingOtp;
  final bool isError;
  final bool isSuccess;
  final String errorMessage;

  // Firebase OTP fields
  final String? verificationId;
  final int? resendToken;

  // Backend check
  final bool driverExists;
  final bool shouldRedirectToRegister;

  const LoginState({
    this.step = LoginStep.phone,
    this.phoneNumber = '',
    this.otpDigits = const ['', '', '', '', '', ''],
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.isError = false,
    this.isSuccess = false,
    this.errorMessage = '',
    this.verificationId,
    this.resendToken,
    this.driverExists = false,
    this.shouldRedirectToRegister = false,
  });

  LoginState copyWith({
    LoginStep? step,
    String? phoneNumber,
    List<String>? otpDigits,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    bool? isError,
    bool? isSuccess,
    String? errorMessage,
    String? verificationId,
    int? resendToken,
    bool? driverExists,
    bool? shouldRedirectToRegister,
  }) {
    return LoginState(
      step: step ?? this.step,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otpDigits: otpDigits ?? this.otpDigits,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      isError: isError ?? this.isError,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      driverExists: driverExists ?? this.driverExists,
      shouldRedirectToRegister:
          shouldRedirectToRegister ?? this.shouldRedirectToRegister,
    );
  }

  bool get isPhoneValid => phoneNumber.length == 10;
  String get otpString => otpDigits.join();
  bool get isOtpComplete => otpDigits.every((d) => d.isNotEmpty);
  int get filledOtpCount => otpDigits.where((d) => d.isNotEmpty).length;
  String get maskedPhone =>
      phoneNumber.length >= 10
          ? '******${phoneNumber.substring(6)}'
          : phoneNumber;
}

class LoginNotifier extends Notifier<LoginState> {
  @override
  LoginState build() => const LoginState();

  void setPhoneNumber(String phone) {
    state = state.copyWith(
      phoneNumber: phone.replaceAll(RegExp(r'[^\d]'), ''),
      isError: false,
      errorMessage: '',
      shouldRedirectToRegister: false,
    );
  }

  /// Step 1: Check if driver exists, then send OTP if yes.
  Future<void> sendOtp() async {
    if (!state.isPhoneValid) {
      state = state.copyWith(
        isError: true,
        errorMessage: 'Enter a valid 10-digit phone number',
      );
      return;
    }

    state = state.copyWith(
      isSendingOtp: true,
      isError: false,
      shouldRedirectToRegister: false,
    );

    try {
      // Check if driver exists in backend
      final driverData = await DriverService.checkDriverExists(
        state.phoneNumber,
      );

      if (driverData == null) {
        // Driver does NOT exist → redirect to register
        state = state.copyWith(
          isSendingOtp: false,
          driverExists: false,
          shouldRedirectToRegister: true,
        );
        return;
      }

      // Driver exists → send Firebase OTP
      state = state.copyWith(driverExists: true);
      await _sendFirebaseOtp();
    } catch (e) {
      state = state.copyWith(
        isSendingOtp: false,
        isError: true,
        errorMessage: 'Connection error. Please check your network.',
      );
    }
  }

  /// Send Firebase OTP (used for both login and post-register).
  Future<void> _sendFirebaseOtp() async {
    await AuthService.sendOtp(
      phone: state.phoneNumber,
      forceResendingToken: state.resendToken,
      onCodeSent: (verificationId, resendToken) {
        state = state.copyWith(
          isSendingOtp: false,
          step: LoginStep.otp,
          verificationId: verificationId,
          resendToken: resendToken,
        );
      },
      onError: (error) {
        state = state.copyWith(
          isSendingOtp: false,
          isError: true,
          errorMessage: error,
        );
      },
      onAutoVerified: (PhoneAuthCredential credential) async {
        // Android auto-verification
        state = state.copyWith(isVerifyingOtp: true);
        final userCredential = await AuthService.signInWithCredential(credential);
        final success = userCredential != null;
        state = state.copyWith(
          isVerifyingOtp: false,
          isSuccess: success,
          isError: !success,
          errorMessage: success ? '' : 'Auto-verification failed.',
        );
      },
    );
  }

  /// Public method to send OTP after registration (skips exists check).
  Future<void> sendOtpForRegisteredUser(String phone) async {
    state = state.copyWith(
      phoneNumber: phone,
      isSendingOtp: true,
      isError: false,
      driverExists: true,
      shouldRedirectToRegister: false,
    );
    await _sendFirebaseOtp();
  }

  void setOtpDigit(String digit) {
    if (state.isVerifyingOtp || state.isSuccess) return;
    final digits = List<String>.from(state.otpDigits);
    final emptyIndex = digits.indexWhere((d) => d.isEmpty);
    if (emptyIndex == -1) return;
    digits[emptyIndex] = digit;
    state = state.copyWith(otpDigits: digits, isError: false);
  }

  void deleteOtpDigit() {
    if (state.isVerifyingOtp || state.isSuccess) return;
    final digits = List<String>.from(state.otpDigits);
    int lastFilled = -1;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (digits[i].isNotEmpty) {
        lastFilled = i;
        break;
      }
    }
    if (lastFilled == -1) return;
    digits[lastFilled] = '';
    state = state.copyWith(otpDigits: digits, isError: false);
  }

  void clearOtp() {
    state = state.copyWith(
      otpDigits: ['', '', '', '', '', ''],
      isError: false,
    );
  }

  /// Verify OTP against Firebase.
  Future<bool> verifyOtp() async {
    if (!state.isOtpComplete || state.isVerifyingOtp) return false;
    if (state.verificationId == null) {
      state = state.copyWith(
        isError: true,
        errorMessage: 'Verification expired. Please resend OTP.',
      );
      return false;
    }

    state = state.copyWith(isVerifyingOtp: true, isError: false);

    try {
      final userCredential = await AuthService.verifyOtp(
        verificationId: state.verificationId!,
        smsCode: state.otpString,
      );
      final success = userCredential != null;

      if (success) {
        final user = userCredential.user;
        if (user != null) {
          final token = await user.getIdToken();
          if (token != null) {
            // 1. Fetch backend driver profile to get the ID
            final driverData = await DriverService.getDriverByPhone(state.phoneNumber);
            if (driverData != null) {
              final driverId = driverData['id']?.toString() ?? driverData['driver_id']?.toString();
              if (driverId != null && driverId.isNotEmpty) {
                // 2. AWAIT the sync! (Do not move forward until this finishes)
                debugPrint('[LoginNotifier] Awaiting sync of Firebase UID: ${user.uid}');
                await DriverService.syncFirebaseUid(driverId, user.uid, token);
              }
            }
          }
        }

        // 3. Force a tiny artificial delay just to ensure Riverpod and GoRouter sync up
        await Future.delayed(const Duration(milliseconds: 300));

        state = state.copyWith(isVerifyingOtp: false, isSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isVerifyingOtp: false,
          isError: true,
          errorMessage: 'Invalid OTP. Please try again.',
          otpDigits: ['', '', '', '', '', ''],
        );
        return false;
      }
    } catch (e) {
      debugPrint('[LoginNotifier] OTP Login Failed: $e');
      state = state.copyWith(
        isVerifyingOtp: false,
        isError: true,
        errorMessage: 'OTP Login Failed: $e',
        otpDigits: ['', '', '', '', '', ''],
      );
      return false;
    }
  }

  void goBackToPhone() {
    state = const LoginState();
  }

  Future<void> resendOtp() async {
    state = state.copyWith(
      otpDigits: ['', '', '', '', '', ''],
      isError: false,
      isSendingOtp: true,
    );
    await _sendFirebaseOtp();
  }
}
