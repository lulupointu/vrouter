import 'package:flutter/widgets.dart';
import 'package:vrouter/src/core/local_vrouter_data.dart';
import 'package:vrouter/src/vroute_elements/vroute_element_with_name.dart';
import 'package:vrouter/src/vrouter_core.dart';
import 'package:vrouter/src/vrouter_widgets.dart';

/// If the [VRouteElement] does have a page to display, it should extend this class
///
/// What is does is:
///   - Requiring attribute [widget]
///   - implementing [buildRoute] methods
@immutable
mixin VRouteElementWithPage on VRouteElement implements VRouteElementWithName {
  List<VRouteElement> get stackedRoutes;

  /// The widget which will be displayed for the given [path]
  Page Function(LocalKey key, Widget child, String? name) get pageBuilder;

  /// The widget which will be put inside the page
  Widget get widget;

  /// A LocalKey that will be given to the page which contains the given [_rootVRouter]
  ///
  /// This key mostly controls the page animation. If a page remains the same but the key is changes,
  /// the page gets animated
  /// The key is by default the value of the current [path] (or [aliases]) with
  /// the path parameters replaced
  ///
  /// Do provide a constant [key] if you don't want this page to animate even if [path] or
  /// [aliases] path parameters change
  LocalKey? get key;

  /// A name for the route which will allow you to easily navigate to it
  /// using [VRouter.of(context).pushNamed]
  ///
  /// Note that [name] should be unique w.r.t every [VRouteElement]
  String? get name;

  /// This is basically the same as [VPath.buildRoute] except that
  /// we add the page of this [VRouteElement] as a page to [VRoute.pages]
  @override
  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required VPathMatch parentVPathMatch,
    required bool parentCanPop,
  }) {
    // Set localPath to null since a VRouteElementWithPage marks a limit between localPaths
    VPathMatch newVPathMatch = (parentVPathMatch is ValidVPathMatch)
        ? ValidVPathMatch(
            remainingPath: parentVPathMatch.remainingPath,
            pathParameters: parentVPathMatch.pathParameters,
            localPath: null,
            names: parentVPathMatch.names + [if (name != null) name!],
          )
        : InvalidVPathMatch(
            localPath: null,
            names: parentVPathMatch.names + [if (name != null) name!],
          );

    VRoute? childVRoute;
    for (var vRouteElement in stackedRoutes) {
      childVRoute = vRouteElement.buildRoute(
        vPathRequestData,
        parentVPathMatch: newVPathMatch,
        parentCanPop: true,
      );
      if (childVRoute != null) {
        break;
      }
    }

    final bool validParentVRoute = !(parentVPathMatch is InvalidVPathMatch) &&
        (parentVPathMatch as ValidVPathMatch).remainingPath.isEmpty;
    if (childVRoute == null && !validParentVRoute) {
      return null;
    }

    final VRouteElementNode vRouteElementNode = VRouteElementNode(
      this,
      localPath: null,
      stackedVRouteElementNode: childVRoute?.vRouteElementNode,
    );

    Map<String, String> pathParameters = childVRoute?.pathParameters ??
        (parentVPathMatch as ValidVPathMatch).pathParameters;

    return VRoute(
      vRouteElementNode: vRouteElementNode,
      pages: [
        pageBuilder(
          key ?? ValueKey(parentVPathMatch.localPath),
          Builder(
            builder: (context) => LocalVRouterData(
              child: NotificationListener<VWidgetGuardMessage>(
                // This listen to [VWidgetGuardNotification] which is a notification
                // that a [VWidgetGuard] sends when it is created
                // When this happens, we store the VWidgetGuard and its context
                // This will be used to call its afterUpdate and beforeLeave in particular.
                onNotification: (VWidgetGuardMessage vWidgetGuardMessage) {
                  VWidgetGuardMessageRoot(
                    vWidgetGuardState: vWidgetGuardMessage.vWidgetGuardState,
                    localContext: vWidgetGuardMessage.localContext,
                    associatedVRouteElement: this,
                  ).dispatch(vPathRequestData.rootVRouterContext);

                  return true;
                },
                child: widget,
              ),
              vRouteElementNode: vRouteElementNode,
              url: vPathRequestData.url,
              previousUrl: vPathRequestData.previousUrl,
              historyState: vPathRequestData.historyState,
              pathParameters: pathParameters,
              queryParameters: vPathRequestData.queryParameters,
              context: context,
            ),
          ),
          name ?? parentVPathMatch.localPath,
        ),
        ...childVRoute?.pages ?? []
      ],
      pathParameters: pathParameters,
      vRouteElements:
          <VRouteElement>[this] + (childVRoute?.vRouteElements ?? []),
      names: (childVRoute?.names ?? []) + [if (name != null) name!],
    );
  }

  /// Tries to find a path from a name
  ///
  /// This first asks its stackedRoutes if they have a match
  /// Else is tries to see if this [VRouteElement] matches the name
  /// Else return null
  ///
  /// Note that not only the name must match but the path parameters must be able to form a
  /// valid path afterward too
  GetPathFromNameResult getPathFromName(
    String nameToMatch, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
    required Map<String, String> remainingPathParameters,
  }) {
    final List<GetPathFromNameResult> childNameResults = [];

    // Check if any subroute matches the name
    for (var vRouteElement in stackedRoutes) {
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

    // If no subroute matches the name, try to match this name
    if (name == nameToMatch) {
      // If path or any alias is valid considering the given path parameters, return this
      if (parentPathResult is ValidParentPathResult) {
        if (parentPathResult.path == null) {
          // If this path is null, we add a NullPathErrorNameResult
          childNameResults.add(NullPathErrorNameResult(name: nameToMatch));
        } else {
          if (remainingPathParameters.isNotEmpty) {
            // If there are path parameters remaining, wee add a PathParamsErrorsNameResult
            childNameResults.add(
              PathParamsErrorsNameResult(
                name: nameToMatch,
                values: [
                  OverlyPathParamsError(
                    pathParams: pathParameters.keys.toList(),
                    expectedPathParams:
                        parentPathResult.pathParameters.keys.toList(),
                  ),
                ],
              ),
            );
          } else {
            // Else the result is valid
            return ValidNameResult(path: parentPathResult.path!);
          }
        }
      } else {
        assert(parentPathResult is PathParamsErrorNewParentPath);
        childNameResults.add(
          PathParamsErrorsNameResult(
            name: nameToMatch,
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
}
