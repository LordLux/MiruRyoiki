import '../services/di/dependency_injection.dart';
import 'package:meta/meta.dart';
// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:video_data_utils/video_data_utils.dart';

import '../utils/logging.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'path.dart';

// Constants for ShellExecuteEx
const int SEE_MASK_INVOKEIDLIST = 0x0000000C;
const int SEE_MASK_NO_CONSOLE = 0x00008000;
const int SEE_MASK_FLAG_DDEWAIT = 0x00000100;

// Constants for SetWindowPos
const int HWND_TOP = 0;
const int SWP_NOMOVE = 0x0002;
const int SWP_NOSIZE = 0x0001;
const int SWP_SHOWWINDOW = 0x0040;

// Constants for SHFileOperation
const int FO_DELETE = 0x0003;
const int FOF_ALLOWUNDO = 0x0040;
const int FOF_NOCONFIRMATION = 0x0010;
const int FOF_SILENT = 0x0004;

// GUIDs for IShellLink
const String IID_IShellLinkW = '{000214F9-0000-0000-C000-000000000046}';
const String CLSID_ShellLink = '{00021401-0000-0000-C000-000000000046}';
const String IID_IPersistFile = '{0000010B-0000-0000-C000-000000000046}';

abstract class IShellUtils {
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
  void moveToRecycleBin(String path);
}

class RealShellUtils implements IShellUtils {
  /// Opens the Windows "Open With" dialog for a file
  @override
  void openWithDialog(PathString filePath) async {
    final exeInfo = calloc<SHELLEXECUTEINFO>();
    try {
      exeInfo.ref.cbSize = sizeOf<SHELLEXECUTEINFO>();
      exeInfo.ref.fMask = SEE_MASK_FLAG_DDEWAIT | SEE_MASK_INVOKEIDLIST | SEE_MASK_NO_CONSOLE;
      exeInfo.ref.hwnd = NULL;
      exeInfo.ref.lpVerb = TEXT('openas');
      exeInfo.ref.lpFile = TEXT(filePath.path);
      exeInfo.ref.nShow = SW_SHOWNORMAL; // 1

      final success = ShellExecuteEx(exeInfo);
      if (success == FALSE) {
        final error = GetLastError();
        logErr('ShellExecuteEx failed with error', error);
      }
    } catch (e) {
      logErr('Error opening "Open With" dialog', e);
    } finally {
      free(exeInfo);
    }
  }

  Future<bool> _open(String directory, String? fileName) async {
    if (!Platform.isWindows) {
      logErr('This functionality is Windows-only.');
      return false;
    }
    final program = 'explorer.exe';
    final command = fileName != null //
        ? '/select,"${p.join(directory, fileName)}"'
        : '"$directory"';

    final success = ShellExecute(
      NULL,
      TEXT('open'),
      TEXT(program),
      TEXT(command),
      nullptr,
      SW_SHOWMAXIMIZED,
    );
    if (success <= 32) {
      final error = GetLastError();
      logErr('ShellExecute failed with error', error);
      return false;
    }

    logInfo('Opened directory: $directory, highlighted file: $fileName');
    return true;
  }

  /// Opens the file explorer and selects the specified file
  @override
  Future<bool> openFileExplorerAndSelect(PathString filePath) async {
    try {
      final directory = p.dirname(filePath.path);
      final fileName = p.basename(filePath.path);
      return await _open(directory, fileName);
    } catch (e) {
      logErr('Error selecting file in explorer', e);
      return false;
    }
  }

  /// Opens the folder in file explorer
  @override
  Future<bool> openFolder(String folderPath) async {
    try {
      return await _open(folderPath, null);
    } catch (e) {
      logErr('Error opening folder', e);
      return false;
    }
  }

  @override
  Future<ProcessResult> runFFmpeg(List<String> args) async => //
      await Process.run('ffmpeg', args);

  /// testing method to resolve shortcut
  /// example input: "M:\Videos\SeriesTest\A Place Further Than The Universe - Shortcut.lnk"
  /// output: "M:\Videos\Series\A Place Further Than The Universe\"
  @override
  String resolveShortcutInternal(String shortcutPath) {
    shortcutPath = shortcutPath.replaceAll(" - Shortcut.lnk", "");
    final path = PathString(shortcutPath);
    return r"M:\Videos\Series\" + path.fileName!;
  }

  /// Resolves a Windows shortcut (.lnk) file to its target path
  /// Returns null if the file is not a shortcut or if resolution fails
  /// Based on the official Microsoft documentation approach using Resolve + GetPath
  @override
  Future<String?> resolveShortcut(String shortcutPath) async {
    if (!Platform.isWindows) return null;
    if (!shortcutPath.toLowerCase().endsWith('.lnk')) return null;
    if (!File(shortcutPath).existsSync()) return null;

    return await VideoDataUtils().resolveShortcutPath(shortcutPath: shortcutPath);
  }

  /// Check if a path is a Windows shortcut file
  @override
  bool isShortcut(String path) => Platform.isWindows && path.toLowerCase().endsWith('.lnk');

  /// Callback function for EnumWindows to find a window by its title
  Pointer<NativeFunction<WNDENUMPROC>>? _enumWindowsCallback;
  static String? _targetFilePath;
  static int _foundWindowHandle = 0;

  /// Finds a window handle by searching for a window title that contains the file path
  @override
  int findPlayerWindowByFilePath(String filePath) {
    if (!Platform.isWindows) {
      logErr('This functionality is Windows-only.');
      return 0;
    }

    _targetFilePath = p.basename(filePath); // Get just the filename
    _foundWindowHandle = 0;

    // Create the callback function
    _enumWindowsCallback = Pointer.fromFunction<WNDENUMPROC>(_enumWindowsCallbackImpl, 0);

    // Enumerate all top-level windows
    EnumWindows(_enumWindowsCallback!, 0);

    final result = _foundWindowHandle;
    _foundWindowHandle = 0;
    _targetFilePath = null;
    return result;
  }

