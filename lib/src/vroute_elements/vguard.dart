import 'package:flutter/widgets.dart';
import 'package:vrouter/src/vroute_elements/void_vguard.dart';
import 'package:vrouter/src/vroute_elements/void_vpop_handler.dart';
import 'package:vrouter/src/vroute_elements/vroute_element_builder.dart';
import 'package:vrouter/src/vrouter_core.dart';

/// [VGuard] is a [VRouteElement] which is used to control navigation changes
///
/// Use [beforeEnter], [beforeLeave] or [beforeUpdate] to get navigation changes before
/// they take place. These methods will give you a [VRedirector] that you can use to:
///   - know about the navigation changes [VRedirector.previousVRouterData] and [VRedirector.newVRouterData]
///   - redirect using [VRedirector.to] or stop the navigation using [VRedirector.stopRedirection]
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
        VoidVGuard.voidBeforeEnter,
    Future<void> Function(VRedirector vRedirector) beforeUpdate =
        VoidVGuard.voidBeforeUpdate,
    final Future<void> Function(VRedirector vRedirector,
            void Function(Map<String, String> state) saveHistoryState)
        beforeLeave = VoidVGuard.voidBeforeLeave,
    void Function(BuildContext context, String? from, String to) afterEnter =
        VoidVGuard.voidAfterEnter,
    void Function(BuildContext context, String? from, String to) afterUpdate =
        VoidVGuard.voidAfterUpdate,
    required this.stackedRoutes,
  })  : _beforeEnter = beforeEnter,
        _beforeUpdate = beforeUpdate,
        _beforeLeave = beforeLeave,
        _afterEnter = afterEnter,
        _afterUpdate = afterUpdate;
}
