class CosmaticsOrder {
  final String id;
  final String storeName;
  final String items;
  final int itemCount;
  final String pickupAddress;
  final String dropAddress;
  final int etaMinutes;
  final String distance;
  final double fare;
  final String contactNumber;
  final String notes;

  const CosmaticsOrder({
    required this.id,
    required this.storeName,
    required this.items,
    required this.itemCount,
    required this.pickupAddress,
    required this.dropAddress,
    required this.etaMinutes,
    required this.distance,
    required this.fare,
    required this.contactNumber,
    this.notes = '',
  });
}
