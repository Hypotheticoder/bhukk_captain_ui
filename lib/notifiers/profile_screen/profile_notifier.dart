import 'package:bhukkdelivery/providers/auth/auth_provider.dart';
import 'package:bhukkdelivery/services/api/driver_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String id; // Backend internal driver UUID
  final String name;
  final String phone;
  final String email;
  final String vehicleType;
  final String vehicleBrand;
  final String vehicleModel;
  final String vehicleNumber;
  final String vehicleColor;
  final double rating;
  final int totalDeliveries;
  final String joinDate;

  // File paths
  final String? profilePhotoPath;
  final String? drivingLicensePath;
  final String? rcBookPath;
  final String? insurancePath;
  final String? panCardPath;
  final String? aadharCardPath;

  // Bank details
  final String? bankAccountHolder;
  final String? bankAccountNumber;
  final String? bankIfscCode;
  final String? bankUpiId;

  UserProfile({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.vehicleType,
    this.vehicleBrand = '',
    this.vehicleModel = '',
    this.vehicleNumber = '',
    this.vehicleColor = '',
    required this.rating,
    required this.totalDeliveries,
    required this.joinDate,
    this.profilePhotoPath,
    this.drivingLicensePath,
    this.rcBookPath,
    this.insurancePath,
    this.panCardPath,
    this.aadharCardPath,
    this.bankAccountHolder,
    this.bankAccountNumber,
    this.bankIfscCode,
    this.bankUpiId,
  });

  /// Whether the driver has saved bank details.
  bool get hasBankDetails =>
      bankAccountHolder != null &&
      bankAccountHolder!.isNotEmpty &&
      bankAccountNumber != null &&
      bankAccountNumber!.isNotEmpty;

  /// Returns a masked account number like "XXXX XXXX 1234".
  String get maskedAccountNumber {
    if (bankAccountNumber == null || bankAccountNumber!.length < 4) {
      return bankAccountNumber ?? '';
    }
    final last4 = bankAccountNumber!.substring(bankAccountNumber!.length - 4);
    return 'XXXX XXXX $last4';
  }

  UserProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? vehicleType,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleNumber,
    String? vehicleColor,
    double? rating,
    int? totalDeliveries,
    String? joinDate,
    String? profilePhotoPath,
    String? drivingLicensePath,
    String? rcBookPath,
    String? insurancePath,
    String? panCardPath,
    String? aadharCardPath,
    String? bankAccountHolder,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankUpiId,
    bool clearProfilePhoto = false,
    bool clearDrivingLicense = false,
    bool clearRcBook = false,
    bool clearInsurance = false,
    bool clearPanCard = false,
    bool clearAadharCard = false,
  }) {
    return UserProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleBrand: vehicleBrand ?? this.vehicleBrand,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      vehicleColor: vehicleColor ?? this.vehicleColor,
      rating: rating ?? this.rating,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      joinDate: joinDate ?? this.joinDate,
      profilePhotoPath: clearProfilePhoto
          ? null
          : (profilePhotoPath ?? this.profilePhotoPath),
      drivingLicensePath: clearDrivingLicense
          ? null
          : (drivingLicensePath ?? this.drivingLicensePath),
      rcBookPath: clearRcBook ? null : (rcBookPath ?? this.rcBookPath),
      insurancePath:
          clearInsurance ? null : (insurancePath ?? this.insurancePath),
      panCardPath: clearPanCard ? null : (panCardPath ?? this.panCardPath),
      aadharCardPath:
          clearAadharCard ? null : (aadharCardPath ?? this.aadharCardPath),
      bankAccountHolder: bankAccountHolder ?? this.bankAccountHolder,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfscCode: bankIfscCode ?? this.bankIfscCode,
      bankUpiId: bankUpiId ?? this.bankUpiId,
    );
  }

  String get vehicleDisplay {
    if (vehicleBrand.isNotEmpty && vehicleModel.isNotEmpty) {
      return '$vehicleBrand $vehicleModel';
    }
    return vehicleType;
  }

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

  /// Factory constructor to build a UserProfile from a backend JSON map.
  /// Maps to the FastAPI DriverRead schema where:
  ///   - name field is 'name' (not 'full_name')
  ///   - document URLs are flat fields: driving_license_url, rc_book_url, etc.
  factory UserProfile.fromJson(Map<String, dynamic> data) {
    String joinDate = "Recently joined";
    if (data['created_at'] != null) {
      joinDate = data['created_at'].toString().split('T').first;
    }

    // Document URLs are flat fields on the DriverRead model (not nested)
    final photoPath = data['profile_photo_url']?.toString();
    final dlPath = data['driving_license_url']?.toString();
    final rcPath = data['rc_book_url']?.toString();
    final insurPath = data['insurance_url']?.toString();
    final panPath = data['pan_card_url']?.toString();
    final aadharPath = data['aadhar_card_url']?.toString();

    return UserProfile(
      id: data['id']?.toString() ?? data['driver_id']?.toString() ?? '',
      name: data['name']?.toString() ?? data['full_name']?.toString() ?? 'Driver',
      phone: data['phone_number']?.toString() ?? '',
      email: data['email']?.toString() ?? '',
      vehicleType: data['vehicle_type']?.toString() ?? 'bike',
      vehicleBrand: data['vehicle_brand']?.toString() ?? '',
      vehicleModel: data['vehicle_model']?.toString() ?? '',
      vehicleNumber: data['vehicle_number']?.toString() ?? '',
      vehicleColor: data['vehicle_color']?.toString() ?? '',
      rating: (data['rating'] is num)
          ? (data['rating'] as num).toDouble()
          : 4.8,
      totalDeliveries: data['total_deliveries'] as int? ?? 0,
      joinDate: joinDate,
      profilePhotoPath: photoPath,
      drivingLicensePath: dlPath,
      rcBookPath: rcPath,
      insurancePath: insurPath,
      panCardPath: panPath,
      aadharCardPath: aadharPath,
      bankAccountHolder: data['bank_account_holder']?.toString(),
      bankAccountNumber: data['bank_account_number']?.toString(),
      bankIfscCode: data['bank_ifsc_code']?.toString(),
      bankUpiId: data['bank_upi_id']?.toString(),
    );
  }
}

