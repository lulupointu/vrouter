import 'vlogs.dart';

abstract class VLogPrinter {
  static List<VLogLevel> showLevels = [
    VLogLevel.info,
    VLogLevel.warning,
  ];

  static const Map<VLogLevel, String> _vLogLevelsColor = {
    VLogLevel.info: '\x1B[32m', // Green
    VLogLevel.warning: '\x1B[33m', // Yellow
    // VLogLevel.error: '\x1B[31m',
  };

  /// A marker used to stop coloring
  static final _endColorMarker = "\x1B[0m";

  static void show(VLog vLog) {
    if (!showLevels.contains(vLog.level)) return;

    final String message = _vLogLevelsColor[vLog.level]! +
        '[VRouter: ' +
        vLog.level.toString().toUpperCase().substring('VLOGLEVEL.'.length) +
        '] ' +
        vLog.toString() +
        ' ' +
        _endColorMarker;

    print(message);
  }
}
