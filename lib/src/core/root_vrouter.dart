import 'package:flutter/widgets.dart';
import 'package:vrouter/src/vrouter_vroute_elements.dart';
import 'package:vrouter/src/core/vroute_element.dart';
import 'package:vrouter/src/core/vredirector.dart';

class RootVRouter extends VRouteElement with VRouteElementSingleSubRoute {
  final List<VRouteElement> routes;

  RootVRouter({
    required this.routes,
    Future<void> Function(VRedirector vRedirector) beforeEnter =
        VoidVGuard.voidBeforeEnter,
    Future<void> Function(
      VRedirector vRedirector,
      void Function(Map<String, String> historyState) saveHistoryState,
    )
        beforeLeave = VoidVGuard.voidBeforeLeave,
    void Function(BuildContext context, String? from, String to) afterEnter =
        VoidVGuard.voidAfterEnter,
    Future<void> Function(VRedirector vRedirector) onPop =
        VoidVPopHandler.voidOnPop,
    Future<void> Function(VRedirector vRedirector) onSystemPop =
        VoidVPopHandler.voidOnSystemPop,
  })  : _beforeEnter = beforeEnter,
        _beforeLeave = beforeLeave,
        _afterEnter = afterEnter,
        _onPop = onPop,
        _onSystemPop = onSystemPop;

  @override
  Future<void> beforeEnter(VRedirector vRedirector) =>
      _beforeEnter(vRedirector);
  final Future<void> Function(VRedirector vRedirector) _beforeEnter;

  @override
  Future<void> beforeLeave(
    VRedirector vRedirector,
    void Function(Map<String, String> historyState) saveHistoryState,
  ) =>
      _beforeLeave(vRedirector, saveHistoryState);
  final Future<void> Function(
    VRedirector vRedirector,
    void Function(Map<String, String> historyState) saveHistoryState,
  ) _beforeLeave;

  @override
  void afterEnter(BuildContext context, String? from, String to) =>
      _afterEnter(context, from, to);
  final void Function(BuildContext context, String? from, String to)
      _afterEnter;

  @override
  Future<void> onPop(VRedirector vRedirector) => _onPop(vRedirector);
  final Future<void> Function(VRedirector vRedirector) _onPop;

  @override
  Future<void> onSystemPop(VRedirector vRedirector) =>
      _onSystemPop(vRedirector);
  final Future<void> Function(VRedirector vRedirector) _onSystemPop;

  @override
  void afterUpdate(BuildContext context, String? from, String to) {}

  @override
  Future<void> beforeUpdate(VRedirector vRedirector) async {}

  @override
  List<VRouteElement> buildRoutes() => routes;

  @override
  void afterLeave(BuildContext context, String? from, String to) {}
}
