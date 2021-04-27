part of '../main.dart';

/// A [VRouteElement] which allows you to intercept and react to pop events
/// See [onPop] and [onSystemPop] for more detailed explanations
class VPopHandler extends VRouteElement
    with VRouteElementSingleSubRoute, VoidVGuard {
  VPopHandler({
    Future<void> Function(VRedirector vRedirector) onPop =
        VPopHandler._voidOnPop,
    Future<void> Function(VRedirector vRedirector) onSystemPop =
        VPopHandler._voidOnSystemPop,
    required this.stackedRoutes,
  })   : _onPop = onPop,
        _onSystemPop = onSystemPop;

  /// See [VRouteElement.buildRoutes]
  final List<VRouteElement> stackedRoutes;

  List<VRouteElement> buildRoutes() => stackedRoutes;

  @override
  Future<void> onPop(VRedirector vRedirector) => _onPop(vRedirector);
  final Future<void> Function(VRedirector vRedirector) _onPop;

  @override
  Future<void> onSystemPop(VRedirector vRedirector) =>
      _onSystemPop(vRedirector);
  final Future<void> Function(VRedirector vRedirector) _onSystemPop;

  /// Default function for [onPop]
  /// Basically does nothing
  static Future<void> _voidOnPop(VRedirector vRedirector) async {}

  /// Default function for [onSystemPop]
  /// Basically does nothing
  static Future<void> _voidOnSystemPop(VRedirector vRedirector) async {}
}
