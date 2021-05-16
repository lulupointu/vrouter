import 'package:vrouter/src/vrouter_core.dart';

/// Use this mixin if you don't want to implement [VRouteElement.onPop] and [VRouteElement.onSystemPop]
///
/// This mixin will set them to doing nothing
///
/// Note that you can still override these methods
mixin VoidVPopHandler on VRouteElement {
  @override
  Future<void> onPop(VRedirector vRedirector) => voidOnPop(vRedirector);

  @override
  Future<void> onSystemPop(VRedirector vRedirector) =>
      voidOnSystemPop(vRedirector);

  /// Default function for [onPop]
  /// Basically does nothing
  static Future<void> voidOnPop(VRedirector vRedirector) async {}

  /// Default function for [onSystemPop]
  /// Basically does nothing
  static Future<void> voidOnSystemPop(VRedirector vRedirector) async {}
}
