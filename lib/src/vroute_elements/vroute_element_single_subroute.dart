part of '../main.dart';

/// If the VRouteElement has a single [VRouteElement] as a child, it should instantiate this class
///
/// What is does is implementing [buildRoute], [buildPathFromName] and [buildPathFromPop] methods
mixin VRouteElementSingleSubRoute on VRouteElement {
  /// The list of possible routes
  /// Only one will be chosen to be displayed
  List<VRouteElement> buildRoutes();

  late final List<VRouteElement> _subroutes = buildRoutes();

  /// Describes whether we should we pop this [VRouteElement]
  /// if the [VRouteElement] of the subroute pops
  bool get popWithSubRoute => true;

  /// [buildRoute] must return [VRoute] if it constitute (which its subroutes or not) a valid
  /// route given the input parameters
  /// [VRoute] should describe this valid route
  ///
  ///
  /// [vPathRequestData] contains all the information about the original request coming
  /// from [VRouter]
  /// It should not be changed and should be given as-is to its subroutes
  ///
  /// [parentRemainingPath] is the part on which to base any local path
  /// WARNING: [parentRemainingPath] is null if the parent did not match the path
  /// in which case only absolute path should be tested.
  ///
  /// [parentPathParameters] are the path parameters of every [VRouteElement] above this
  /// one in the route
  ///
  /// [buildRoute] basically just checks for a match in stackedRoutes and if any
  /// adds this [VRouteElement] to the [VRoute]
  ///
  /// For more info on buildRoute, see [VRouteElement.buildRoute]
  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required VPathMatch parentVPathMatch,
  }) {
    VRoute? childVRoute;
    for (var vRouteElement in _subroutes) {
      childVRoute = vRouteElement.buildRoute(
        vPathRequestData,
        parentVPathMatch: parentVPathMatch,
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

  /// This function takes a name and tries to find the path corresponding to
  /// the route matching this name
  ///
  /// The deeper nested the route the better
  /// The given path parameters have to include at least every path parameters of the final path
  GetPathFromNameResult getPathFromName(
    String nameToMatch, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
    required Map<String, String> remainingPathParameters,
  }) {
    final childNameResults = <GetPathFromNameResult>[];

    // Check if any subroute matches the name
    for (var vRouteElement in _subroutes) {
      childNameResults.add(
        vRouteElement.getPathFromName(
          nameToMatch,
          pathParameters: pathParameters,
          parentPathResult: parentPathResult,
          remainingPathParameters: remainingPathParameters,
        ),
      );
      if (childNameResults.last is ValidNameResult) {
        return childNameResults.last;
      }
    }

    // If we don't have any valid result

    // If some stackedRoute returned PathParamsPopError, aggregate them
    final pathParamsNameErrors = PathParamsErrorsNameResult(
      name: nameToMatch,
      values: childNameResults.fold<List<PathParamsError>>(
        <PathParamsError>[],
        (previousValue, element) {
          return previousValue +
              ((element is PathParamsErrorsNameResult) ? element.values : []);
        },
      ),
    );

    // If there was any PathParamsPopError, we have some pathParamsPopErrors.values
    // and therefore should return this
    if (pathParamsNameErrors.values.isNotEmpty) {
      return pathParamsNameErrors;
    }

    // Else try to find a NullPathError
    if (childNameResults.indexWhere(
            (childNameResult) => childNameResult is NullPathErrorNameResult) !=
        -1) {
      return NullPathErrorNameResult(name: nameToMatch);
    }

    // Else return a NotFoundError
    return NotFoundErrorNameResult(name: nameToMatch);
  }

  /// [GetPathFromPopResult.didPop] is true if this [VRouteElement] popped
  /// [GetPathFromPopResult.extendedPath] is null if this path can't be the right one according to
  ///                                                                     the path parameters
  /// [GetPathFromPopResult] is null when this [VRouteElement] does not pop AND none of
  ///                                                                     its stackedRoutes popped
  GetPathFromPopResult getPathFromPop(
    VRouteElement elementToPop, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
  }) {
    // If vRouteElement is this, then this is the element to pop so we return null
    if (elementToPop == this) {
      if (parentPathResult is ValidParentPathResult) {
        return ValidPopResult(
          path: parentPathResult.path,
          didPop: true,
          poppedVRouteElements: [this],
        );
      } else {
        assert(parentPathResult is PathParamsErrorNewParentPath);
        return PathParamsPopErrors(
          values: [
            MissingPathParamsError(
              pathParams: pathParameters.keys.toList(),
              missingPathParams:
                  (parentPathResult as PathParamsErrorNewParentPath)
                      .pathParameters,
            ),
          ],
        );
      }
    }

    final popErrorResults = <GetPathFromPopResult>[];

    // Try to pop from the stackedRoutes
    for (var vRouteElement in _subroutes) {
      GetPathFromPopResult childPopResult = vRouteElement.getPathFromPop(
        elementToPop,
        pathParameters: pathParameters,
        parentPathResult: parentPathResult,
      );
      if (childPopResult is ValidPopResult) {
        if (popWithSubRoute && childPopResult.didPop) {
          // if the nestedRoute popped, we should pop too
          if (parentPathResult is ValidParentPathResult) {
            return ValidPopResult(
              path: parentPathResult.path,
              didPop: true,
              poppedVRouteElements:
                  <VRouteElement>[this] + childPopResult.poppedVRouteElements,
            );
          } else {
            assert(parentPathResult is PathParamsErrorNewParentPath);
            popErrorResults.add(
              PathParamsPopErrors(
                values: [
                  MissingPathParamsError(
                    pathParams: pathParameters.keys.toList(),
                    missingPathParams:
                        (parentPathResult as PathParamsErrorNewParentPath)
                            .pathParameters,
                  ),
                ],
              ),
            );
          }
        } else {
          return ValidPopResult(
            path: childPopResult.path,
            didPop: false,
            poppedVRouteElements: childPopResult.poppedVRouteElements,
          );
        }
      } else {
        popErrorResults.add(childPopResult);
      }
    }

    // If we don't have any valid result

    // If some stackedRoute returned PathParamsPopError, aggregate them
    final pathParamsPopErrors = PathParamsPopErrors(
      values: popErrorResults.fold<List<MissingPathParamsError>>(
        <MissingPathParamsError>[],
        (previousValue, element) {
          return previousValue +
              ((element is PathParamsPopErrors) ? element.values : []);
        },
      ),
    );

    // If there was any PathParamsPopError, we have some pathParamsPopErrors.values
    // and therefore should return this
    if (pathParamsPopErrors.values.isNotEmpty) {
      return pathParamsPopErrors;
    }

    // If none of the stackedRoutes popped, this did not pop, and there was no path parameters issue, return not found
    // This should never happen
    return ErrorNotFoundGetPathFromPopResult();
  }
}
