class Provider {
  final String id;
  final String name;
  final String service;
  final bool available;
  final String area;
  final double rating;
  final double distanceKm;
  final double score; // from ranking
  final String reasoning; // from ranking

  Provider({
    required this.id,
    required this.name,
    required this.service,
    required this.available,
    required this.area,
    required this.rating,
    required this.distanceKm,
    this.score = 0.0,
    this.reasoning = '',
  });

  factory Provider.fromJson(Map<String, dynamic> json) {
    return Provider(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      service: json['service'] ?? '',
      available: json['available'] ?? false,
      area: json['area'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      distanceKm: (json['distance_km'] ?? 0.0).toDouble(),
      score: (json['score'] ?? 0.0).toDouble(),
      reasoning: json['reasoning'] ?? '',
    );
  }
}
