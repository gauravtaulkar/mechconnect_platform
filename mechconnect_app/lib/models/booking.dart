class Booking {
  final int id;
  final int mechanicId;
  final String customerName;
  final String customerPhone;
  final String bikeModel;
  final String bookingTime;
  final String problemDescription;
  final String status;

  Booking({
    required this.id,
    required this.mechanicId,
    required this.customerName,
    required this.customerPhone,
    required this.bikeModel,
    required this.bookingTime,
    required this.problemDescription,
    required this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'],
      mechanicId: json['mechanicId'] ?? 0,
      customerName: json['customerName'] ?? '',
      customerPhone: json['customerPhone'] ?? '',
      bikeModel: json['bikeModel'] ?? '',
      bookingTime: json['bookingTime']?.toString() ?? '',
      problemDescription: json['problemDescription'] ?? '',
      status: json['status'] ?? 'PENDING',
    );
  }
}
