import 'dart:io' if (dart.library.io) 'dart:html';

class MoveToBackground {

  /// This should not be called
  static Future<void> moveTaskToBack() async => throw('This method should only be called on IOS or Android but current platform is ${Platform.operatingSystem} not IOS or Android.');
}