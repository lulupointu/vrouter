part of '../main.dart';

/// If the VRouteElement does have a page to display, it should instantiate this class
///
/// What is does is:
///     - Requiring attributes [path], [name], [aliases], [widget] and [mustMatchStackedRoutes]
///     - Computing attributes [pathRegExp], [aliasesRegExp], [pathParametersKeys],
///                                                          [aliasesParameters] and [stateKey]
///     - implementing [build] and [getPathFromName] methods for them
@immutable
abstract class VRouteElementWithPage extends VRouteElementWithPath {
  final Widget widget;

  VRouteElementWithPage({
    required this.widget,
    required String? path,
    required String? name,
    required List<VRouteElement> stackedRoutes,
    required List<String> aliases,
    required bool mustMatchSubRoute,
  }) : super(
          path: path,
          name: name,
          stackedRoutes: stackedRoutes,
          aliases: aliases,
          mustMatchSubRoute: mustMatchSubRoute,
        );

  /// [entirePath] is the entire path given (in push for example)
  ///
  /// [parentRemainingPath] is the part of the path which is left to match
  /// after the parent [VRouteElement] matched the [entirePath]
  /// WARNING: [parentRemainingPath] is null if the parent did not match the path
  /// in which case only absolute path should be tested.
  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required String? parentRemainingPath,
    required Map<String, String> parentPathParameters,
  }) {
    VRoute? vRouteElementWithPathVRoute = super.buildRoute(vPathRequestData,
        parentRemainingPath: parentRemainingPath,
        parentPathParameters: parentPathParameters);

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
          vRouteElements: vRouteElementWithPathVRoute.vRouteElements);
    }

    // Else return null
    return null;
  }

  Page buildPage({
    required Widget widget,
    required VPathRequestData vPathRequestData,
    required pathParameters,
    required VRouteElementNode vRouteElementNode,
  });
}