class ProfileNotifier extends Notifier<UserProfile?> {
  @override
  UserProfile? build() {
    // Watch auth state reactively. Whenever the user signs in or out, 
    // this build() method will re-run automatically.
    final authState = ref.watch(firebaseAuthProvider);
    
    return authState.when(
      data: (user) {
        if (user == null) {
          debugPrint('[ProfileNotifier] User is null, clearing profile state.');
          return null;
        }
        debugPrint('[ProfileNotifier] User logged in: ${user.uid}. Fetching profile...');
        _fetchProfile(user);
        return null; // Return null (loading) while fetching
      },
      loading: () => null,
      error: (error, stack) => null,
    );
  }

  /// Fetches the driver profile from the backend.
  Future<void> _fetchProfile(User user) async {
    try {
      // 1. 🛑 THE FIX: Force Dart to wait until Firebase guarantees the user is fully mounted in the stream.
      // This entirely bypasses the micro-transition race condition!
      final activeUser = await FirebaseAuth.instance.authStateChanges().firstWhere(
        (u) => u != null,
        orElse: () => null,
      );

      if (activeUser == null) {
        debugPrint('[ProfileNotifier] Aborting fetch: User is definitively null.');
        return;
      }

      // ── Fast path: lookup by Firebase UID ──
      try {
        final data = await DriverService.getDriver(activeUser.uid);
        state = UserProfile.fromJson(data);
        debugPrint('[ProfileNotifier] ✓ Loaded profile via UID: ${state?.name}');
        return;
      } catch (_) {
        debugPrint('[ProfileNotifier] UID lookup 404 — trying phone fallback...');
      }

      // ── Fallback: lookup by phone number ──
      final phone = activeUser.phoneNumber;
      if (phone == null || phone.isEmpty) {
        debugPrint('[ProfileNotifier] No phone number on Firebase user.');
        _setFallbackProfile(activeUser);
        return;
      }

      final driverData = await DriverService.getDriverByPhone(phone);
      if (driverData == null) {
        debugPrint('[ProfileNotifier] Driver not found via phone either.');
        _setFallbackProfile(activeUser);
        return;
      }

      state = UserProfile.fromJson(driverData);
      debugPrint('[ProfileNotifier] ✓ Loaded profile via phone: ${state?.name}');

      // ── Sync the new Firebase UID to backend ──
      // So next login resolves via the fast UID path
      final backendId = state?.id ?? '';
      if (backendId.isNotEmpty) {
        debugPrint('[ProfileNotifier] Syncing new firebase_uid → $backendId');
        final token = await activeUser.getIdToken(true); // Force token refresh
        if (token != null) {
          await DriverService.syncFirebaseUid(backendId, activeUser.uid, token);
        }
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('[ProfileNotifier] Firebase Auth Guard caught an error: ${e.code}');
      _setFallbackProfile(user);
    } catch (e) {
      debugPrint('[ProfileNotifier] Profile fetch error: $e');
      _setFallbackProfile(user);
    }
  }

  /// Sets a minimal fallback profile from Firebase user data
  /// so the UI doesn't show an infinite spinner.
  void _setFallbackProfile(User user) {
    state = UserProfile(
      id: user.uid,
      name: user.displayName ?? 'Driver',
      phone: user.phoneNumber ?? '',
      email: user.email ?? '',
      vehicleType: 'bike',
      rating: 4.8,
      totalDeliveries: 0,
      joinDate: 'Recently joined',
    );
  }

  /// Force a re-fetch of the profile from the backend.
  Future<void> refresh() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      state = null;
      await _fetchProfile(user);
    }
  }

  Future<void> updateProfile({
    String? name,
    String? phone,
    String? email,
    String? vehicleType,
    String? vehicleBrand,
    String? vehicleModel,
    String? vehicleNumber,
    String? vehicleColor,
    String? bankAccountHolder,
    String? bankAccountNumber,
    String? bankIfscCode,
    String? bankUpiId,
  }) async {
    final current = state;
    if (current == null) return;

    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (phone != null) data['phone_number'] = phone;
    if (email != null) data['email'] = email;
    if (vehicleType != null) data['vehicle_type'] = vehicleType;
    if (vehicleBrand != null) data['vehicle_brand'] = vehicleBrand;
    if (vehicleModel != null) data['vehicle_model'] = vehicleModel;
    if (vehicleNumber != null) data['vehicle_number'] = vehicleNumber;
    if (vehicleColor != null) data['vehicle_color'] = vehicleColor;
    if (bankAccountHolder != null) data['bank_account_holder'] = bankAccountHolder;
    if (bankAccountNumber != null) data['bank_account_number'] = bankAccountNumber;
    if (bankIfscCode != null) data['bank_ifsc_code'] = bankIfscCode;
    if (bankUpiId != null) data['bank_upi_id'] = bankUpiId;

    // Use the backend internal ID, not Firebase UID
    final driverId = current.id;

    if (driverId.isNotEmpty && data.isNotEmpty) {
      try {
        await DriverService.updateDriver(driverId, data);
      } catch (_) {
        // Silently fail update on error
      }
    }

    state = current.copyWith(
      name: name,
      phone: phone,
      email: email,
      vehicleType: vehicleType,
      vehicleBrand: vehicleBrand,
      vehicleModel: vehicleModel,
      vehicleNumber: vehicleNumber,
      vehicleColor: vehicleColor,
      bankAccountHolder: bankAccountHolder,
      bankAccountNumber: bankAccountNumber,
      bankIfscCode: bankIfscCode,
      bankUpiId: bankUpiId,
    );
  }

  Future<void> setProfilePhoto(String path) async {
    if (state == null) return;
    _uploadDoc('profile_photo', path);
    state = state!.copyWith(profilePhotoPath: path);
  }

  Future<void> setDocument(String docType, String path) async {
    if (state == null) return;
    
    String backendDocType = docType;
    switch (docType) {
      case 'dl':
        backendDocType = 'driving_license';
        state = state!.copyWith(drivingLicensePath: path);
        break;
      case 'rc':
        backendDocType = 'rc_book';
        state = state!.copyWith(rcBookPath: path);
        break;
      case 'insurance':
        backendDocType = 'insurance';
        state = state!.copyWith(insurancePath: path);
        break;
      case 'pan':
        backendDocType = 'pan_card';
        state = state!.copyWith(panCardPath: path);
        break;
      case 'aadhar':
        backendDocType = 'aadhar_card';
        state = state!.copyWith(aadharCardPath: path);
        break;
    }
    
    _uploadDoc(backendDocType, path);
  }

  Future<void> _uploadDoc(String docType, String path) async {
    final driverId = state?.id ?? '';
    if (driverId.isNotEmpty) {
      try {
        await DriverService.uploadDocument(driverId, docType, path);
      } catch (_) {}
    }
  }

  void removeDocument(String docType) {
    if (state == null) return;
    switch (docType) {
      case 'profile':
        state = state!.copyWith(clearProfilePhoto: true);
        break;
      case 'dl':
        state = state!.copyWith(clearDrivingLicense: true);
        break;
      case 'rc':
        state = state!.copyWith(clearRcBook: true);
        break;
      case 'insurance':
        state = state!.copyWith(clearInsurance: true);
        break;
      case 'pan':
        state = state!.copyWith(clearPanCard: true);
        break;
      case 'aadhar':
        state = state!.copyWith(clearAadharCard: true);
        break;
    }
  }
}
