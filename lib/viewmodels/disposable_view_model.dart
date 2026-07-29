import 'package:flutter/foundation.dart';

/// Shared [ChangeNotifier] base for MiruRyoiki ViewModels.
///
/// Tracks disposal and exposes [notifySafe], so in-flight async work that resolves
/// after the VM was disposed can't call notifyListeners() on an already-disposed notifier.
abstract class DisposableViewModel extends ChangeNotifier {
  bool _isDisposed = false;

  /// Whether [dispose] has run
  /// 
  /// Async methods should check this after an await before touching state or notifying
  @protected
  bool get isDisposed => _isDisposed;

  @override
  @mustCallSuper
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  /// Calls [notifyListeners] unless this VM has already been disposed
  @protected
  void notifySafe() {
    if (!_isDisposed) notifyListeners();
  }
}
