// ignore_for_file: constant_identifier_names

import 'dart:io';
import 'package:path/path.dart' as p;

import '../utils/logging.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

const int SEE_MASK_INVOKEIDLIST = 0x0000000C;
const int SEE_MASK_NO_CONSOLE = 0x00008000;
const int SEE_MASK_FLAG_DDEWAIT = 0x00000100;

class ShellUtils {
  /// Opens the Windows "Open With" dialog for a file
  static void openWithDialog(String filePath) async {
    final exeInfo = calloc<SHELLEXECUTEINFO>();
    try {
      exeInfo.ref.cbSize = sizeOf<SHELLEXECUTEINFO>();
      exeInfo.ref.fMask = SEE_MASK_FLAG_DDEWAIT | SEE_MASK_INVOKEIDLIST | SEE_MASK_NO_CONSOLE;
      exeInfo.ref.hwnd = NULL;
      exeInfo.ref.lpVerb = TEXT('openas');
      exeInfo.ref.lpFile = TEXT(filePath);
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
    final command = fileName != null
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

    log('Opened directory: $directory, highlighted file: $fileName');
    return true;
  }

  /// Opens the file explorer and selects the specified file
  static Future<bool> openFileExplorerAndSelect(String filePath) async {
    try {
      final directory = p.dirname(filePath);
      final fileName = p.basename(filePath);
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
}
