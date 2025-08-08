// ignore_for_file: constant_identifier_names

abstract class FileUnit {
  String get symbol;
  int get scale; // Number of bytes per unit
}

enum FileSizeUnit implements FileUnit {
  B(1),
  KB(1024),
  MB(1048576),
  GB(1073741824),
  TB(1099511627776);

  @override
  final int scale;

  const FileSizeUnit(this.scale);

  @override
  String get symbol => name;
}

enum FileTransferRateUnit implements FileUnit {
  Bps(1),
  KBps(1024),
  MBps(1048576),
  GBps(1073741824),
  TBps(1099511627776);

  @override
  final int scale;

  const FileTransferRateUnit(this.scale);

  @override
  String get symbol => name;
}

extension FileUnitX on FileUnit {
  String get label => symbol.replaceAll('ps', '/s'); // KB/s or KBps
}

String formatWithUnit(num value, FileUnit unit) => '${(value / unit.scale).toStringAsFixed(2)} ${unit.symbol}';

String _fileXUnit(int value, List<FileUnit> units, [FileUnit? unit]) {
  if (unit != null) return formatWithUnit(value, unit);

  for (final unit in units.reversed) {
    if (value >= unit.scale) return formatWithUnit(value, unit);
  }
  return formatWithUnit(value, units.last);
}

String fileSize(int size, [FileSizeUnit? unit]) => _fileXUnit(size, FileSizeUnit.values, unit);

String fileTransferRate(int rate, [FileTransferRateUnit? unit]) => _fileXUnit(rate, FileTransferRateUnit.values, unit);
