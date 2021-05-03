part of '../main.dart';

class RootVRouter extends VRouteElement with VRouteElementSingleSubRoute {
  final List<VRouteElement> routes;

  RootVRouter({
    required this.routes,
    Future<void> Function(VRedirector vRedirector) beforeEnter =
        VGuard._voidBeforeEnter,
    Future<void> Function(
      VRedirector vRedirector,
      void Function(Map<String, String> historyState) saveHistoryState,
    )
        beforeLeave = VGuard._voidBeforeLeave,
    void Function(BuildContext context, String? from, String to) afterEnter =
        VGuard._voidAfterEnter,
    Future<void> Function(VRedirector vRedirector) onPop =
        VPopHandler._voidOnPop,
    Future<void> Function(VRedirector vRedirector) onSystemPop =
        VPopHandler._voidOnSystemPop,
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
}
