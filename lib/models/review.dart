import '../utils/json_parsing.dart';

class ReviewItem {
  final String id;
  final int rating;
  final String? comment;
  final String userName;
  final DateTime? createdAt;

  ReviewItem({
    required this.id,
    required this.rating,
    required this.userName,
    this.comment,
    this.createdAt,
  });

  factory ReviewItem.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return ReviewItem(
      id: json['id'].toString(),
      rating: parseJsonInt(json['rating']),
      comment: json['comment']?.toString(),
      userName: user is Map
          ? (user['name'] ?? 'Anonymous').toString()
          : 'Anonymous',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}
