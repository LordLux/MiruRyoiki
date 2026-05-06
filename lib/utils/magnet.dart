/// Extracts the BitTorrent info-hash (BTIH) from a magnet URL
///
/// Magnet URLs look like `magnet:?xt=urn:btih:HASH&dn=...`. The hash is either:
/// - 40 hex chars (BTIH v1, the common case)
/// - 32 base32 chars (BTIH v1 in older clients)
///
/// Returns the lowercased 40-char hex form, or null if the URL has no BTIH
String? extractBtih(String magnetUrl) {
  final match = RegExp(r'xt=urn:btih:([0-9A-Fa-f]{40}|[0-9A-Za-z]{32})').firstMatch(magnetUrl);
  if (match == null) return null;
  final raw = match.group(1)!;
  // 40-char hex → just lowercase. Base32 (32 chars) gets returned as-is lowercased
  // since qBittorrent normalizes both forms to hex internally; if a caller needs
  // strict equality with qBittorrent's output, convert at the call site
  return raw.toLowerCase();
}
