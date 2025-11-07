// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:video_data_utils/video_data_utils.dart';

import '../utils/logging.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

import 'path.dart';

const int SEE_MASK_INVOKEIDLIST = 0x0000000C;
const int SEE_MASK_NO_CONSOLE = 0x00008000;
const int SEE_MASK_FLAG_DDEWAIT = 0x00000100;

// Constants for SetWindowPos
const int HWND_TOP = 0;
const int SWP_NOMOVE = 0x0002;
const int SWP_NOSIZE = 0x0001;
const int SWP_SHOWWINDOW = 0x0040;

// GUIDs for IShellLink
const String IID_IShellLinkW = '{000214F9-0000-0000-C000-000000000046}';
const String CLSID_ShellLink = '{00021401-0000-0000-C000-000000000046}';
const String IID_IPersistFile = '{0000010B-0000-0000-C000-000000000046}';

class ShellUtils {
  /// Opens the Windows "Open With" dialog for a file
  static void openWithDialog(PathString filePath) async {
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

  static Future<bool> _open(String directory, String? fileName) async {
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
  static Future<bool> openFileExplorerAndSelect(PathString filePath) async {
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
  static Future<bool> openFolder(String folderPath) async {
    try {
      return await _open(folderPath, null);
    } catch (e) {
      logErr('Error opening folder', e);
      return false;
    }
  }

  static Future<ProcessResult> runFFmpeg(List<String> args) async => //
      await Process.run('ffmpeg', args);

  /// testing method to resolve shortcut
  /// example input: "M:\Videos\SeriesTest\A Place Further Than The Universe - Shortcut.lnk"
  /// output: "M:\Videos\Series\A Place Further Than The Universe\"
  static String resolveShortcutInternal(String shortcutPath) {
    shortcutPath = shortcutPath.replaceAll(" - Shortcut.lnk", "");
    final path = PathString(shortcutPath);
    return r"M:\Videos\Series\" + path.name!;
  }

  /// Resolves a Windows shortcut (.lnk) file to its target path
  /// Returns null if the file is not a shortcut or if resolution fails
  /// Based on the official Microsoft documentation approach using Resolve + GetPath
  static Future<String?> resolveShortcut(String shortcutPath) async {
    if (!Platform.isWindows) return null;
    if (!shortcutPath.toLowerCase().endsWith('.lnk')) return null;
    if (!File(shortcutPath).existsSync()) return null;

    return await VideoDataUtils().resolveShortcutPath(shortcutPath: shortcutPath);
  }

  /// Check if a path is a Windows shortcut file
  static bool isShortcut(String path) => Platform.isWindows && path.toLowerCase().endsWith('.lnk');

  /// Callback function for EnumWindows to find a window by its title
  static Pointer<NativeFunction<WNDENUMPROC>>? _enumWindowsCallback;
  static String? _targetFilePath;
  static int _foundWindowHandle = 0;

  /// Finds a window handle by searching for a window title that contains the file path
  static int findPlayerWindowByFilePath(String filePath) {
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
  static bool bringWindowToForeground(int hwnd) {
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
  static bool focusPlayerWindowByFilePath(String filePath) {
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
}
