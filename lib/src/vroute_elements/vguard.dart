part of '../main.dart';

/// [VGuard] is a [VRouteElement] which is used to control navigation changes
///
/// Use [beforeEnter], [beforeLeave] or [beforeUpdate] to get navigation changes before
/// they take place. These methods will give you a [VRedirector] that you can use to:
///   - know about the navigation changes [VRedirector.previousVRouterData] and [VRedirector.newVRouterData]
///   - redirect using [VRedirector.push] or stop the navigation using [VRedirector.stopRedirection]
///
/// Use [afterEnter] or [afterUpdate] to get notification changes after they happened. At this point
/// you can use [VRouter.of(context)] to get any information about the new route
///
/// See also [VWidgetGuard] for a widget-level way of controlling navigation changes
class VGuard extends VRouteElementBuilder with VoidVPopHandler {
  @override
  Future<void> beforeEnter(VRedirector vRedirector) =>
      _beforeEnter(vRedirector);
  final Future<void> Function(VRedirector vRedirector) _beforeEnter;

  @override
  Future<void> beforeUpdate(VRedirector vRedirector) =>
      _beforeUpdate(vRedirector);
  final Future<void> Function(VRedirector vRedirector) _beforeUpdate;

  @override
  Future<void> beforeLeave(VRedirector vRedirector,
          void Function(Map<String, String> state) saveHistoryState) =>
      _beforeLeave(vRedirector, saveHistoryState);
  final Future<void> Function(VRedirector vRedirector,
      void Function(Map<String, String> state) saveHistoryState) _beforeLeave;

  @override
  void afterEnter(BuildContext context, String? from, String to) =>
      _afterEnter(context, from, to);
  final void Function(BuildContext context, String? from, String to)
      _afterEnter;

  @override
  void afterUpdate(BuildContext context, String? from, String to) =>
      _afterUpdate(context, from, to);
  final void Function(BuildContext context, String? from, String to)
      _afterUpdate;

  /// See [VRouteElement.buildRoutes]
  final List<VRouteElement> stackedRoutes;

  @override
  List<VRouteElement> buildRoutes() => stackedRoutes;

  VGuard({
    Future<void> Function(VRedirector vRedirector) beforeEnter =
        VGuard._voidBeforeEnter,
    Future<void> Function(VRedirector vRedirector) beforeUpdate =
        VGuard._voidBeforeUpdate,
    final Future<void> Function(VRedirector vRedirector,
            void Function(Map<String, String> state) saveHistoryState)
        beforeLeave = VGuard._voidBeforeLeave,
    void Function(BuildContext context, String? from, String to) afterEnter =
        VGuard._voidAfterEnter,
    void Function(BuildContext context, String? from, String to) afterUpdate =
        VGuard._voidAfterUpdate,
    required this.stackedRoutes,
  })   : _beforeEnter = beforeEnter,
        _beforeUpdate = beforeUpdate,
        _beforeLeave = beforeLeave,
        _afterEnter = afterEnter,
        _afterUpdate = afterUpdate;

  /// Default function for [VRouteElement.beforeEnter]
  /// Basically does nothing
  static Future<void> _voidBeforeEnter(VRedirector vRedirector) async {}

  /// Default function for [VRouteElement.beforeUpdate]
  /// Basically does nothing
  static Future<void> _voidBeforeUpdate(VRedirector vRedirector) async {}

  /// Default function for [VRouteElement.beforeLeave]
  /// Basically does nothing
  static Future<void> _voidBeforeLeave(
    VRedirector? vRedirector,
    void Function(Map<String, String> state) saveHistoryState,
  ) async {}

  /// Default function for [VRouteElement.afterEnter]
  /// Basically does nothing
  static void _voidAfterEnter(BuildContext context, String? from, String to) {}

  /// Default function for [VRouteElement.afterUpdate]
  /// Basically does nothing
  static void _voidAfterUpdate(BuildContext context, String? from, String to) {}
}
