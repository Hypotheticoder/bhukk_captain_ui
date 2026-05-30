import 'package:bhukkdelivery/services/api/auth_service.dart';
import 'package:bhukkdelivery/services/api/driver_service.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum RegisterStep { personal, vehicle, documents, otp }

class RegisterState {
  // Step tracking
  final RegisterStep currentStep;
  final bool isSubmitting;
  final bool isSuccess;
  final String errorMessage;

  // Personal Info
  final String fullName;
  final String email;
  final String phone;
  final String city;
  final String dateOfBirth;

  // Vehicle Info
  final String vehicleType;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehicleYear;
  final String vehicleNumber;
  final String vehicleColor;

  // Documents
  final String? profilePhotoPath;
  final String? drivingLicensePath;
  final String? rcBookPath;
  final String? insurancePath;
  final String? panCardPath;
  final String? aadharCardPath;

  // OTP / Firebase
  final String? verificationId;
  final int? resendToken;
  final List<String> otpDigits;
  final bool isSendingOtp;
  final bool isVerifyingOtp;

  // Backend response
  final String? driverId;

  const RegisterState({
    this.currentStep = RegisterStep.personal,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.errorMessage = '',
    this.fullName = '',
    this.email = '',
    this.phone = '',
    this.city = '',
    this.dateOfBirth = '',
    this.vehicleType = 'bike',
    this.vehicleBrand = '',
    this.vehicleModel = '',
    this.vehicleYear = '',
    this.vehicleNumber = '',
    this.vehicleColor = '',
    this.profilePhotoPath,
    this.drivingLicensePath,
    this.rcBookPath,
    this.insurancePath,
    this.panCardPath,
    this.aadharCardPath,
    this.verificationId,
    this.resendToken,
    this.otpDigits = const ['', '', '', '', '', ''],
    this.isSendingOtp = false,
    this.isVerifyingOtp = false,
    this.driverId,
  });

  RegisterState copyWith({
    RegisterStep? currentStep,
    bool? isSubmitting,
    bool? isSuccess,
    String? errorMessage,
    String? fullName,
    String? email,
    String? phone,
    String? city,
    String? dateOfBirth,
    String? vehicleType,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleYear,
    String? vehicleNumber,
    String? vehicleColor,
    String? profilePhotoPath,
    String? drivingLicensePath,
    String? rcBookPath,
    String? insurancePath,
    String? panCardPath,
    String? aadharCardPath,
    bool clearProfilePhoto = false,
    bool clearDrivingLicense = false,
    bool clearRcBook = false,
    bool clearInsurance = false,
    bool clearPanCard = false,
    bool clearAadharCard = false,
    String? verificationId,
    int? resendToken,
    List<String>? otpDigits,
    bool? isSendingOtp,
    bool? isVerifyingOtp,
    String? driverId,
  }) {
    return RegisterState(
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleYear: vehicleYear ?? this.vehicleYear,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      profilePhotoPath: clearProfilePhoto
          ? null
          : (profilePhotoPath ?? this.profilePhotoPath),
      drivingLicensePath: clearDrivingLicense
          ? null
          : (drivingLicensePath ?? this.drivingLicensePath),
      rcBookPath: clearRcBook ? null : (rcBookPath ?? this.rcBookPath),
      insurancePath: clearInsurance
          ? null
          : (insurancePath ?? this.insurancePath),
      panCardPath: clearPanCard ? null : (panCardPath ?? this.panCardPath),
      aadharCardPath: clearAadharCard
          ? null
          : (aadharCardPath ?? this.aadharCardPath),
      verificationId: verificationId ?? this.verificationId,
      resendToken: resendToken ?? this.resendToken,
      otpDigits: otpDigits ?? this.otpDigits,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      isVerifyingOtp: isVerifyingOtp ?? this.isVerifyingOtp,
      driverId: driverId ?? this.driverId,
    );
  }

