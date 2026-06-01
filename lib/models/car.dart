import 'app_user.dart';
import '../utils/json_parsing.dart';

class Car {
  final String id;
  final String userId;
  final String brand;
  final String model;
  final int year;
  final String transmission;
  final String fuelType;
  final int seats;
  final double pricePerDay;
  final String status;
  final String? image;
  final List<String> images;
  final double averageRating;
  final int reviewsCount;
  final AppUser? owner;

  Car({
    required this.id,
    required this.userId,
    required this.brand,
    required this.model,
    required this.year,
    required this.transmission,
    required this.fuelType,
    required this.seats,
    required this.pricePerDay,
    required this.status,
    required this.averageRating,
    required this.reviewsCount,
    this.image,
    this.images = const [],
    this.owner,
  });

  factory Car.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'];
    return Car(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      brand: (json['brand'] ?? '').toString(),
      model: (json['model'] ?? '').toString(),
      year: parseJsonInt(json['year']),
      transmission: (json['transmission'] ?? '').toString(),
      fuelType: (json['fuel_type'] ?? '').toString(),
      seats: parseJsonInt(json['seats']),
      pricePerDay: parseJsonDouble(json['price_per_day']),
      status: (json['status'] ?? '').toString(),
      image: json['image']?.toString(),
      images: rawImages is List
          ? rawImages.map((e) => e.toString()).toList()
          : const [],
      averageRating: parseJsonDouble(json['average_rating']),
      reviewsCount: parseJsonInt(json['reviews_count']),
      owner: json['owner'] is Map<String, dynamic>
          ? AppUser.fromJson(json['owner'] as Map<String, dynamic>)
          : null,
    );
  }
}
