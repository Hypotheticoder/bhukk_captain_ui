import 'package:flutter/material.dart';

class BackendVehicleInfo {
  final String dbValue;
  final String displayName;
  final String description; // Detailed: which vehicles/cars fit here
  final String eligibleServices; // Description of services they get
  final IconData icon;

  const BackendVehicleInfo({
    required this.dbValue,
    required this.displayName,
    required this.description,
    required this.eligibleServices,
    required this.icon,
  });
}

const List<BackendVehicleInfo> kBackendVehicles = [
  BackendVehicleInfo(
    dbValue: 'bike',
    displayName: 'Bike / Motorcycle',
    description: 'Motorcycle, Scooter, Scooty, or E-Bike',
    eligibleServices: 'Ride Booking & Parcel Delivery',
    icon: Icons.two_wheeler_rounded,
  ),
  BackendVehicleInfo(
    dbValue: '3_wheeler',
    displayName: 'Auto Rickshaw (3-Wheeler)',
    description: 'Passenger/Cargo Auto Rickshaw, E-Rickshaw',
    eligibleServices: 'Parcel Delivery Only',
    icon: Icons.electric_moped_rounded,
  ),
  BackendVehicleInfo(
    dbValue: 'car_normal',
    displayName: 'Normal Car (Hatchback/Sedan)',
    description: 'Alto, WagonR, Swift, Dzire, Etios, i20, Celerio',
    eligibleServices: 'Ride Booking Only',
    icon: Icons.directions_car_rounded,
  ),
  BackendVehicleInfo(
    dbValue: 'car-premium(fast)',
    displayName: 'Premium Car (AC Sedan)',
    description: 'Ciaz, Honda City, Verna, Rapid, Slavia',
    eligibleServices: 'Ride Booking Only',
    icon: Icons.speed_rounded,
  ),
  BackendVehicleInfo(
    dbValue: 'car_xl',
    displayName: 'XL Car (SUV/6-Seater)',
    description: 'Ertiga, Carens, Triber, Mobilio, BR-V',
    eligibleServices: 'Ride Booking Only',
    icon: Icons.local_taxi_rounded,
  ),
  BackendVehicleInfo(
    dbValue: 'car_xl_premium',
    displayName: 'Premium XL Car (Luxury SUV)',
    description: 'Innova Crysta, Innova Hycross, XUV700, Fortuner',
    eligibleServices: 'Ride Booking Only',
    icon: Icons.airport_shuttle_rounded,
  ),
  BackendVehicleInfo(
    dbValue: 'mini_truck',
    displayName: 'Mini Truck',
    description: 'Tata Ace (Chota Hathi), Mahindra Supro, Bolero Pik-up',
    eligibleServices: 'Parcel Delivery Only',
    icon: Icons.local_shipping_outlined,
  ),
  BackendVehicleInfo(
    dbValue: 'truck',
    displayName: 'Heavy Truck',
    description: 'Large Eicher, Tata Truck, Container Truck, Lorry',
    eligibleServices: 'Parcel Delivery Only',
    icon: Icons.local_shipping_rounded,
  ),
];
