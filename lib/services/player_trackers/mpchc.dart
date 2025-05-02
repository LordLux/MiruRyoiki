import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

import '../../utils/registry_utils.dart';
import '../../models/episode.dart';

class MPCHCTracker with ChangeNotifier {
  static const String _mpcHcRegPath = r'SOFTWARE\MPC-HC\MPC-HC\MediaHistory';
  
  // Maps file paths to their registry keys
  final Map<String, String> _fileToKeyMap = {};
  
  // Maps registry keys to their FilePosition value (percentage watched)
  final Map<String, double> _keyToPositionMap = {};
  
  // Timer for periodic checking
  Timer? _checkTimer;
  
  // Flag to indicate if tracker is initialized
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Constructor
  MPCHCTracker() {
    // Initial scan of registry
    indexRegistry();
    
    // Set up periodic checking every 2 minutes
    _checkTimer = Timer.periodic(const Duration(minutes: 2), (_) {
      checkForUpdates();
    });
  }
  
  @override
  void dispose() {
    _checkTimer?.cancel();
    super.dispose();
  }

  /// Initialize the tracker by scanning the registry
  Future<void> indexRegistry() async {
    try {
      _fileToKeyMap.clear();
      _keyToPositionMap.clear();
      
      // Open the MPC-HC MediaHistory key
      final hMediaHistory = RegistryUtils.openKey(HKEY_CURRENT_USER, _mpcHcRegPath);
      
      if (hMediaHistory == 0) {
        debugPrint('Failed to open MPC-HC MediaHistory registry key');
        return;
      }

      try {
        // Get all subkeys (these are the random keys for each file)
        final subKeys = RegistryUtils.enumSubKeys(hMediaHistory);
        
        for (final subKey in subKeys) {
          final hFileKey = RegistryUtils.openKey(hMediaHistory, subKey);
          
          if (hFileKey != 0) {
            try {
              // Get the filename this key is associated with
              final filename = RegistryUtils.getStringValue(hFileKey, 'Filename');
              
              if (filename != null && filename.isNotEmpty) {
                // Get the file position (as percentage of total)
                final position = RegistryUtils.getDwordValue(hFileKey, 'FilePosition') ?? 0;
                final durationValue = RegistryUtils.getDwordValue(hFileKey, 'FileDuration') ?? 1;
                
                // Avoid division by zero
                final percentage = durationValue > 0 
                    ? (position / durationValue).clamp(0.0, 1.0)
                    : 0.0;
                
                // Map the file to its registry key and track position
                _fileToKeyMap[filename] = subKey;
                _keyToPositionMap[subKey] = percentage;
                
                debugPrint('Indexed: $filename -> $subKey (${(percentage * 100).toStringAsFixed(1)}%)');
              }
            } finally {
              RegistryUtils.closeKey(hFileKey);
            }
          }
        }
        
        _isInitialized = true;
        notifyListeners();
      } finally {
        RegistryUtils.closeKey(hMediaHistory);
      }
    } catch (e) {
      debugPrint('Error indexing MPC-HC registry: $e');
    }
  }

  /// Check for updates in the registry and identify completed videos
  Future<List<String>> checkForUpdates() async {
    if (!_isInitialized) {
      await indexRegistry();
    }
    
    final watchedFiles = <String>[];
    
    try {
      final hMediaHistory = RegistryUtils.openKey(HKEY_CURRENT_USER, _mpcHcRegPath);
      
      if (hMediaHistory == 0) {
        return watchedFiles;
      }

      try {
        // Get updated subkeys
        final subKeys = RegistryUtils.enumSubKeys(hMediaHistory);
        
        // Check for new entries
        for (final subKey in subKeys) {
          // If this is a key we haven't seen before
          if (!_keyToPositionMap.containsKey(subKey)) {
            final hFileKey = RegistryUtils.openKey(hMediaHistory, subKey);
            
            if (hFileKey != 0) {
              try {
                final filename = RegistryUtils.getStringValue(hFileKey, 'Filename');
                
                if (filename != null && filename.isNotEmpty) {
                  // Add to our maps
                  _fileToKeyMap[filename] = subKey;
                  
                  // Get the current position
                  final position = RegistryUtils.getDwordValue(hFileKey, 'FilePosition') ?? 0;
                  final durationValue = RegistryUtils.getDwordValue(hFileKey, 'FileDuration') ?? 1;
                  
                  final percentage = durationValue > 0 
                      ? (position / durationValue).clamp(0.0, 1.0)
                      : 0.0;
                  
                  _keyToPositionMap[subKey] = percentage;
                  
                  // If the file is watched more than 85%
                  if (percentage >= 0.85) {
                    watchedFiles.add(filename);
                  }
                }
              } finally {
                RegistryUtils.closeKey(hFileKey);
              }
            }
          } else {
            // Check if an existing key has been updated
            final hFileKey = RegistryUtils.openKey(hMediaHistory, subKey);
            
            if (hFileKey != 0) {
              try {
                final position = RegistryUtils.getDwordValue(hFileKey, 'FilePosition') ?? 0;
                final durationValue = RegistryUtils.getDwordValue(hFileKey, 'FileDuration') ?? 1;
                
                final percentage = durationValue > 0 
                    ? (position / durationValue).clamp(0.0, 1.0)
                    : 0.0;
                
                final previousPercentage = _keyToPositionMap[subKey] ?? 0.0;
                
                // Update the stored percentage
                _keyToPositionMap[subKey] = percentage;
                
                // If it crossed the 85% threshold
                if (percentage >= 0.85 && previousPercentage < 0.85) {
                  // Find the filename for this key
                  final filename = _fileToKeyMap.entries
                      .firstWhere((entry) => entry.value == subKey, 
                          orElse: () => const MapEntry('', ''))
                      .key;
                  
                  if (filename.isNotEmpty) {
                    watchedFiles.add(filename);
                  }
                }
              } finally {
                RegistryUtils.closeKey(hFileKey);
              }
            }
          }
        }
      } finally {
        RegistryUtils.closeKey(hMediaHistory);
      }
    } catch (e) {
      debugPrint('Error checking MPC-HC registry updates: $e');
    }
    
    if (watchedFiles.isNotEmpty) {
      notifyListeners();
    }
    
    return watchedFiles;
  }

  /// Check if a specific file has been watched (85% or more)
  bool isWatched(String filePath) {
    final normalizedPath = filePath.replaceAll('/', '\\');
    final key = _fileToKeyMap[normalizedPath];
    
    if (key == null) return false;
    
    final percentage = _keyToPositionMap[key] ?? 0.0;
    return percentage >= 0.85;
  }

  /// Get the watch percentage for a file
  double getWatchPercentage(String filePath) {
    final normalizedPath = filePath.replaceAll('/', '\\');
    final key = _fileToKeyMap[normalizedPath];
    
    if (key == null) return 0.0;
    
    return _keyToPositionMap[key] ?? 0.0;
  }
}