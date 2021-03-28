import 'move_to_background_fake.dart'
    if (dart.library.io) 'package:move_to_background/move_to_background.dart'
    as moveToBackground;

import 'platform/platform_none.dart'
    if (dart.library.io) 'platform/platform_io.dart'
    if (dart.library.js) 'platform/platform_web.dart';

/// This class is created so that we can mock MoveToBackground when not on mobile
/// On mobile, we use MoveToBackground from https://pub.dev/packages/move_to_background
class MoveToBackground {
  /// This should not be called
  static Future<void> moveTaskToBack() async {
    if (Platform.isIOS || Platform.isAndroid) {
      moveToBackground.MoveToBackground.moveTaskToBack();
    } else {
      throw ('This method should only be called on IOS or Android.');
    }
  }
}
