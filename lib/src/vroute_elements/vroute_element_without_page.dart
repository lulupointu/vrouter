part of '../main.dart';

/// If the VRouteElement does not have a page to display, it should instantiate this class
///
/// What is does is implementing [buildRoute] methods
mixin VRouteElementWithoutPage on VRouteElement {
  /// This [buildRoute] basically just checks for a match in stackedRoutes and if any
  /// adds this [VRouteElement] to the [VRoute]
  ///
  /// For more info on buildRoute, see [VRouteElement.buildRoute]
  @override
  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required String? parentRemainingPath,
    required Map<String, String> parentPathParameters,
  }) {
    VRoute? childVRoute;
    for (var vRouteElement in stackedRoutes) {
      childVRoute = vRouteElement.buildRoute(
        vPathRequestData,
        parentRemainingPath: parentRemainingPath,
        parentPathParameters: parentPathParameters,
      );
      if (childVRoute != null) {
        return VRoute(
          vRouteElementNode: VRouteElementNode(
            this,
            localPath: null,
            stackedVRouteElementNode: childVRoute.vRouteElementNode,
          ),
          pages: childVRoute.pages,
          pathParameters: childVRoute.pathParameters,
          vRouteElements: <VRouteElement>[this] + childVRoute.vRouteElements,
        );
      }
    }

    return null;
  }
}
