import 'services/isolates/isolate_manager.dart';

/// Simple test function to verify isolate functionality
Future<Map<String, dynamic>> simpleIsolateTest(Map<String, dynamic> input) async {
  // Just echo back the input with a small modification
  return {
    'result': 'Processed in isolate',
    'input': input,
    'timestamp': DateTime.now().toIso8601String(),
  };
}

/// Function to run the test isolate
Future<String> testIsolateSystem() async {
  final isolateManager = IsolateManager();

  try {
    // Create a simple test payload
    final testPayload = {
      'test': 'This is a test',
      'value': 42,
    };

    // Run the test in the isolate
    final result = await isolateManager.runIsolateWithProgress(
      task: simpleIsolateTest,
      params: testPayload,
      onProgress: (processed, total) => print('Progress: $processed / $total'),
    );

    // Return a simple success message
    return "Isolate test successful! Result: ${result['result']}";
  } catch (e, stack) {
    return "Isolate test failed: $e\n$stack";
  }
}

Future<void> onTestIsolatePressed() async {
  final result = await testIsolateSystem();
  print(result);
}