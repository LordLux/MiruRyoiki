import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class RegistryUtils {
  /// Opens a registry key with the specified path
  static int openKey(int hKey, String subKey, {bool readOnly = true}) {
    final keyPath = subKey.toNativeUtf16();
    final phkResult = calloc<HKEY>();

    try {
      final result = readOnly
          ? RegOpenKeyEx(hKey, keyPath, 0, KEY_READ, phkResult)
          : RegOpenKeyEx(hKey, keyPath, 0, KEY_READ | KEY_WRITE, phkResult);

      if (result != ERROR_SUCCESS) {
        throw WindowsException(result);
      }
      return phkResult.value;
    } finally {
      free(keyPath);
      free(phkResult);
    }
  }

  /// Enumerates subkeys of the given registry key
  static List<String> enumSubKeys(int hKey) {
    final subKeys = <String>[];
    var index = 0;
    final nameBuffer = calloc<Uint16>(256).cast<Utf16>();
    final nameLength = calloc<DWORD>();

    try {
      while (true) {
        nameLength.value = 256;
        final result =
            RegEnumKeyEx(hKey, index, nameBuffer, nameLength, nullptr, nullptr, nullptr, nullptr);

        if (result == ERROR_NO_MORE_ITEMS) break;
        if (result != ERROR_SUCCESS) {
          throw WindowsException(result);
        }

        subKeys.add(nameBuffer.toDartString());
        index++;
      }
      return subKeys;
    } finally {
      free(nameBuffer);
      free(nameLength);
    }
  }

  /// Gets a string value from a registry key
  static String? getStringValue(int hKey, String valueName) {
    final nameBuffer = valueName.toNativeUtf16();
    final dataSize = calloc<DWORD>();
    
    try {
      // First get the size of the data
      var result = RegQueryValueEx(
          hKey, nameBuffer, nullptr, nullptr, nullptr, dataSize);

      if (result == ERROR_FILE_NOT_FOUND) return null;

      if (result != ERROR_SUCCESS) {
        throw WindowsException(result);
      }

      final dataBuffer = calloc<Uint16>(dataSize.value ~/ 2 + 1).cast<Utf16>();

      try {
        final valueType = calloc<DWORD>();
        try {
          result = RegQueryValueEx(
              hKey, nameBuffer, nullptr, valueType, dataBuffer.cast(), dataSize);

          if (result != ERROR_SUCCESS) {
            throw WindowsException(result);
          }

          if (valueType.value != REG_SZ && valueType.value != REG_EXPAND_SZ) {
            return null;
          }

          return dataBuffer.toDartString();
        } finally {
          free(valueType);
        }
      } finally {
        free(dataBuffer);
      }
    } finally {
      free(nameBuffer);
      free(dataSize);
    }
  }

  /// Gets a DWORD value from a registry key
  static int? getDwordValue(int hKey, String valueName) {
    final nameBuffer = valueName.toNativeUtf16();
    final dataSize = calloc<DWORD>();
    dataSize.value = sizeOf<DWORD>();
    
    final data = calloc<DWORD>();
    final valueType = calloc<DWORD>();
    
    try {
      final result = RegQueryValueEx(
          hKey, nameBuffer, nullptr, valueType, data.cast(), dataSize);

      if (result == ERROR_FILE_NOT_FOUND) return null;

      if (result != ERROR_SUCCESS) {
        throw WindowsException(result);
      }

      if (valueType.value != REG_DWORD) {
        return null;
      }

      return data.value;
    } finally {
      free(nameBuffer);
      free(dataSize);
      free(data);
      free(valueType);
    }
  }
  
  /// Close a registry key handle
  static void closeKey(int hKey) {
    RegCloseKey(hKey);
  }
}