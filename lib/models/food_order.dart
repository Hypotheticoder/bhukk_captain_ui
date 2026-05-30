// Food order model used by the Food Take Orders UI
class FoodOrder {
  final String id;
  final String restaurantName;
  final List<String> items;
  final int totalItems;
  final String pickupAddress;
  final String dropAddress;
  final int etaMinutes;
  final String distance;
  final double fare;
  final String contactNumber;
  final String notes;

  const FoodOrder({
    required this.id,
    required this.restaurantName,
    required this.items,
    required this.totalItems,
    required this.pickupAddress,
    required this.dropAddress,
    required this.etaMinutes,
    required this.distance,
    required this.fare,
    required this.contactNumber,
    this.notes = '',
  });
}