  int get stepIndex {
    switch (currentStep) {
      case RegisterStep.personal:
        return 0;
      case RegisterStep.vehicle:
        return 1;
      case RegisterStep.documents:
        return 2;
      case RegisterStep.otp:
        return 3;
    }
  }

  int get totalSteps => 4;

  String get stepTitle {
    switch (currentStep) {
      case RegisterStep.personal:
        return 'Personal Details';
      case RegisterStep.vehicle:
        return 'Vehicle Information';
      case RegisterStep.documents:
        return 'Documents Upload';
      case RegisterStep.otp:
        return 'Verify Phone';
    }
  }

  String get stepSubtitle {
    switch (currentStep) {
      case RegisterStep.personal:
        return 'Tell us about yourself';
      case RegisterStep.vehicle:
        return 'Your delivery vehicle details';
      case RegisterStep.documents:
        return 'Upload verification documents';
      case RegisterStep.otp:
        return 'Verify your phone number via OTP';
    }
  }

  IconData get stepIcon {
    switch (currentStep) {
      case RegisterStep.personal:
        return Icons.person_rounded;
      case RegisterStep.vehicle:
        return Icons.two_wheeler_rounded;
      case RegisterStep.documents:
        return Icons.folder_rounded;
      case RegisterStep.otp:
        return Icons.sms_rounded;
    }
  }

  bool get isPersonalValid => fullName.trim().length >= 2 && phone.length == 10;
  bool get isVehicleValid =>
      vehicleBrand.trim().isNotEmpty &&
      vehicleModel.trim().isNotEmpty &&
      vehicleNumber.trim().length >= 4;
  bool get isDocumentsValid =>
      profilePhotoPath != null && drivingLicensePath != null;

  String get otpString => otpDigits.join();
  bool get isOtpComplete => otpDigits.every((d) => d.isNotEmpty);
  int get filledOtpCount => otpDigits.where((d) => d.isNotEmpty).length;
  String get maskedPhone =>
      phone.length >= 10 ? '******${phone.substring(6)}' : phone;

  int get uploadedDocsCount {
    int count = 0;
    if (profilePhotoPath != null) count++;
    if (drivingLicensePath != null) count++;
    if (rcBookPath != null) count++;
    if (insurancePath != null) count++;
    if (panCardPath != null) count++;
    if (aadharCardPath != null) count++;
    return count;
  }
}

