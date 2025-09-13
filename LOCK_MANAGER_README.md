# Operation Lock Manager Implementation

## Overview

This implementation adds a comprehensive locking mechanism to prevent concurrent operations that could corrupt data or cause conflicts between UI actions and background processes. The system automatically disables user actions during critical operations like library scanning, dominant color calculation, and database saves.

## Key Components

### 1. LockManager (`lib/services/lock_manager.dart`)

The central coordinator that manages operation locks and provides methods to check if actions should be disabled.

**Features:**

- **Operation Types**: Different types of operations can be locked independently or exclusively
- **User Action Validation**: Checks if specific user actions should be disabled
- **Progress Tracking**: Tracks active operations with descriptions
- **Waiting Queue**: Operations can wait for others to complete

**Operation Types:**

- `libraryScanning` - When scanning the library for new/changed files
- `dominantColorCalculation` - When calculating dominant colors in batch
- `seriesSorting` - When sorting large datasets in isolates  
- `fileProcessing` - When processing file metadata in isolates
- `databaseSave` - When saving to the database
- `anilistBatchOperations` - When performing batch AniList operations
- `seriesUpdate` - When updating series information

**User Actions:**

- `markEpisodeWatched` - Marking episodes as watched/unwatched
- `markSeriesWatched` - Marking entire series as watched/unwatched
- `updateSeriesInfo` - Updating series metadata
- `scanLibrary` - Manual library scanning
- `calculateDominantColors` - Manual dominant color calculation
- `anilistOperations` - AniList-related operations
- `seriesImageSelection` - Changing poster/banner images

### 2. Operation Status Widgets (`lib/widgets/operation_status.dart`)

UI components that automatically disable themselves during relevant operations.

**Components:**

- `OperationStatusListener` - Wraps the main app to show operation status
- `OperationAwareButton` - Generic button that disables during operations
- `ScanLibraryButton` - Specialized for library scan operations
- `DominantColorButton` - Specialized for color calculation operations
- `WatchStatusButton` - Specialized for watch status changes
- `AnilistButton` - Specialized for AniList operations

### 3. Integration Points

**Library Operations:**

- Library scanning now requires an exclusive lock
- File processing in isolates uses a processing lock
- Database saves use a dedicated save lock
- Dominant color calculation uses its own lock

**User Actions:**

- Episode context menus check locks before allowing watch status changes
- Series context menus check locks before bulk operations
- All database update operations check for active critical operations

## Usage Examples

### Acquiring a Lock

```dart
// Acquire an exclusive lock for library scanning
final lockHandle = await lockManager.acquireLock(
  OperationType.libraryScanning,
  description: 'scanning library',
  exclusive: true,
  waitForOthers: false,
);

if (lockHandle == null) {
  // Operation is already in progress
  return;
}

try {
  // Perform the operation
  await scanLibrary();
} finally {
  // Always dispose the lock
  lockHandle.dispose();
}
```

### Checking if Actions Should be Disabled

```dart
// Check if user actions should be disabled
if (lockManager.shouldDisableUserActions()) {
  snackBar(
    'Please wait for the current operation to complete',
    severity: InfoBarSeverity.warning,
  );
  return;
}

// Check specific action
if (lockManager.shouldDisableAction(UserAction.markEpisodeWatched)) {
  snackBar(
    lockManager.getDisabledReason(UserAction.markEpisodeWatched),
    severity: InfoBarSeverity.warning,
  );
  return;
}
```

### Using Operation-Aware Widgets

```dart
// Generic operation-aware button
OperationAwareButton(
  userAction: UserAction.scanLibrary,
  onPressed: onPressed,
  child: Text('Scan Library'),
)

// Specialized button
ScanLibraryButton(
  onPressed: () => library.scanLocalLibrary(),
  child: Text('Scan Library'),
)
```

## Implementation Details

### Lock Types

1. **Exclusive Locks**: Wait for all other operations to complete before proceeding
2. **Operation-Specific Locks**: Only prevent the same type of operation
3. **Waiting Locks**: Queue up and wait for the specific operation to complete
4. **Non-Waiting Locks**: Return null immediately if conflicted

### Critical Operations

These operations disable most user actions:

- Library scanning
- Database saves
- File processing

### User Action Protection

The system protects against these potential conflicts:

1. **During Library Scanning**:
   - Prevents manual episode/series updates
   - Prevents additional scan requests
   - Prevents image preference changes

2. **During Dominant Color Calculation**:
   - Prevents duplicate color calculations
   - Allows other operations to continue

3. **During Database Operations**:
   - Prevents concurrent write operations
   - Ensures data consistency

4. **During AniList Batch Operations**:
   - Prevents conflicting AniList requests
   - Maintains rate limiting

## Benefits

1. **Data Integrity**: Prevents corruption from concurrent database operations
2. **User Experience**: Clear feedback when operations are unavailable
3. **Performance**: Prevents resource conflicts from multiple heavy operations
4. **Reliability**: Eliminates race conditions and inconsistent state

## Testing

The implementation includes comprehensive error handling and provides clear user feedback when operations are blocked. The lock manager is a singleton that can be accessed throughout the application to check operation status.

## Future Enhancements

- Progress indicators for long-running operations
- Priority-based operation queuing
- Configurable operation timeouts
- Operation cancellation support
