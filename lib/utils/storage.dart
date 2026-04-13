import 'package:flutter/foundation.dart';

/// Returns a [FlutterSecureStorage] key namespaced by build mode.
///
/// In debug builds the key is prefixed with `'dev_'` so debug and release builds never share credentials, even when running on the same machine.
String secureKey(String key) => kDebugMode ? 'dev_$key' : key;
