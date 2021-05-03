part of '../main.dart';

/// Use this mixin if you don't want to implement [VRouteElement.beforeEnter],
/// [VRouteElement.beforeUpdate], [VRouteElement.beforeLeave], [VRouteElement.afterEnter]
/// and [VRouteElement.afterUpdate]
///
/// This mixin will set them to doing nothing
///
/// Note that you can still override these methods
mixin VoidVGuard on VRouteElement {
  @override
  Future<void> beforeEnter(VRedirector vRedirector) async {}

  @override
  Future<void> beforeUpdate(VRedirector vRedirector) async {}

  @override
  Future<void> beforeLeave(
    VRedirector vRedirector,
    void Function(Map<String, String> state) saveHistoryState,
  ) async {}

  @override
  void afterEnter(BuildContext context, String? from, String to) {}

  @override
  void afterUpdate(BuildContext context, String? from, String to) {}
}
