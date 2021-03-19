part of '../main.dart';

/// A [VRouteElement] which allows you to intercept and react to pop events
/// See [onPop] and [onSystemPop] for more detailed explanations
class VPopHandler with VRouteElement, VRouteElementWithoutPage {
  VPopHandler({
    this.onPop = VRouteElement._voidOnPop,
    this.onSystemPop = VRouteElement._voidOnSystemPop,
    required this.stackedRoutes,
  });

  /// See [VRouteElement.stackedRoutes]
  final List<VRouteElement> stackedRoutes;

  /// When [onPop] is called, you are given a [VRedirector] with which you can:
  ///   - Interrupt the navigation using [VRedirector.stopRedirection]
  ///   - Change the navigation destination using [VRedirector.push], [VRedirector.pushNamed] ...
  ///   - Get information about where you are navigating from using [VRedirector.previousVRouterData]
  ///   - Get information about where you are navigating to using [VRedirector.newVRouterData]. Where you are navigating to is determined by [VRouterState._defaultPop]
  ///
  /// [onPop] can be called in multiple cases:
  ///   - If you call [VRouter.of(context).pop]
  ///   - If you call [Navigator.of(context).pop]
  ///   - When the back button of an AppBar is used (or any other material component which uses
  ///       [Navigator.of(context).pop] under the hood)
  final Future<void> Function(VRedirector vRedirector) onPop;

  /// When [onSystemPop] is called, you are given a [VRedirector] with which you can:
  ///   - Interrupt the navigation using [VRedirector.stopRedirection]
  ///   - Change the navigation destination using [VRedirector.push], [VRedirector.pushNamed] ...
  ///   - Get information about where you are navigating from using [VRedirector.previousVRouterData]
  ///   - Get information about where you are navigating to using [VRedirector.newVRouterData]. Where you are navigating to is determined by [VRouterState._defaultPop]
  ///
  /// [onSystemPop] is called when android back button is used
  ///
  /// Note that if [onSystemPop] is not implemented, [onPop] will be called instead
  final Future<void> Function(VRedirector vRedirector) onSystemPop;
}
