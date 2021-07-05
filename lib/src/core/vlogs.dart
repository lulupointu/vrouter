import 'package:vrouter/src/vlogs.dart';

/// A class which helps easily define which VRouter
/// logs should be shown
abstract class VLogs {
  static const List<VLogLevel> none = [];

  static const List<VLogLevel> info = [
    VLogLevel.info,
    VLogLevel.warning,
  ];

  static const List<VLogLevel> warning = [
    VLogLevel.warning,
  ];
}
