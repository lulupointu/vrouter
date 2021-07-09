import 'package:vrouter/src/vroute_elements/void_vguard.dart';
import 'package:vrouter/src/vroute_elements/void_vpop_handler.dart';
import 'package:vrouter/src/vroute_elements/vroute_element_single_subroute.dart';
import 'package:vrouter/src/vrouter_core.dart';

/// A [VRouteElement] which allows you to intercept and react to pop events
/// See [onPop] and [onSystemPop] for more detailed explanations
class VPopHandler extends VRouteElement
    with VRouteElementSingleSubRoute, VoidVGuard {
  VPopHandler({
    Future<void> Function(VRedirector vRedirector) onPop =
        VoidVPopHandler.voidOnPop,
    Future<void> Function(VRedirector vRedirector) onSystemPop =
        VoidVPopHandler.voidOnSystemPop,
    required this.stackedRoutes,
  })  : _onPop = onPop,
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
}
