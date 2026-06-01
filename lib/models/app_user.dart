class AppUser {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? idImageUrl;

  AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.idImageUrl,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'].toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'customer').toString(),
      phone: json['phone']?.toString(),
      idImageUrl: json['id_image_url']?.toString(),
    );
  }
}
