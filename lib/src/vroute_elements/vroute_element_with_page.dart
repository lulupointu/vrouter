part of '../main.dart';

/// If the [VRouteElement] does have a page to display, it should extend this class
///
/// What is does is:
///   - Requiring attribute [widget]
///   - implementing [buildRoute] methods
@immutable
abstract class VRouteElementWithPage extends VRouteElementWithPath {
  /// The widget which will be displayed for the given [path]
  final Widget widget;

  /// The key associated to the page
  final LocalKey? key;

  VRouteElementWithPage({
    required String? path,
    required this.widget,
    required this.key,
    required String? name,
    required List<VRouteElement> stackedRoutes,
    required List<String> aliases,
    required bool mustMatchStackedRoute,
  }) : super(
          path: path,
          name: name,
          stackedRoutes: stackedRoutes,
          aliases: aliases,
          mustMatchStackedRoute: mustMatchStackedRoute,
        );

  /// This is basically the same as [VRouteElementWithPath.buildRoute] except that
  /// we add the page of this [VRouteElement] as a page to [VRoute.pages]
  @override
  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required String? parentRemainingPath,
    required Map<String, String> parentPathParameters,
  }) {
    VRoute? vRouteElementWithPathVRoute = super.buildRoute(
      vPathRequestData,
      parentRemainingPath: parentRemainingPath,
      parentPathParameters: parentPathParameters,
    );

    // If the path did match, we add the page in the list of pages
    if (vRouteElementWithPathVRoute != null) {
      return VRoute(
        vRouteElementNode: vRouteElementWithPathVRoute.vRouteElementNode,
        pages: [
              buildPage(
                widget: widget,
                vPathRequestData: vPathRequestData,
                pathParameters: vRouteElementWithPathVRoute.pathParameters,
                vRouteElementNode:
                    vRouteElementWithPathVRoute.vRouteElementNode,
              )
            ] +
            vRouteElementWithPathVRoute.pages,
        pathParameters: vRouteElementWithPathVRoute.pathParameters,
        vRouteElements: vRouteElementWithPathVRoute.vRouteElements,
      );
    }

    // Else return null
    return null;
  }

  /// A function which should allow us to build the page to put in [VRoute.pages]
  Page buildPage({
    required Widget widget,
    required VPathRequestData vPathRequestData,
    required Map<String, String> pathParameters,
    required VRouteElementNode vRouteElementNode,
  });
}
