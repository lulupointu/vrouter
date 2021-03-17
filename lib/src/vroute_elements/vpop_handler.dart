part of '../main.dart';

class VPopHandler with VRouteElement, VRouteElementWithoutPage {
  final List<VRouteElement> stackedRoutes;

  VPopHandler({
    this.onPop = VRouteElement._voidOnPop,
    this.onSystemPop = VRouteElement._voidOnSystemPop,
    required this.stackedRoutes,
  });

  final Future<void> Function(VRedirector vRedirector) onPop;

  final Future<void> Function(VRedirector vRedirector) onSystemPop;
}
