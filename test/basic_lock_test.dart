import 'package:flutter_test/flutter_test.dart';
import 'package:miruryoiki/services/lock_manager.dart';

void main() {
  test('Basic lock manager test', () async {
    final lockManager = LockManager();
    
    print('Testing basic functionality...');
    
    final handle = await lockManager.acquireLock(
      OperationType.databaseSave,
      description: 'test',
      waitForOthers: true,
    );
    
    print('Handle: ${handle != null ? "SUCCESS" : "NULL"}');
    
    if (handle != null) {
      handle.dispose();
      print('Disposed successfully');
    }
    
    expect(handle, isNotNull);
  });
}
