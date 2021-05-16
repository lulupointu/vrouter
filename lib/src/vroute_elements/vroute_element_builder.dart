import 'package:flutter/foundation.dart';
import 'package:vrouter/src/vroute_elements/void_vguard.dart';
import 'package:vrouter/src/vroute_elements/void_vpop_handler.dart';
import 'package:vrouter/src/vroute_elements/vroute_element_single_subroute.dart';
import 'package:vrouter/src/vrouter_core.dart';

/// [VRouteElement] is the base class for any object used in routes, stackedRoutes
/// or nestedRoutes
@immutable
abstract class VRouteElementBuilder extends VRouteElement
    with VRouteElementSingleSubRoute, VoidVPopHandler, VoidVGuard {}
