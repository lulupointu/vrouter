part of '../main.dart';

/// A [VRouteElement] similar to [VNester] but which allows you to specify your own page
/// thanks to [pageBuilder]
class VNesterPageBase extends VRouteElement with VoidVGuard, VoidVPopHandler {
  /// A list of [VRouteElement] which widget will be accessible in [widgetBuilder]
  final List<VRouteElement> nestedRoutes;

  /// The list of possible routes to stack on top of this [VRouteElement]
  final List<VRouteElement> stackedRoutes;

  /// A function which creates the [VRouteElement._rootVRouter] associated to this [VRouteElement]
  ///
  /// [child] will be the [VRouteElement._rootVRouter] of the matched [VRouteElement] in
  /// [nestedRoutes]
  final Widget Function(Widget child) widgetBuilder;

  /// A LocalKey that will be given to the page which contains the given [_rootVRouter]
  ///
  /// This key mostly controls the page animation. If a page remains the same but the key is changes,
  /// the page gets animated
  /// The key is by default the value of the current [path] (or [aliases]) with
  /// the path parameters replaced
  ///
  /// Do provide a constant [key] if you don't want this page to animate even if [path] or
  /// [aliases] path parameters change
  final LocalKey? key;

  /// A name for the route which will allow you to easily navigate to it
  /// using [VRouter.of(context).pushNamed]
  ///
  /// Note that [name] should be unique w.r.t every [VRouteElement]
  final String? name;

  /// Function which returns a page that will wrap [widget]
  ///   - key and name should be given to your [Page]
  ///   - child should be placed as the last child in [Route]
  final Page Function(LocalKey key, Widget child, String? name) pageBuilder;

  VNesterPageBase({
    required this.nestedRoutes,
    required this.widgetBuilder,
    required this.pageBuilder,
    this.stackedRoutes = const [],
    this.key,
    this.name,
  }) {
    assert(nestedRoutes.isNotEmpty,
        'The nestedRoutes of a VNester should not be null, otherwise it can\'t nest');
  }

  /// A key for the navigator
  /// It is created automatically
  late final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>(
      debugLabel: 'This is the key of VNesterBase with key $key');

  /// A hero controller for the navigator
  /// It is created automatically
  final HeroController heroController = HeroController();

