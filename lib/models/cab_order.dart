// Cab order model for two-wheeler cab bookings
class CabOrder {
  final String id;
  final String passengerName;
  final String pickupAddress;
  final String dropAddress;
  final int etaMinutes;
  final String distance;
  final double fare;
  final String contactNumber;
  final String notes;

  const CabOrder({
    required this.id,
    required this.passengerName,
    required this.pickupAddress,
    required this.dropAddress,
    required this.etaMinutes,
    required this.distance,
    required this.fare,
    required this.contactNumber,
    this.notes = '',
  });
}
