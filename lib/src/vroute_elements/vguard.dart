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
  ///   * [VWidgetGuard.beforeLeave] for widget level beforeLeave
  ///   * [VRedirector] to known how to redirect and have access to route information
  @override
  final Future<void> Function(VRedirector vRedirector,
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
  ///   * [VWidgetGuard.afterEnter] for widget level afterEnter
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
  ///   * [VWidgetGuard.afterEnter] for widget level afterEnter
  @override
  final void Function(BuildContext context, String? from, String to)
      afterUpdate;

  /// See [VRouteElement.stackedRoutes]
  @override
  final List<VRouteElement> stackedRoutes;

  VGuard({
    this.afterEnter = VRouteElement._voidAfterEnter,
    this.afterUpdate = VRouteElement._voidAfterUpdate,
    this.beforeEnter = VRouteElement._voidBeforeEnter,
    this.beforeLeave = VRouteElement._voidBeforeLeave,
    this.beforeUpdate = VRouteElement._voidBeforeUpdate,
    required this.stackedRoutes,
  });
}
