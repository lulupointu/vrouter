class MoveToBackground {

  /// This should not be called
  static Future<void> moveTaskToBack() async => throw('This method should only be called on IOS or Android.');
}