/// Maps a recommended fly name to a representative tied-fly image asset.
///
/// The recommendations are specific patterns (e.g. "Elk Hair Caddis #14"); we
/// group them by fly type and show a representative photo. Images are bundled
/// assets sourced from Wikimedia Commons — see `assets/flies/CREDITS.md`.
String flyImageAsset(String flyName) {
  final name = flyName.toLowerCase();

  bool has(String s) => name.contains(s);

  // Order matters: more specific keywords first.
  if (has('larva') || has('pupa') || has('prince')) {
    return 'assets/flies/bead_nymph.jpg';
  }
  if (has('midge') || has('gnat') || has('buzzer')) {
    return 'assets/flies/midge.jpg';
  }
  if (has('spinner')) return 'assets/flies/spinner.jpg';
  if (has('caddis')) return 'assets/flies/caddis.jpg';
  if (has('nymph') ||
      has('emerger') ||
      has('pheasant tail') ||
      name.startsWith('pt ')) {
    return 'assets/flies/nymph.jpg';
  }
  if (has('bugger') || has('streamer') || has('woolly')) {
    return 'assets/flies/streamer.jpg';
  }
  // Duns, comparaduns, drakes, terrestrials and anything else: a dry fly.
  return 'assets/flies/dry_mayfly.jpg';
}
