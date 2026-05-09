import 'package:fluent_ui/fluent_ui.dart';

import 'navigation.dart';

// Intent definitions
class OpenSettingsIntent extends Intent {
  const OpenSettingsIntent();
}

class OpenSearchIntent extends Intent {
  const OpenSearchIntent();
}

class ZoomInIntent extends Intent {
  const ZoomInIntent();
}

class ZoomOutIntent extends Intent {
  const ZoomOutIntent();
}

class ToggleHiddenSeriesIntent extends Intent {
  const ToggleHiddenSeriesIntent();
}

class ReloadLibraryIntent extends Intent {
  const ReloadLibraryIntent();
}

class ClearCacheReloadIntent extends Intent {
  const ClearCacheReloadIntent();
}

class BackNavigationIntent extends Intent {
  const BackNavigationIntent();
}

class DebugDialogIntent extends Intent {
  const DebugDialogIntent();
}

class ToggleDebugColorIntent extends Intent {
  const ToggleDebugColorIntent();
}

class GoToPaneIntent extends Intent {
  const GoToPaneIntent(this.pane);
  final PaneDefinition pane;
}
