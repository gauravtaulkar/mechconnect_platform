class Mechanic {
  final int id;
  final String name;
  final String shopName;
  final String city;
  final String street;
  final double latitude;
  final double longitude;
  final String phone;
  final int experience;
  final String expertise;
  final bool available;
  final String openingTime;
  final String closingTime;

  Mechanic({
    required this.id,
    required this.name,
    required this.shopName,
    required this.city,
    required this.street,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.experience,
    required this.expertise,
    required this.available,
    required this.openingTime,
    required this.closingTime,
  });

  factory Mechanic.fromJson(Map<String, dynamic> json) {
    return Mechanic(
      id: json['id'],
      name: json['name'] ?? '',
      shopName: json['shopName'] ?? '',
      city: json['city'] ?? '',
      street: json['street'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      phone: json['phone'] ?? '',
      experience: json['experience'] ?? 0,
      expertise: json['expertise'] ?? '',
      available: json['available'] ?? false,
      openingTime: json['openingTime']?.toString() ?? '09:00:00',
      closingTime: json['closingTime']?.toString() ?? '18:00:00',
    );
  }
}
