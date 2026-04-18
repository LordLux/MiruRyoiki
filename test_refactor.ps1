(Get-Content -Path 'lib/utils/shell.dart') -replace 'class ShellUtils \{','abstract class IShellUtils {
  void openWithDialog(PathString filePath);
  Future<bool> openFileExplorerAndSelect(PathString filePath);
  Future<bool> openFolder(String folderPath);
  Future<ProcessResult> runFFmpeg(List<String> args);
  String resolveShortcutInternal(String shortcutPath);
  Future<String?> resolveShortcut(String shortcutPath);
  bool isShortcut(String path);
  int findPlayerWindowByFilePath(String filePath);
  bool bringWindowToForeground(int hwnd);
  bool focusPlayerWindowByFilePath(String filePath);
}

class RealShellUtils implements IShellUtils {' -replace 'static void openWithDialog','void openWithDialog' -replace 'static Future<bool> _open','Future<bool> _open' -replace 'static Future<bool> openFileExplorerAndSelect','Future<bool> openFileExplorerAndSelect' -replace 'static Future<bool> openFolder','Future<bool> openFolder' -replace 'static Future<ProcessResult> runFFmpeg','Future<ProcessResult> runFFmpeg' -replace 'static String resolveShortcutInternal','String resolveShortcutInternal' -replace 'static Future<String\?> resolveShortcut','Future<String?> resolveShortcut' -replace 'static bool isShortcut','bool isShortcut' -replace 'static Pointer<NativeFunction<WNDENUMPROC>>\? _enumWindowsCallback;','Pointer<NativeFunction<WNDENUMPROC>>? _enumWindowsCallback;' -replace 'static String\? _targetFilePath;','String? _targetFilePath;' -replace 'static int _foundWindowHandle = 0;','int _foundWindowHandle = 0;' -replace 'static int findPlayerWindowByFilePath','int findPlayerWindowByFilePath' -replace 'static int _enumWindowsCallbackImpl','int _enumWindowsCallbackImpl' -replace 'static bool bringWindowToForeground','bool bringWindowToForeground' -replace 'static bool focusPlayerWindowByFilePath','bool focusPlayerWindowByFilePath' | Set-Content -Path 'lib/utils/shell.dart'

Add-Content -Path 'lib/utils/shell.dart' -Value @"
class MockShellUtils implements IShellUtils {
  @override
  void openWithDialog(PathString filePath) {}

  @override
  Future<bool> openFileExplorerAndSelect(PathString filePath) async => true;

  @override
  Future<bool> openFolder(String folderPath) async => true;

  @override
  Future<ProcessResult> runFFmpeg(List<String> args) async => ProcessResult(0, 0, '', '');

  @override
  String resolveShortcutInternal(String shortcutPath) => shortcutPath.replaceAll(' - Shortcut.lnk', '');

  @override
  Future<String?> resolveShortcut(String shortcutPath) async => null;

  @override
  bool isShortcut(String path) => path.toLowerCase().endsWith('.lnk');

  @override
  int findPlayerWindowByFilePath(String filePath) => 0;

  @override
  bool bringWindowToForeground(int hwnd) => true;

  @override
  bool focusPlayerWindowByFilePath(String filePath) => true;
}
"@
