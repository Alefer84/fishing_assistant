class River {
  final String id;
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  /// Identifier for the hydrological gauge feeding water readings.
  final String? gaugeId;

  const River({
    required this.id,
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.gaugeId,
  });

  factory River.fromJson(Map<String, dynamic> json) => River(
    id: json['id'] as String,
    name: json['name'] as String,
    country: json['country'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    gaugeId: json['gauge_id'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'country': country,
    'latitude': latitude,
    'longitude': longitude,
    'gauge_id': gaugeId,
  };
}
