part of '../main.dart';

class VGuard with VRouteElement, VRouteElementWithoutPage {
  /// This is called before the url is updated, if this [VRouteElement] is NOT in the previous route
  /// but IS in the new route
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.beforeEnter] for global level beforeEnter
  ///   * [VRedirector] to known how to redirect and have access to route information
  @override
  final Future<void> Function(VRedirector vRedirector) beforeEnter;

  /// This is called before the url is updated, if this [VRouteElement] is in the previous route
  /// AND in the new route
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.beforeEnter] for global level beforeEnter
  ///   * [VRedirector] to known how to redirect and have access to route information
  @override
  final Future<void> Function(VRedirector vRedirector) beforeUpdate;

  /// This is called before the url is updated, if this [VRouteElement] is in the previous route
  /// AND NOT in the new route
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// [saveHistoryState] can be used to save a history state before leaving
  /// This history state will be restored if the user uses the back button
  /// You will find the saved history state in the [VRouterData] using
  /// [VRouteData.of(context).historyState]
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.beforeLeave] for global level beforeLeave
  ///   * [VNavigationGuard.beforeLeave] for widget level beforeLeave
  ///   * [VRedirector] to known how to redirect and have access to route information
  @override
  final Future<void> Function(VRedirector? vRedirector,
      void Function(Map<String, String> state) saveHistoryState) beforeLeave;

  /// This is called after the url and the state is updated if this [VRouteElement]
  /// was not it the previous route
  ///
  /// You can't prevent the navigation anymore
  /// You can get the new route parameters, and queryParameters from the context
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.afterEnter] for global level afterEnter
  ///   * [VNavigationGuard.afterEnter] for widget level afterEnter
  @override
  final void Function(BuildContext context, String? from, String to) afterEnter;

  /// This is called after the url and the state is updated if this [VRouteElement]
  /// was already it the previous route
  ///
  /// You can't prevent the navigation anymore
  /// You can get the new route parameters, and queryParameters from the context
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.afterEnter] for global level afterEnter
  ///   * [VNavigationGuard.afterEnter] for widget level afterEnter
  @override
  final void Function(BuildContext context, String? from, String to)
      afterUpdate;

  final List<VRouteElement> subroutes;

  VGuard({
    this.afterEnter = VRouteElement._voidAfterEnter,
    this.afterUpdate = VRouteElement._voidAfterUpdate,
    this.beforeEnter = VRouteElement._voidBeforeEnter,
    this.beforeLeave = VRouteElement._voidBeforeLeave,
    this.beforeUpdate = VRouteElement._voidBeforeUpdate,
    required this.subroutes,
  });

  @override
  Future<void> Function(VRedirector vRedirector) get onPop =>
      VRouteElement._voidOnPop;

  @override
  Future<void> Function(VRedirector vRedirector) get onSystemPop =>
      VRouteElement._voidOnSystemPop;
}
