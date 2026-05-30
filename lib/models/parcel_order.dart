// Parcel order model used by the Parcel Take Orders UI
class ParcelOrder {
  final String id;
  final String senderName;
  final String pickupAddress;
  final String dropAddress;
  final double weightKg;
  final String size; // e.g. "Small", "Medium", "Large"
  final int etaMinutes;
  final String distance;
  final double fare;
  final String contactNumber;
  final String notes;

  const ParcelOrder({
    required this.id,
    required this.senderName,
    required this.pickupAddress,
    required this.dropAddress,
    required this.weightKg,
    required this.size,
    required this.etaMinutes,
    required this.distance,
    required this.fare,
    required this.contactNumber,
    this.notes = '',
  });
}
