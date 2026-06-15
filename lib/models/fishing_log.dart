class FishingLog {
  final String id;
  final String riverId;
  final String riverName;
  final DateTime date;
  final String? weather;
  final double? waterLevel;
  final String? flyUsed;
  final String? fishSpecies;
  final int fishCaught;
  final double? fishLengthCm;
  final String? notes;

  /// Lunar context captured at logging time for later analysis.
  final String? moonPhase;
  final double? moonIllumination;

  /// Identifiers of photos stored locally for this entry.
  final List<String> photoIds;

  const FishingLog({
    required this.id,
    required this.riverId,
    required this.riverName,
    required this.date,
    this.weather,
    this.waterLevel,
    this.flyUsed,
    this.fishSpecies,
    this.fishCaught = 0,
    this.fishLengthCm,
    this.notes,
    this.moonPhase,
    this.moonIllumination,
    this.photoIds = const [],
  });

  factory FishingLog.fromJson(Map<String, dynamic> json) => FishingLog(
    id: json['id'] as String,
    riverId: json['river_id'] as String,
    riverName: json['river_name'] as String? ?? '',
    date: DateTime.parse(json['date'] as String),
    weather: json['weather'] as String?,
    waterLevel: (json['water_level'] as num?)?.toDouble(),
    flyUsed: json['fly_used'] as String?,
    fishSpecies: json['fish_species'] as String?,
    fishCaught: (json['fish_caught'] as num?)?.toInt() ?? 0,
    fishLengthCm: (json['fish_length'] as num?)?.toDouble(),
    notes: json['notes'] as String?,
    moonPhase: json['moon_phase'] as String?,
    moonIllumination: (json['moon_illumination'] as num?)?.toDouble(),
    photoIds:
        (json['photo_ids'] as List<dynamic>?)
            ?.map((e) => e as String)
            .toList() ??
        const [],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'river_id': riverId,
    'river_name': riverName,
    'date': date.toIso8601String(),
    'weather': weather,
    'water_level': waterLevel,
    'fly_used': flyUsed,
    'fish_species': fishSpecies,
    'fish_caught': fishCaught,
    'fish_length': fishLengthCm,
    'notes': notes,
    'moon_phase': moonPhase,
    'moon_illumination': moonIllumination,
    'photo_ids': photoIds,
  };
}
