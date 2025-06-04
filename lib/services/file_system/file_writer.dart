import 'dart:convert';
import 'package:crypto/crypto.dart';

/// Generates a short hash based on the SHA-1 algorithm.
/// The hash is encoded in Base64 and truncated to 12 characters.
/// If hashing fails, it falls back to using the last 30 characters of the input, replacing backslashes with forward slashes.
String getRfeHash(String path) {
  // 1. Lower-case the path
  final lower = path.toLowerCase();
  // 2. Build UTF-16LE bytes from code units
  final codeUnits = lower.codeUnits; // Dart codeUnits are UTF-16
  final bytes = <int>[];
  for (var cu in codeUnits) {
    bytes.add(cu & 0xFF);
    bytes.add((cu >> 8) & 0xFF);
  }
  // 3. SHA-1 digest
  final digest = sha1.convert(bytes).bytes;
  // 4. Base64 encode and take first 12 chars
  final b64 = base64.encode(digest);
  return b64.substring(0, 12);
}