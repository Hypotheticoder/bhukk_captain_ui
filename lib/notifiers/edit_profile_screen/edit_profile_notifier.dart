import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Bike Document Model ──
enum DocumentStatus { notUploaded, uploaded, expired }

class BikeDocument {
  final String title;
  final IconType iconType;
  final DocumentStatus status;
  final String? uploadedDate;
  final String? url;

  const BikeDocument({
    required this.title,
    required this.iconType,
    this.status = DocumentStatus.notUploaded,
    this.uploadedDate,
    this.url,
  });

  BikeDocument copyWith({
    DocumentStatus? status,
    String? uploadedDate,
    String? url,
  }) {
    return BikeDocument(
      title: title,
      iconType: iconType,
      status: status ?? this.status,
      uploadedDate: uploadedDate ?? this.uploadedDate,
      url: url ?? this.url,
    );
  }
}

enum IconType { rc, insurance, dl, puc }

// ── Edit Profile State ──
class EditProfileState {
  final String name;
  final String phone;
  final String email;
  final String vehicleType;
  final String vehicleNumber;
  final List<BikeDocument> documents;
  final bool isSaving;
  final bool saveSuccess;

  const EditProfileState({
    this.name = '',
    this.phone = '',
    this.email = '',
    this.vehicleType = '',
    this.vehicleNumber = '',
    this.documents = const [],
    this.isSaving = false,
    this.saveSuccess = false,
  });

  EditProfileState copyWith({
    String? name,
    String? phone,
    String? email,
    String? vehicleType,
    String? vehicleNumber,
    List<BikeDocument>? documents,
    bool? isSaving,
    bool? saveSuccess,
  }) {
    return EditProfileState(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      documents: documents ?? this.documents,
      isSaving: isSaving ?? this.isSaving,
      saveSuccess: saveSuccess ?? this.saveSuccess,
    );
  }
}

// ── Notifier ──
class EditProfileNotifier extends Notifier<EditProfileState> {
  @override
  EditProfileState build() {
    return const EditProfileState(
      documents: [
        BikeDocument(title: 'Registration Certificate', iconType: IconType.rc),
        BikeDocument(title: 'Insurance', iconType: IconType.insurance),
        BikeDocument(title: 'Driving License', iconType: IconType.dl),
        BikeDocument(title: 'PUC Certificate', iconType: IconType.puc),
      ],
    );
  }

  void initFromProfile({
    required String name,
    required String phone,
    required String email,
    required String vehicleType,
    required String vehicleNumber,
    String? rcPath,
    String? insurancePath,
    String? dlPath,
    String? pucPath,
  }) {
    final docs = [
      BikeDocument(
        title: 'Registration Certificate',
        iconType: IconType.rc,
        status: rcPath != null && rcPath.isNotEmpty
            ? DocumentStatus.uploaded
            : DocumentStatus.notUploaded,
        url: rcPath,
      ),
      BikeDocument(
        title: 'Insurance',
        iconType: IconType.insurance,
        status: insurancePath != null && insurancePath.isNotEmpty
            ? DocumentStatus.uploaded
            : DocumentStatus.notUploaded,
        url: insurancePath,
      ),
      BikeDocument(
        title: 'Driving License',
        iconType: IconType.dl,
        status: dlPath != null && dlPath.isNotEmpty
            ? DocumentStatus.uploaded
            : DocumentStatus.notUploaded,
        url: dlPath,
      ),
      BikeDocument(
        title: 'PUC Certificate',
        iconType: IconType.puc,
        status: pucPath != null && pucPath.isNotEmpty
            ? DocumentStatus.uploaded
            : DocumentStatus.notUploaded,
        url: pucPath,
      ),
    ];

    state = state.copyWith(
      name: name,
      phone: phone,
      email: email,
      vehicleType: vehicleType,
      vehicleNumber: vehicleNumber,
      documents: docs,
    );
  }

  void updateName(String value) => state = state.copyWith(name: value);
  void updatePhone(String value) => state = state.copyWith(phone: value);
  void updateEmail(String value) => state = state.copyWith(email: value);
  void updateVehicleType(String value) =>
      state = state.copyWith(vehicleType: value);
  void updateVehicleNumber(String value) =>
      state = state.copyWith(vehicleNumber: value);

  // Document upload with path
  Future<void> uploadDocument(int index, String path) async {
    final docs = List<BikeDocument>.from(state.documents);
    docs[index] = docs[index].copyWith(
      status: DocumentStatus.uploaded,
      url: path,
    );
    state = state.copyWith(documents: docs);
  }

  // Simulate save
  Future<void> saveProfile() async {
    state = state.copyWith(isSaving: true, saveSuccess: false);
    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 1200));
    state = state.copyWith(isSaving: false, saveSuccess: true);
  }
}
