part of '../main.dart';

/// If the VRouteElement does not have a page to display, it should instantiate this class
///
/// What is does is implementing [buildRoute] and [getPathFromName] methods for them
mixin VRouteElementWithoutPage on VRouteElement {
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
          vRouteElementNode: VRouteElementNode(this,
              subVRouteElementNode: childVRoute.vRouteElementNode),
          pages: childVRoute.pages,
          pathParameters: {
            ...parentPathParameters,
            ...childVRoute.pathParameters,
          },
          vRouteElements: <VRouteElement>[this] + childVRoute.vRouteElements,
        );
      }
    }

    return null;
  }
}
