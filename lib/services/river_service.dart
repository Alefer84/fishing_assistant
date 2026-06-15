import 'package:shared_preferences/shared_preferences.dart';

import '../models/river.dart';

/// Provides the supported rivers and persists the user's favorites.
class RiverService {
  static const _favoritesKey = 'favorite_river_ids';

  /// Phase 1 supports a curated set of Polish rivers (see guideline).
  static const List<River> rivers = [
    River(
      id: 'san',
      name: 'San',
      country: 'Poland',
      latitude: 49.3700,
      longitude: 22.3500,
      gaugeId: 'imgw-san',
    ),
    River(
      id: 'dunajec',
      name: 'Dunajec',
      country: 'Poland',
      latitude: 49.4200,
      longitude: 20.4200,
      gaugeId: 'imgw-dunajec',
    ),
    River(
      id: 'wisla',
      name: 'Wisła',
      country: 'Poland',
      latitude: 50.0600,
      longitude: 19.9400,
      gaugeId: 'imgw-wisla',
    ),
    River(
      id: 'bobr',
      name: 'Bóbr',
      country: 'Poland',
      latitude: 50.9000,
      longitude: 15.7300,
      gaugeId: 'imgw-bobr',
    ),
  ];

  River riverById(String id) =>
      rivers.firstWhere((r) => r.id == id, orElse: () => rivers.first);

  List<River> search(String query) {
    if (query.trim().isEmpty) return rivers;
    final q = query.toLowerCase();
    return rivers
        .where(
          (r) =>
              r.name.toLowerCase().contains(q) ||
              r.country.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<Set<String>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getStringList(_favoritesKey) ?? const []).toSet();
  }

  Future<void> toggleFavorite(String riverId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = (prefs.getStringList(_favoritesKey) ?? <String>[])
        .toSet();
    if (!favorites.add(riverId)) {
      favorites.remove(riverId);
    }
    await prefs.setStringList(_favoritesKey, favorites.toList());
  }
}
