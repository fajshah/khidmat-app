class Booking {
  final String bookingId;
  final String providerId;
  final String providerName;
  final String service;
  final String slot;
  final String userName;
  final String status;
  final String reminder;
  final String confirmationMessage;

  Booking({
    required this.bookingId,
    required this.providerId,
    required this.providerName,
    required this.service,
    required this.slot,
    required this.userName,
    required this.status,
    required this.reminder,
    required this.confirmationMessage,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      bookingId: json['booking_id'] ?? '',
      providerId: json['provider_id'] ?? '',
      providerName: json['provider_name'] ?? '',
      service: json['service'] ?? '',
      slot: json['slot'] ?? '',
      userName: json['user_name'] ?? '',
      status: json['status'] ?? '',
      reminder: json['reminder'] ?? '',
      confirmationMessage: json['confirmation_message'] ?? '',
    );
  }
}
