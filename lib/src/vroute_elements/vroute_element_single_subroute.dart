import 'package:vrouter/src/vroute_elements/vroute_element_with_name.dart';
import 'package:vrouter/src/vrouter_core.dart';

/// If the VRouteElement has a single [VRouteElement] as a child, it should instantiate this class
///
/// What is does is implementing [buildRoute], [buildPathFromName] and [buildPathFromPop] methods
mixin VRouteElementSingleSubRoute on VRouteElement {
  /// The list of possible routes
  /// Only one will be chosen to be displayed
  List<VRouteElement> buildRoutes();

  late final List<VRouteElement> _subroutes = buildRoutes();

  /// Describes whether this [VRouteElement] can be a node of a [VRoute]
  ///
  /// If true:
  ///   - this can create a [VRoute] even if no [_subroutes] matches
  ///   - this will pop if a route in [_subroutes] pops
  bool get mustHaveSubRoutes => true;

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
    required bool parentCanPop,
  }) {
    VRoute? childVRoute;
    for (var vRouteElement in _subroutes) {
      childVRoute = vRouteElement.buildRoute(
        vPathRequestData,
        parentVPathMatch: parentVPathMatch,
        parentCanPop: parentCanPop,
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
          names: parentVPathMatch.names,
        );
      }
    }

    // If none where found, test if this [VRouteElement] can create a [VRoute]
    final validParentVPathMatch = (parentVPathMatch is ValidVPathMatch) &&
        parentVPathMatch.remainingPath.isEmpty;
    if (!mustHaveSubRoutes && validParentVPathMatch) {
      return VRoute(
        vRouteElementNode: VRouteElementNode(
          this,
          localPath: null,
        ),
        pages: [],
        pathParameters: (parentVPathMatch as ValidVPathMatch).pathParameters,
        vRouteElements: <VRouteElement>[this],
        names: parentVPathMatch.names,
      );
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

  /// [VPopResult.didPop] is true if this [VRouteElement] popped
  /// [VPopResult.extendedPath] is null if this path can't be the right one according to
  ///                                                                     the path parameters
  /// [VPopResult] is null when this [VRouteElement] does not pop AND none of
  ///                                                                     its stackedRoutes popped
  VPopResult getPathFromPop(
    VRouteElement elementToPop, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
  }) {
    // If vRouteElement is this, then this is the element to pop so we return null
    if (elementToPop == this) {
      return PoppingPopResult(poppedVRouteElements: [this]);
    }

    // Try to pop from the stackedRoutes
    for (var vRouteElement in _subroutes) {
      VPopResult childPopResult = vRouteElement.getPathFromPop(
        elementToPop,
        pathParameters: pathParameters,
        parentPathResult: parentPathResult,
      );
      if (!(childPopResult is NotFoundPopResult)) {
        // If the VRouteElement to pop has been found

        // If NOT PoppingPopResult, return the PathParamsPopErrors or the ValidPopResult as is
        if (!(childPopResult is PoppingPopResult)) {
          // If it is ValidPopResult, add this name to the list of names if this has a name
          if (childPopResult is ValidPopResult) {
            return ValidPopResult(
                path: childPopResult.path,
                poppedVRouteElements: childPopResult.poppedVRouteElements,
                names: ((this is VRouteElementWithName) &&
                            (this as VRouteElementWithName).name != null
                        ? [(this as VRouteElementWithName).name!]
                        : <String>[]) +
                    childPopResult.names);
          }

          return childPopResult;
        }

        // If PoppingPopResult, check whether we should pop with it or not

        if (mustHaveSubRoutes) {
          // If we should pop with the VRouteElement to pop
          // Add ourselves to the poppedVRouteElements in a PoppingPopResult
          return PoppingPopResult(
            poppedVRouteElements: childPopResult.poppedVRouteElements + [this],
          );
        }

        // If we should NOT pop with the VRouteElement to pop

        final poppedVRouteElements = childPopResult.poppedVRouteElements;

        // Check whether the parentPathResult is valid or not
        if (parentPathResult is ValidParentPathResult) {
          // If parentPathResult is valid, return a ValidPopResult with the right path
          return ValidPopResult(
            path: parentPathResult.path,
            poppedVRouteElements: poppedVRouteElements,
            names: (this is VRouteElementWithName) &&
                    (this as VRouteElementWithName).name != null
                ? [(this as VRouteElementWithName).name!]
                : [],
          );
        }

        // Else return a PathParamsPopErrors by specifying what prevented parentPathResult from
        // being valid
        assert(parentPathResult is PathParamsErrorNewParentPath);
        return PathParamsPopErrors(
          poppedVRouteElements: poppedVRouteElements,
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

    // If none of the stackedRoutes popped and this did not pop, return a NotValidPopResult
    // This should never reach RootVRouter
    return NotFoundPopResult();
  }
}
