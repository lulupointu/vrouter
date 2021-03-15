/// This class is created so that we can mock MoveToBackground when not on mobile
/// On mobile, we use MoveToBackground from https://pub.dev/packages/move_to_background
class MoveToBackground {
  /// This should not be called
  static Future<void> moveTaskToBack() async =>
      throw ('This method should only be called on IOS or Android.');
}