  /// Callback implementation for EnumWindows
  static int _enumWindowsCallbackImpl(int hwnd, int lParam) {
    final length = GetWindowTextLength(hwnd);
    if (length == 0) return TRUE;

    final buffer = wsalloc(length + 1);
    GetWindowText(hwnd, buffer, length + 1);
    final title = buffer.toDartString();
    free(buffer);

    // Check if the window title contains the target file path
    if (_targetFilePath != null && title.contains(_targetFilePath!)) {
      _foundWindowHandle = hwnd;
      return FALSE; // Stop enumeration
    }

    return TRUE; // Continue enumeration
  }

  /// Brings a window to the foreground
  @override
  bool bringWindowToForeground(int hwnd) {
    if (!Platform.isWindows) {
      logErr('This functionality is Windows-only.');
      return false;
    }

    if (hwnd == 0) {
      logErr('Invalid window handle: 0');
      return false;
    }

    try {
      // Check if window is minimized and restore it if necessary
      if (IsIconic(hwnd) != 0) ShowWindow(hwnd, SW_RESTORE);

      // Set the window as the foreground window
      final result = SetForegroundWindow(hwnd);

      if (result == 0) {
        logErr('Failed to bring window to foreground. Handle: $hwnd');
        return false;
      }

      // Optionally bring the window to the top of the Z order
      SetWindowPos(hwnd, HWND_TOP, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_SHOWWINDOW);

      logInfo('Successfully brought window to foreground. Handle: $hwnd');
      return true;
    } catch (e) {
      logErr('Error bringing window to foreground', e);
      return false;
    }
  }

  /// Finds a window by file path and brings it to the foreground
  /// Returns true if successful, false otherwise
  @override
  bool focusPlayerWindowByFilePath(String filePath) {
    if (!Platform.isWindows) {
      logErr('This functionality is Windows-only.');
      return false;
    }

    try {
      final hwnd = findPlayerWindowByFilePath(filePath);
      if (hwnd == 0) {
        logErr('Could not find window for file: $filePath');
        return false;
      }

      return bringWindowToForeground(hwnd);
    } catch (e) {
      logErr('Error focusing window by file path', e);
      return false;
    }
  }

  // TODO: implement proper recycle bin support for other platforms
  /// Moves [path] to the Windows Recycle Bin (with undo support)
  ///
  /// On non-Windows platforms the entity is permanently deleted
  @override
  void moveToRecycleBin(String path) {
    if (!Platform.isWindows) {
      try {
        if (FileSystemEntity.isDirectorySync(path)) {
          Directory(path).deleteSync(recursive: true);
        } else {
          File(path).deleteSync();
        }
      } catch (e) {
        logErr('Error permanently deleting: $e', e);
      }
      return;
    }

    final units = path.codeUnits;
    final pFrom = calloc<Uint16>(units.length + 2);
    for (var i = 0; i < units.length; i++) {
      pFrom[i] = units[i];
    }
    final fileOp = calloc<SHFILEOPSTRUCT>();
    try {
      fileOp.ref.wFunc = FO_DELETE;
      fileOp.ref.pFrom = pFrom.cast<Utf16>();
      fileOp.ref.fFlags = FOF_ALLOWUNDO | FOF_NOCONFIRMATION | FOF_SILENT;
      SHFileOperation(fileOp);
    } finally {
      calloc.free(pFrom);
      calloc.free(fileOp);
    }
  }
}

@visibleForTesting
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
  Future<String?> resolveShortcut(String shortcutPath) async => resolveShortcutInternal(shortcutPath);

  @override
  bool isShortcut(String path) => path.toLowerCase().endsWith('.lnk');

  @override
  int findPlayerWindowByFilePath(String filePath) => 0;

  @override
  bool bringWindowToForeground(int hwnd) => true;

  @override
  bool focusPlayerWindowByFilePath(String filePath) => true;

  @override
  void moveToRecycleBin(String path) {}
}

class ShellUtils {
  static void openWithDialog(PathString filePath) => ServiceLocator.shellUtils.openWithDialog(filePath);
  static Future<bool> openFileExplorerAndSelect(PathString filePath) => ServiceLocator.shellUtils.openFileExplorerAndSelect(filePath);
  static Future<bool> openFolder(String folderPath) => ServiceLocator.shellUtils.openFolder(folderPath);
  static Future<ProcessResult> runFFmpeg(List<String> args) => ServiceLocator.shellUtils.runFFmpeg(args);
  static String resolveShortcutInternal(String shortcutPath) => ServiceLocator.shellUtils.resolveShortcutInternal(shortcutPath);
  static Future<String?> resolveShortcut(String shortcutPath) => ServiceLocator.shellUtils.resolveShortcut(shortcutPath);
  static bool isShortcut(String path) => ServiceLocator.shellUtils.isShortcut(path);
  static int findPlayerWindowByFilePath(String filePath) => ServiceLocator.shellUtils.findPlayerWindowByFilePath(filePath);
  static bool bringWindowToForeground(int hwnd) => ServiceLocator.shellUtils.bringWindowToForeground(hwnd);
  static bool focusPlayerWindowByFilePath(String filePath) => ServiceLocator.shellUtils.focusPlayerWindowByFilePath(filePath);
  static void moveToRecycleBin(String path) => ServiceLocator.shellUtils.moveToRecycleBin(path);
}
