import 'package:bhukkdelivery/providers/delivery/active_delivery_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpState {
  static const Object _unset = Object();

  final List<String> digits;
  final bool isVerifying;
  final bool isError;
  final bool isSuccess;
  final OtpType otpType;
  final String? errorMessage;

  const OtpState({
    this.digits = const ['', '', '', ''],
    this.isVerifying = false,
    this.isError = false,
    this.isSuccess = false,
    this.otpType = OtpType.pickup,
    this.errorMessage,
  });

  OtpState copyWith({
    List<String>? digits,
    bool? isVerifying,
    bool? isError,
    bool? isSuccess,
    OtpType? otpType,
    Object? errorMessage = _unset,
  }) {
    return OtpState(
      digits: digits ?? this.digits,
      isVerifying: isVerifying ?? this.isVerifying,
      isError: isError ?? this.isError,
      isSuccess: isSuccess ?? this.isSuccess,
      otpType: otpType ?? this.otpType,
      errorMessage: errorMessage == _unset
          ? this.errorMessage
          : errorMessage as String?,
    );
  }

  String get otpString => digits.join();
  bool get isComplete => digits.every((d) => d.isNotEmpty);
  int get filledCount => digits.where((d) => d.isNotEmpty).length;

  String get title => otpType == OtpType.pickup ? 'Pickup OTP' : 'Delivery OTP';
  String get subtitle => otpType == OtpType.pickup
      ? 'Enter the OTP from the store to confirm pickup'
      : 'Enter the OTP from the customer to complete delivery';
}

class OtpNotifier extends Notifier<OtpState> {
  @override
  OtpState build() => const OtpState();

  void initialize(OtpType type) {
    state = OtpState(otpType: type);
  }

  void setDigit(String digit) {
    if (state.isVerifying || state.isSuccess) return;

    final digits = List<String>.from(state.digits);
    final emptyIndex = digits.indexWhere((d) => d.isEmpty);
    if (emptyIndex == -1) return; // All filled

    digits[emptyIndex] = digit;
    state = state.copyWith(digits: digits, isError: false, errorMessage: null);
  }

  void deleteDigit() {
    if (state.isVerifying || state.isSuccess) return;

    final digits = List<String>.from(state.digits);
    // Find the last filled index
    int lastFilledIndex = -1;
    for (int i = digits.length - 1; i >= 0; i--) {
      if (digits[i].isNotEmpty) {
        lastFilledIndex = i;
        break;
      }
    }
    if (lastFilledIndex == -1) return; // All empty

    digits[lastFilledIndex] = '';
    state = state.copyWith(digits: digits, isError: false, errorMessage: null);
  }

  void clearAll() {
    if (state.isVerifying || state.isSuccess) return;
    state = state.copyWith(
      digits: ['', '', '', ''],
      isError: false,
      errorMessage: null,
    );
  }

  Future<bool> verify() async {
    if (!state.isComplete || state.isVerifying) return false;

    state = state.copyWith(
      isVerifying: true,
      isError: false,
      errorMessage: null,
    );

    try {
      // Simulate brief network delay
      await Future.delayed(const Duration(milliseconds: 600));

      final delivery = ref.read(activeDeliveryProvider);
      if (delivery == null) {
        state = state.copyWith(
          isVerifying: false,
          isError: true,
          errorMessage: 'No active order',
        );
        return false;
      }

      final activeDeliveryNotifier = ref.read(activeDeliveryProvider.notifier);
      final success = await activeDeliveryNotifier.verifyOtp(state.otpString);

      if (success) {
        state = state.copyWith(isVerifying: false, isSuccess: true);
        return true;
      } else {
        state = state.copyWith(
          isVerifying: false,
          isError: true,
          errorMessage: activeDeliveryNotifier.lastOtpError ?? 'Invalid OTP',
          digits: ['', '', '', ''],
        );
        return false;
      }
    } catch (e, stack) {
      debugPrint('Error during OTP verification: $e\n$stack');
      state = state.copyWith(
        isVerifying: false,
        isError: true,
        errorMessage: 'Connection error: ${e.toString()}',
        digits: ['', '', '', ''],
      );
      return false;
    }
  }
}
