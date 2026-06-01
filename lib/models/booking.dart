class BookingItem {
  final String id;
  final String userId;
  final String carId;
  final DateTime? startDate;
  final DateTime? endDate;
  final double totalPrice;
  final String status;
  final String? carBrand;
  final String? carModel;
  final String? carImage;

  BookingItem({
    required this.id,
    required this.userId,
    required this.carId,
    required this.totalPrice,
    required this.status,
    this.startDate,
    this.endDate,
    this.carBrand,
    this.carModel,
    this.carImage,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    final car = json['car'];
    return BookingItem(
      id: json['id'].toString(),
      userId: json['user_id'].toString(),
      carId: json['car_id'].toString(),
      startDate: json['start_date'] == null
          ? null
          : DateTime.tryParse(json['start_date'].toString()),
      endDate: json['end_date'] == null
          ? null
          : DateTime.tryParse(json['end_date'].toString()),
      totalPrice: (json['total_price'] is num)
          ? (json['total_price'] as num).toDouble()
          : double.tryParse(json['total_price']?.toString() ?? '0') ?? 0,
      status: (json['status'] ?? '').toString(),
      carBrand: car is Map ? car['brand']?.toString() : null,
      carModel: car is Map ? car['model']?.toString() : null,
      carImage: car is Map ? car['image']?.toString() : null,
    );
  }
}
