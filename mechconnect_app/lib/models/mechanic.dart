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
      name: json['name'],
      shopName: json['shopName'],
      city: json['city'],
      street: json['street'],
      latitude: json['latitude'],
      longitude: json['longitude'],
      phone: json['phone'],
      experience: json['experience'],
      expertise: json['expertise'],
      available: json['available'],
      openingTime: json['openingTime'],
      closingTime: json['closingTime'],
    );
  }
}