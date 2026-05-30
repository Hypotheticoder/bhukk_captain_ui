// Ambulance order model used by the Take Order UI
class AmbulanceOrder {
  final String id;
  final String patientName;
  final String pickupAddress;
  final String dropAddress;
  final String severity; // e.g., "Critical", "High", "Moderate"
  final int etaMinutes;
  final String distance;
  final double fare;
  final String contactNumber;
  final String notes;

  const AmbulanceOrder({
    required this.id,
    required this.patientName,
    required this.pickupAddress,
    required this.dropAddress,
    required this.severity,
    required this.etaMinutes,
    required this.distance,
    required this.fare,
    required this.contactNumber,
    this.notes = '',
  });
}
