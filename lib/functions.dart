import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';

import 'services/navigation/show_info.dart';

void copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
}

void openFile(String path) async {
  if (path.isEmpty) {
    snackBar('Nessun file selezionato', severity: InfoBarSeverity.warning);
    return;
  }
  if (!File(path).existsSync()) {
    snackBar('Il file selezionato non esiste', severity: InfoBarSeverity.error);
    return;
  }
  await Future.microtask(() => OpenFile.open(path));
}

Widget NoImage([Widget? child]) {
  return Container(
    color: Colors.grey.withOpacity(0),
    child: child ?? const Center(child: Text('No Image')),
  );
}