  @override
  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required VPathMatch parentVPathMatch,
  }) {
    // Set localPath to null since a VNesterPageBase marks a limit between localPaths
    VPathMatch newVPathMatch = (parentVPathMatch is ValidVPathMatch)
        ? ValidVPathMatch(
            remainingPath: parentVPathMatch.remainingPath,
            pathParameters: parentVPathMatch.pathParameters,
            localPath: null,
          )
        : InvalidVPathMatch(localPath: null);

    // Try to find valid VRoute from nestedRoutes
    VRoute? nestedRouteVRoute;
    for (var vRouteElement in nestedRoutes) {
      nestedRouteVRoute = vRouteElement.buildRoute(
        vPathRequestData,
        parentVPathMatch: newVPathMatch,
      );
      if (nestedRouteVRoute != null) {
        break;
      }
    }

    // If no child route match, this is not a match
    if (nestedRouteVRoute == null) {
      return null;
    }

    // Else also try to match stackedRoutes
    VRoute? stackedRouteVRoute;
    for (var vRouteElement in stackedRoutes) {
      stackedRouteVRoute = vRouteElement.buildRoute(
        vPathRequestData,
        parentVPathMatch: newVPathMatch,
      );
      if (stackedRouteVRoute != null) {
        break;
      }
    }

    final vRouteElementNode = VRouteElementNode(
      this,
      localPath: null,
      nestedVRouteElementNode: nestedRouteVRoute.vRouteElementNode,
      stackedVRouteElementNode: stackedRouteVRoute?.vRouteElementNode,
    );

    final pathParameters = {
      ...nestedRouteVRoute.pathParameters,
      ...stackedRouteVRoute?.pathParameters ?? {},
    };

    return VRoute(
      vRouteElementNode: vRouteElementNode,
      pages: [
        pageBuilder(
          key ?? ValueKey(parentVPathMatch.localPath),
          LocalVRouterData(
            child: NotificationListener<VWidgetGuardMessage>(
              // This listen to [VWidgetGuardNotification] which is a notification
              // that a [VWidgetGuard] sends when it is created
              // When this happens, we store the VWidgetGuard and its context
              // This will be used to call its afterUpdate and beforeLeave in particular.
              onNotification: (VWidgetGuardMessage vWidgetGuardMessage) {
                VWidgetGuardMessageRoot(
                  vWidgetGuard: vWidgetGuardMessage.vWidgetGuard,
                  localContext: vWidgetGuardMessage.localContext,
                  associatedVRouteElement: this,
                ).dispatch(vPathRequestData.rootVRouterContext);

                return true;
              },
              child: widgetBuilder(
                Builder(
                  builder: (BuildContext context) {
                    return VRouterHelper(
                      pages: nestedRouteVRoute!.pages.isNotEmpty
                          ? nestedRouteVRoute.pages
                          : [
                              MaterialPage(
                                  child: Center(
                                      child: CircularProgressIndicator())),
                            ],
                      navigatorKey: navigatorKey,
                      observers: <NavigatorObserver>[heroController] +
                          RootVRouterData.of(context)._state.navigatorObservers,
                      backButtonDispatcher: ChildBackButtonDispatcher(
                          Router.of(context).backButtonDispatcher!),
                      onPopPage: (_, __) {
                        RootVRouterData.of(context).popFromElement(
                          nestedRouteVRoute!.vRouteElementNode
                              .getVRouteElementToPop(),
                          pathParameters: VRouter.of(context).pathParameters,
                        );

                        // We always prevent popping because we handle it in VRouter
                        return false;
                      },
                      onSystemPopPage: () async {
                        await RootVRouterData.of(context).systemPopFromElement(
                          nestedRouteVRoute!.vRouteElementNode
                              .getVRouteElementToPop(),
                          pathParameters: VRouter.of(context).pathParameters,
                        );

                        // We always prevent popping because we handle it in VRouter
                        return true;
                      },
                    );
                  },
                ),
              ),
            ),
            vRouteElementNode: vRouteElementNode,
            url: vPathRequestData.url,
            previousUrl: vPathRequestData.previousUrl,
            historyState: vPathRequestData.historyState,
            pathParameters: pathParameters,
            queryParameters: vPathRequestData.queryParameters,
            context: vPathRequestData.rootVRouterContext,
          ),
          name ?? parentVPathMatch.localPath,
        ),
        ...stackedRouteVRoute?.pages ?? [],
      ],
      pathParameters: nestedRouteVRoute.pathParameters,
      vRouteElements: <VRouteElement>[this] +
          nestedRouteVRoute.vRouteElements +
          (stackedRouteVRoute?.vRouteElements ?? []),
    );
  }

  GetPathFromNameResult getPathFromName(
    String nameToMatch, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
    required Map<String, String> remainingPathParameters,
  }) {
    final childNameResults = <GetPathFromNameResult>[];

    // Check if any nestedRoute matches the name
    for (var vRouteElement in nestedRoutes) {
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

    // If no subroute or stackedRoute matches the name, try to match this name
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

    // Try to pop from the nestedRoutes
    for (var vRouteElement in nestedRoutes) {
      GetPathFromPopResult childPopResult = vRouteElement.getPathFromPop(
        elementToPop,
        pathParameters: pathParameters,
        parentPathResult: parentPathResult,
      );
      if (childPopResult is ValidPopResult) {
        if (childPopResult.didPop) {
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

    // Try to pop from the subRoutes
    for (var vRouteElement in stackedRoutes) {
      GetPathFromPopResult childPopResult = vRouteElement.getPathFromPop(
        elementToPop,
        pathParameters: pathParameters,
        parentPathResult: parentPathResult,
      );
      if (childPopResult is ValidPopResult) {
        return ValidPopResult(
          path: childPopResult.path,
          didPop: false,
          poppedVRouteElements: childPopResult.poppedVRouteElements,
        );
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