class RegisterNotifier extends Notifier<RegisterState> {
  String _errorFromException(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['detail'] != null) {
        return data['detail'].toString();
      }
      if (data is String && data.trim().isNotEmpty) {
        return data.trim();
      }
      final message = e.message;
      if (message != null && message.trim().isNotEmpty) {
        return message.trim();
      }
      return 'Network/server error. Please try again.';
    }
    return e.toString();
  }

  @override
  RegisterState build() => const RegisterState();

  // ── Navigation ──

  void goToStep(RegisterStep step) {
    state = state.copyWith(currentStep: step, errorMessage: '');
  }

  bool nextStep() {
    switch (state.currentStep) {
      case RegisterStep.personal:
        if (!state.isPersonalValid) {
          state = state.copyWith(
            errorMessage: 'Please fill in your name and phone number',
          );
          return false;
        }
        state = state.copyWith(
          currentStep: RegisterStep.vehicle,
          errorMessage: '',
        );
        return true;
      case RegisterStep.vehicle:
        if (!state.isVehicleValid) {
          state = state.copyWith(
            errorMessage: 'Please fill vehicle brand, model and number',
          );
          return false;
        }
        state = state.copyWith(
          currentStep: RegisterStep.documents,
          errorMessage: '',
        );
        return true;
      case RegisterStep.documents:
        if (!state.isDocumentsValid) {
          state = state.copyWith(
            errorMessage:
                'Please upload at least your profile photo and driving license',
          );
          return false;
        }
        // Move to OTP step and trigger OTP send
        _goToOtpStep();
        return true;
      case RegisterStep.otp:
        return true; // Last step — handled by verifyOtpAndSubmit
    }
  }

  void previousStep() {
    switch (state.currentStep) {
      case RegisterStep.personal:
        return;
      case RegisterStep.vehicle:
        state = state.copyWith(
          currentStep: RegisterStep.personal,
          errorMessage: '',
        );
        break;
      case RegisterStep.documents:
        state = state.copyWith(
          currentStep: RegisterStep.vehicle,
          errorMessage: '',
        );
        break;
      case RegisterStep.otp:
        state = state.copyWith(
          currentStep: RegisterStep.documents,
          errorMessage: '',
          otpDigits: ['', '', '', '', '', ''],
        );
        break;
    }
  }

  // ── Personal fields ──

  void setFullName(String value) =>
      state = state.copyWith(fullName: value, errorMessage: '');
  void setEmail(String value) =>
      state = state.copyWith(email: value, errorMessage: '');
  void setPhone(String value) => state = state.copyWith(
    phone: value.replaceAll(RegExp(r'[^\d]'), ''),
    errorMessage: '',
  );
  void setCity(String value) =>
      state = state.copyWith(city: value, errorMessage: '');
  void setDateOfBirth(String value) =>
      state = state.copyWith(dateOfBirth: value, errorMessage: '');

  // ── Vehicle fields ──

  void setVehicleType(String value) =>
      state = state.copyWith(vehicleType: value, errorMessage: '');
  void setVehicleBrand(String value) =>
      state = state.copyWith(vehicleBrand: value, errorMessage: '');
  void setVehicleModel(String value) =>
      state = state.copyWith(vehicleModel: value, errorMessage: '');
  void setVehicleYear(String value) =>
      state = state.copyWith(vehicleYear: value, errorMessage: '');
  void setVehicleNumber(String value) =>
      state = state.copyWith(vehicleNumber: value, errorMessage: '');
  void setVehicleColor(String value) =>
      state = state.copyWith(vehicleColor: value, errorMessage: '');

  // ── Documents ──

  void setProfilePhoto(String path) =>
      state = state.copyWith(profilePhotoPath: path);
  void setDrivingLicense(String path) =>
      state = state.copyWith(drivingLicensePath: path);
  void setRcBook(String path) => state = state.copyWith(rcBookPath: path);
  void setInsurance(String path) => state = state.copyWith(insurancePath: path);
  void setPanCard(String path) => state = state.copyWith(panCardPath: path);
  void setAadharCard(String path) =>
      state = state.copyWith(aadharCardPath: path);

  void removeDocument(String docType) {
    switch (docType) {
      case 'profile':
        state = state.copyWith(clearProfilePhoto: true);
        break;
      case 'dl':
        state = state.copyWith(clearDrivingLicense: true);
        break;
      case 'rc':
        state = state.copyWith(clearRcBook: true);
        break;
      case 'insurance':
        state = state.copyWith(clearInsurance: true);
        break;
      case 'pan':
        state = state.copyWith(clearPanCard: true);
        break;
      case 'aadhar':
        state = state.copyWith(clearAadharCard: true);
        break;
    }
  }

  // ── OTP Step ──

  Future<void> _goToOtpStep() async {
    state = state.copyWith(
      currentStep: RegisterStep.otp,
      isSendingOtp: true,
      errorMessage: '',
    );
    await _sendFirebaseOtp();
  }

  Future<void> _sendFirebaseOtp() async {
    await AuthService.sendOtp(
      phone: state.phone,
      forceResendingToken: state.resendToken,
      onCodeSent: (verificationId, resendToken) {
        state = state.copyWith(
          isSendingOtp: false,
          verificationId: verificationId,
          resendToken: resendToken,
        );
      },
      onError: (error) {
        state = state.copyWith(isSendingOtp: false, errorMessage: error);
      },
      onAutoVerified: (PhoneAuthCredential credential) async {
        // Android auto-verification
        state = state.copyWith(isVerifyingOtp: true);
        final userCredential = await AuthService.signInWithCredential(credential);
        final success = userCredential != null;
        if (success) {
          await _createDriverOnBackend();
        } else {
          state = state.copyWith(
            isVerifyingOtp: false,
            errorMessage: 'Auto-verification failed.',
          );
        }
      },
    );
  }

  Future<void> resendOtp() async {
    state = state.copyWith(
      otpDigits: ['', '', '', '', '', ''],
      isSendingOtp: true,
      errorMessage: '',
    );
    await _sendFirebaseOtp();
  }

  void setOtpDigit(String digit) {
    if (state.isVerifyingOtp || state.isSuccess) return;
    final digits = List<String>.from(state.otpDigits);
    final emptyIndex = digits.indexWhere((d) => d.isEmpty);
    if (emptyIndex == -1) return;
    digits[emptyIndex] = digit;
    state = state.copyWith(otpDigits: digits, errorMessage: '');
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
    state = state.copyWith(otpDigits: digits, errorMessage: '');
  }

  /// Verify OTP → Firebase sign-in → then create driver on backend.
  Future<bool> verifyOtpAndSubmit() async {
    if (!state.isOtpComplete || state.isVerifyingOtp) return false;
    if (state.verificationId == null) {
      state = state.copyWith(
        errorMessage: 'Verification expired. Please resend OTP.',
      );
      return false;
    }

    state = state.copyWith(isVerifyingOtp: true, errorMessage: '');

    // Step 1: Verify OTP with Firebase
    final userCredential = await AuthService.verifyOtp(
      verificationId: state.verificationId!,
      smsCode: state.otpString,
    );
    final otpSuccess = userCredential != null;

    if (!otpSuccess) {
      state = state.copyWith(
        isVerifyingOtp: false,
        errorMessage: 'Invalid OTP. Please try again.',
        otpDigits: ['', '', '', '', '', ''],
      );
      return false;
    }

    // Step 2: Now user is Firebase-authenticated → create driver
    return await _createDriverOnBackend();
  }

  /// POST /drivers/create with Firebase token.
  Future<bool> _createDriverOnBackend() async {
    state = state.copyWith(isSubmitting: true);

    try {


      final data = {
        'name': state.fullName,
        'email': state.email,
        'phone_number': state.phone,
        'city': state.city,
        'vehicle_type': state.vehicleType,
        'vehicle_brand': state.vehicleBrand,
        'vehicle_model': state.vehicleModel,
        'vehicle_number': state.vehicleNumber,
        'vehicle_color': state.vehicleColor,
      };

      final response = await DriverService.createDriver(data);
      final driverId =
          response['id']?.toString() ?? response['driver_id']?.toString();

      // Upload documents
      if (driverId != null && driverId.isNotEmpty) {
        await _uploadDocuments(driverId);
      }

      state = state.copyWith(
        isSubmitting: false,
        isVerifyingOtp: false,
        isSuccess: true,
        driverId: driverId,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        isVerifyingOtp: false,
        isSuccess: false,
        errorMessage: _errorFromException(e),
      );
      return false;
    }
  }

  Future<void> _uploadDocuments(String driverId) async {
    final docs = <String, String?>{
      'profile_photo': state.profilePhotoPath,
      'driving_license': state.drivingLicensePath,
      'rc_book': state.rcBookPath,
      'insurance': state.insurancePath,
      'pan_card': state.panCardPath,
      'aadhar_card': state.aadharCardPath,
    };

    for (final entry in docs.entries) {
      if (entry.value != null && entry.value!.isNotEmpty) {
        try {
          await DriverService.uploadDocument(driverId, entry.key, entry.value!);
        } catch (_) {
          // Continue uploading other docs even if one fails
        }
      }
    }
  }
}
