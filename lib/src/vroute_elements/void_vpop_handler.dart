part of '../main.dart';

/// Use this mixin if you don't want to implement [VRouteElement.onPop] and [VRouteElement.onSystemPop]
///
/// This mixin will set them to doing nothing
///
/// Note that you can still override these methods
mixin VoidVPopHandler on VRouteElement {
  @override
  Future<void> onPop(VRedirector vRedirector) async {}

  @override
  Future<void> onSystemPop(VRedirector vRedirector) async {}
}
