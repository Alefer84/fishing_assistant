import '../models/hatch.dart';

/// Static regional hatch chart for the supported rivers.
///
/// This is the dataset the guideline calls the app's "competitive advantage".
/// Phase 1 ships a curated chart; later phases can layer user-submitted
/// observations and a prediction model on top.
class HatchService {
  const HatchService();

  /// Base hatch chart applied to every supported river. Months are 1-12.
  static const List<_HatchTemplate> _chart = [
    _HatchTemplate('Blue Wing Olive', HatchStage.emerger, [3, 4, 5, 9, 10, 11],
        HatchProbability.high, ['BWO Emerger #18', 'CDC Dun #18']),
    _HatchTemplate('March Brown', HatchStage.adult, [3, 4, 5],
        HatchProbability.medium, ['March Brown Dun #12', 'Pheasant Tail #14']),
    _HatchTemplate('Grannom Caddis', HatchStage.adult, [4, 5],
        HatchProbability.high, ['Elk Hair Caddis #14', 'Grannom Pupa #14']),
    _HatchTemplate('Sulphur', HatchStage.emerger, [5, 6, 7],
        HatchProbability.high, ['Sulphur Comparadun #16', 'PT Emerger #16']),
    _HatchTemplate('Green Drake (Mayfly)', HatchStage.adult, [5, 6],
        HatchProbability.medium, ['Green Drake #10', 'Mayfly Spinner #10']),
    _HatchTemplate('Caddis', HatchStage.larva, [5, 6, 7, 8],
        HatchProbability.high, ['Elk Hair Caddis #14', 'Caddis Larva #14']),
    _HatchTemplate('Pale Morning Dun', HatchStage.adult, [6, 7],
        HatchProbability.medium, ['PMD Dun #16', 'Pheasant Tail #16']),
    _HatchTemplate('Trico', HatchStage.spinner, [7, 8, 9],
        HatchProbability.medium, ['Trico Spinner #20', 'Trico Dun #20']),
    _HatchTemplate('Terrestrials (Ants/Beetles)', HatchStage.adult, [7, 8, 9],
        HatchProbability.high, ['Foam Ant #16', 'Foam Beetle #14']),
    _HatchTemplate('Midge', HatchStage.larva, [1, 2, 3, 11, 12],
        HatchProbability.medium, ['Zebra Midge #20', 'Griffiths Gnat #20']),
  ];

  List<Hatch> hatchesFor(String riverId) => _chart
      .map((t) => Hatch(
            riverId: riverId,
            species: t.species,
            stage: t.stage,
            months: t.months,
            probability: t.probability,
            recommendedFlies: t.flies,
          ))
      .toList();

  List<Hatch> activeHatches(String riverId, int month) =>
      hatchesFor(riverId).where((h) => h.isActiveIn(month)).toList();

  /// Recommended flies aggregated across active hatches (deduplicated).
  List<String> recommendedFlies(String riverId, int month) {
    final flies = <String>{};
    for (final h in activeHatches(riverId, month)) {
      flies.addAll(h.recommendedFlies);
    }
    return flies.take(4).toList();
  }
}

class _HatchTemplate {
  final String species;
  final HatchStage stage;
  final List<int> months;
  final HatchProbability probability;
  final List<String> flies;

  const _HatchTemplate(
      this.species, this.stage, this.months, this.probability, this.flies);
}
