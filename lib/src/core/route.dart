import 'package:flutter/widgets.dart';
import 'package:vrouter/src/core/vroute_element.dart';
import 'package:vrouter/src/core/vroute_element_node.dart';

/// Describes the current route
///
/// The gets formed in [VRouteElement.buildRoute]
class VRoute {
  /// The top [VRouteElementNode] of the tree which form the current route
  final VRouteElementNode vRouteElementNode;

  /// A list of every [VRouteElement]s in the route
  ///
  /// Basically a flatten version of [vRouteElementNode]
  final List<VRouteElement> vRouteElements;

  /// The list of [Page] in the route, the can be used to put in a Navigator
  ///
  /// Each page may host other navigator to create nesting. This is not flatten.
  final List<Page> pages;

  /// The list of every pathParameters (and their associated current value) of the current route
  final Map<String, String> pathParameters;

  /// The list of every names in the route
  List<String> names;

  VRoute({
    required this.vRouteElementNode,
    required this.pages,
    required this.pathParameters,
    required this.names,
    required this.vRouteElements,
  });
}
