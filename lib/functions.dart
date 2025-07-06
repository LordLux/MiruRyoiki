import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:flutter/services.dart';
import 'package:miruryoiki/manager.dart';
import 'package:miruryoiki/models/series.dart';
import 'package:miruryoiki/services/library/library_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:provider/provider.dart';

import 'services/navigation/show_info.dart';
import 'utils/logging.dart';

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

void printHiddenSeries([String message = '', List<Series>? series]) {
  final library = Provider.of<Library>(Manager.context, listen: false);
  for (final series in series ?? library.series) {
    if (series.isHidden) {
      logSuccess('Hidden series: ${series.name} $message');
    }
  }
}