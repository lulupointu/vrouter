import 'package:flutter/widgets.dart';
import 'package:vrouter/src/vrouter_core.dart';

/// Use this mixin if you don't want to implement [VRouteElement.beforeEnter],
/// [VRouteElement.beforeUpdate], [VRouteElement.beforeLeave], [VRouteElement.afterEnter]
/// and [VRouteElement.afterUpdate]
///
/// This mixin will set them to doing nothing
///
/// Note that you can still override these methods
mixin VoidVGuard on VRouteElement {
  @override
  Future<void> beforeEnter(VRedirector vRedirector) =>
      voidBeforeEnter(vRedirector);

  @override
  Future<void> beforeUpdate(VRedirector vRedirector) =>
      voidBeforeUpdate(vRedirector);

  @override
  Future<void> beforeLeave(
    VRedirector vRedirector,
    void Function(Map<String, String> state) saveHistoryState,
  ) =>
      voidBeforeLeave(vRedirector, saveHistoryState);

  @override
  void afterLeave(BuildContext context, String? from, String to) =>
      voidAfterLeave(context, from, to);

  @override
  void afterEnter(BuildContext context, String? from, String to) =>
      voidAfterEnter(context, from, to);

  @override
  void afterUpdate(BuildContext context, String? from, String to) =>
      voidAfterUpdate(context, from, to);

  /// Default function for [VRouteElement.beforeEnter]
  /// Basically does nothing
  static Future<void> voidBeforeEnter(VRedirector vRedirector) async {}

  /// Default function for [VRouteElement.beforeUpdate]
  /// Basically does nothing
  static Future<void> voidBeforeUpdate(VRedirector vRedirector) async {}

  /// Default function for [VRouteElement.beforeLeave]
  /// Basically does nothing
  static Future<void> voidBeforeLeave(
    VRedirector? vRedirector,
    void Function(Map<String, String> state) saveHistoryState,
  ) async {}

  /// Default function for [VRouteElement.afterEnter]
  /// Basically does nothing
  static void voidAfterEnter(BuildContext context, String? from, String to) {}

  /// Default function for [VRouteElement.voidAfterLeave]
  /// Basically does nothing
  static void voidAfterLeave(BuildContext context, String? from, String to) {}

  /// Default function for [VRouteElement.afterUpdate]
  /// Basically does nothing
  static void voidAfterUpdate(BuildContext context, String? from, String to) {}
}
