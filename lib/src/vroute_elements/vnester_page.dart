part of '../main.dart';

/// A [VRouteElement] similar to [VNester] but which allows you to specify your own page
/// thanks to [pageBuilder]
class VNesterPage extends VPage {
  /// A list of [VRouteElement] which widget will be accessible in [widgetBuilder]
  final List<VRouteElement> nestedRoutes;

  /// A function which creates the [VRouteElement.widget] associated to this [VRouteElement]
  ///
  /// [child] will be the [VRouteElement.widget] of the matched [VRouteElement] in
  /// [nestedRoutes]
  final Widget Function(Widget child) widgetBuilder;

  VNesterPage({
    required String? path,
    required Page Function(LocalKey key, Widget child) pageBuilder,
    required this.widgetBuilder,
    required this.nestedRoutes,
    LocalKey? key,
    String? name,
    List<VRouteElement> stackedRoutes = const [],
    List<String> aliases = const [],
    bool mustMatchStackedRoute = false,
  })  : assert(nestedRoutes.isNotEmpty,
            'The nestedRoutes of a VNester should not be null, otherwise it can\'t nest'),
        navigatorKey = GlobalKey<NavigatorState>(),
        heroController = HeroController(),
        super(
          pageBuilder: pageBuilder,
          widget: widgetBuilder(Container()),
          key: key,
          path: path,
          name: name,
          stackedRoutes: stackedRoutes,
          aliases: aliases,
          mustMatchStackedRoute: mustMatchStackedRoute,
        );

  /// A key for the navigator
  /// It is created automatically
  final GlobalKey<NavigatorState> navigatorKey;

  /// A hero controller for the navigator
  /// It is created automatically
  final HeroController heroController;

  @override
  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required String? parentRemainingPath,
    required Map<String, String> parentPathParameters,
  }) {
    VRoute? nestedRouteVRoute;
    late final GetPathMatchResult getPathMatchResult;

    // Try to find valid VRoute from nestedRoutes

    // Check for the path
    final pathGetPathMatchResult = getPathMatch(
      entirePath: vPathRequestData.path,
      remainingPathFromParent: parentRemainingPath,
      selfPath: path,
      selfPathRegExp: pathRegExp,
      selfPathParametersKeys: pathParametersKeys,
      parentPathParameters: parentPathParameters,
    );
    final VRoute? vRoute = getVRouteFromRoutes(
      vPathRequestData,
      routes: nestedRoutes,
      getPathMatchResult: pathGetPathMatchResult,
    );
    if (vRoute != null) {
      // If we have a matching path with the path, keep it
      nestedRouteVRoute = vRoute;
      getPathMatchResult = pathGetPathMatchResult;
    } else {
      // Else check with the aliases
      for (var i = 0; i < aliases.length; i++) {
        final aliasGetPathMatchResult = getPathMatch(
          entirePath: vPathRequestData.path,
          remainingPathFromParent: parentRemainingPath,
          selfPath: aliases[i],
          selfPathRegExp: aliasesRegExp[i],
          selfPathParametersKeys: aliasesPathParametersKeys[i],
          parentPathParameters: parentPathParameters,
        );
        final VRoute? vRoute = getVRouteFromRoutes(
          vPathRequestData,
          routes: nestedRoutes,
          getPathMatchResult: aliasGetPathMatchResult,
        );
        if (vRoute != null) {
          nestedRouteVRoute = vRoute;
          getPathMatchResult = aliasGetPathMatchResult;
          break;
        }
      }
    }

    // If no child route match, this is not a match
    if (nestedRouteVRoute == null) {
      return null;
    }

    // Else also try to match nestedRoute with the path (or the alias) with which the nestedRoute was valid
    final VRoute? stackedRouteVRoute = getVRouteFromRoutes(
      vPathRequestData,
      routes: stackedRoutes,
      getPathMatchResult: getPathMatchResult,
    );

    if (stackedRouteVRoute == null) {
      final newVRouteElements = VRouteElementNode(
        this,
        localPath: pathGetPathMatchResult.localPath,
        nestedVRouteElementNode: nestedRouteVRoute.vRouteElementNode,
      );

      // If stackedRouteVRoute is null, create a VRoute with nestedRouteVRoute
      return VRoute(
        vRouteElementNode: newVRouteElements,
        pages: [
          buildPage(
            widget: widgetBuilder(
              Builder(
                builder: (BuildContext context) {
                  return VRouterHelper(
                    pages: nestedRouteVRoute!.pages.isNotEmpty
                        ? nestedRouteVRoute.pages
                        : [
                            MaterialPage(
                                child:
                                    Center(child: CircularProgressIndicator())),
                          ],
                    navigatorKey: navigatorKey,
                    observers: [heroController],
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
            vPathRequestData: vPathRequestData,
            pathParameters: nestedRouteVRoute.pathParameters,
            vRouteElementNode: newVRouteElements,
          ),
        ],
        pathParameters: nestedRouteVRoute.pathParameters,
        vRouteElements:
            <VRouteElement>[this] + nestedRouteVRoute.vRouteElements,
      );
    } else {
      // If stackedRouteVRoute is NOT null, create a VRoute by mixing nestedRouteVRoute and stackedRouteVRoute

      final allPathParameters = {
        ...nestedRouteVRoute.pathParameters,
        ...stackedRouteVRoute.pathParameters,
      };
      final newVRouteElementNode = VRouteElementNode(
        this,
        localPath: pathGetPathMatchResult.localPath!,
        nestedVRouteElementNode: nestedRouteVRoute.vRouteElementNode,
        stackedVRouteElementNode: stackedRouteVRoute.vRouteElementNode,
      );

      return VRoute(
        vRouteElementNode: newVRouteElementNode,
        pages: [
          buildPage(
            widget: widgetBuilder(
              Builder(
                builder: (BuildContext context) {
                  return VRouterHelper(
                    pages: nestedRouteVRoute!.pages.isNotEmpty
                        ? nestedRouteVRoute.pages
                        : [
                            MaterialPage(
                                child:
                                    Center(child: CircularProgressIndicator())),
                          ],
                    navigatorKey: navigatorKey,
                    observers: [heroController],
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
            vPathRequestData: vPathRequestData,
            pathParameters: allPathParameters,
            vRouteElementNode: newVRouteElementNode,
          ),
          ...stackedRouteVRoute.pages,
        ],
        pathParameters: allPathParameters,
        vRouteElements: <VRouteElement>[this] +
            nestedRouteVRoute.vRouteElements +
            stackedRouteVRoute.vRouteElements,
      );
    }
  }

  GetPathFromNameResult getPathFromName(
    String nameToMatch, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
    required Map<String, String> remainingPathParameters,
  }) {
    // A variable to store the new parentPath from the path
    final List<GetNewParentPathResult> newParentPathResults = [];
    final List<Map<String, String>> newRemainingPathParameters = [];

    final List<GetPathFromNameResult> nameErrorResults = [];

    // Get the new parent path by taking this path into account
    newParentPathResults.add(
      getNewParentPath(
        parentPathResult,
        thisPath: path,
        thisPathParametersKeys: pathParametersKeys,
        pathParameters: pathParameters,
      ),
    );

    newRemainingPathParameters.add(
      Map<String, String>.from(remainingPathParameters)
        ..removeWhere((key, value) => pathParametersKeys.contains(key)),
    );

    // Check if any nested route matches the name using path
    for (var vRouteElement in nestedRoutes) {
      GetPathFromNameResult childPathFromNameResult =
          vRouteElement.getPathFromName(
        nameToMatch,
        pathParameters: pathParameters,
        parentPathResult: newParentPathResults.last,
        remainingPathParameters: newRemainingPathParameters.last,
      );
      if (childPathFromNameResult is ValidNameResult) {
        return childPathFromNameResult;
      } else {
        nameErrorResults.add(childPathFromNameResult);
      }
    }

    // Check if any subroute matches the name using path
    for (var vRouteElement in stackedRoutes) {
      GetPathFromNameResult childPathFromNameResult =
          vRouteElement.getPathFromName(
        nameToMatch,
        pathParameters: pathParameters,
        parentPathResult: newParentPathResults.last,
        remainingPathParameters: newRemainingPathParameters.last,
      );
      if (childPathFromNameResult is ValidNameResult) {
        return childPathFromNameResult;
      } else {
        nameErrorResults.add(childPathFromNameResult);
      }
    }

    for (var i = 0; i < aliases.length; i++) {
      // Get the new parent path by taking this alias into account
      newParentPathResults.add(getNewParentPath(
        parentPathResult,
        thisPath: aliases[i],
        thisPathParametersKeys: aliasesPathParametersKeys[i],
        pathParameters: pathParameters,
      ));
      newRemainingPathParameters.add(
        Map<String, String>.from(remainingPathParameters)
          ..removeWhere((key, value) => pathParametersKeys.contains(key)),
      );

      // Check if any nested route matches the name using aliases
      for (var vRouteElement in nestedRoutes) {
        GetPathFromNameResult childPathFromNameResult =
            vRouteElement.getPathFromName(
          nameToMatch,
          pathParameters: pathParameters,
          parentPathResult: newParentPathResults.last,
          remainingPathParameters: newRemainingPathParameters.last,
        );
        if (childPathFromNameResult is ValidNameResult) {
          return childPathFromNameResult;
        } else {
          nameErrorResults.add(childPathFromNameResult);
        }
      }

      // Check if any subroute matches the name using aliases
      for (var vRouteElement in stackedRoutes) {
        GetPathFromNameResult childPathFromNameResult =
            vRouteElement.getPathFromName(
          nameToMatch,
          pathParameters: pathParameters,
          parentPathResult: newParentPathResults.last,
          remainingPathParameters: newRemainingPathParameters.last,
        );
        if (childPathFromNameResult is ValidNameResult) {
          return childPathFromNameResult;
        } else {
          nameErrorResults.add(childPathFromNameResult);
        }
      }
    }

    // If no subroute matches the name, try to match this name

    // If no subroute matches the name, try to match this name
    if (name == nameToMatch) {
      // If path or any alias is valid considering the given path parameters, return this
      for (int i = 0; i < newParentPathResults.length; i++) {
        var newParentPathResult = newParentPathResults[i];
        if (newParentPathResult is ValidParentPathResult) {
          if (newParentPathResult.path == null) {
            // If this path is null, we add a NullPathErrorNameResult
            nameErrorResults.add(NullPathErrorNameResult(name: nameToMatch));
          } else {
            final newRemainingPathParameter = newRemainingPathParameters[i];
            if (newRemainingPathParameter.isNotEmpty) {
              // If there are path parameters remaining, wee add a PathParamsErrorsNameResult
              nameErrorResults.add(
                PathParamsErrorsNameResult(
                  name: nameToMatch,
                  values: [
                    OverlyPathParamsError(
                      pathParams: pathParameters.keys.toList(),
                      expectedPathParams:
                          newParentPathResult.pathParameters.keys.toList(),
                    ),
                  ],
                ),
              );
            } else {
              // Else the result is valid
              return ValidNameResult(path: newParentPathResult.path!);
            }
          }
        } else {
          assert(newParentPathResult is PathParamsErrorNewParentPath);
          nameErrorResults.add(
            PathParamsErrorsNameResult(
              name: nameToMatch,
              values: [
                MissingPathParamsError(
                  pathParams: pathParameters.keys.toList(),
                  missingPathParams:
                      (newParentPathResult as PathParamsErrorNewParentPath)
                          .pathParameters,
                ),
              ],
            ),
          );
        }
      }
    }

    // If we don't have any valid result

    // If some stackedRoute returned PathParamsPopError, aggregate them
    final pathParamsNameErrors = PathParamsErrorsNameResult(
      name: nameToMatch,
      values: nameErrorResults.fold<List<PathParamsError>>(
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
    if (nameErrorResults.indexWhere(
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
        return ValidPopResult(path: parentPathResult.path, didPop: true);
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

    final List<GetPathFromPopResult> popErrorResults = [];

    // Try to match the path given the path parameters
    final newParentPathFromPath = getNewParentPath(
      parentPathResult,
      thisPath: path,
      thisPathParametersKeys: pathParametersKeys,
      pathParameters: pathParameters,
    );

    // If the path matched and produced a non null newParentPath, try to pop from the stackedRoutes or the nestedRoutes
    // Try to pop from the stackedRoutes
    for (var vRouteElement in stackedRoutes) {
      final childPopResult = vRouteElement.getPathFromPop(
        elementToPop,
        pathParameters: pathParameters,
        parentPathResult: newParentPathFromPath,
      );
      if (childPopResult is ValidPopResult) {
        return ValidPopResult(path: childPopResult.path, didPop: false);
      } else {
        popErrorResults.add(childPopResult);
      }
    }

    // Try to pop from the nestedRoutes
    for (var vRouteElement in nestedRoutes) {
      final childPopResult = vRouteElement.getPathFromPop(
        elementToPop,
        pathParameters: pathParameters,
        parentPathResult: newParentPathFromPath,
      );
      if (childPopResult is ValidPopResult) {
        if (childPopResult.didPop) {
          // if the nestedRoute popped, we should pop too
          if (parentPathResult is ValidParentPathResult) {
            return ValidPopResult(path: parentPathResult.path, didPop: true);
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
          print('Found ValidPopResult in VNester nesting route, path: $path');
          return ValidPopResult(path: childPopResult.path, didPop: false);
        }
      } else {
        popErrorResults.add(childPopResult);
      }
    }

    // Try to match the aliases given the path parameters
    for (var i = 0; i < aliases.length; i++) {
      final newParentPathFromAlias = getNewParentPath(
        parentPathResult,
        thisPath: aliases[i],
        thisPathParametersKeys: aliasesPathParametersKeys[i],
        pathParameters: pathParameters,
      );

      // If an alias matched and produced a non null newParentPath, try to pop from the stackedRoutes or the nestedRoutes
      // Try to pop from the stackedRoutes
      for (var vRouteElement in stackedRoutes) {
        final childPopResult = vRouteElement.getPathFromPop(
          elementToPop,
          pathParameters: pathParameters,
          parentPathResult: newParentPathFromAlias,
        );
        if (childPopResult is ValidPopResult) {
          return ValidPopResult(path: childPopResult.path, didPop: false);
        } else {
          popErrorResults.add(childPopResult);
        }
      }

      // Try to pop from the nested routes
      for (var vRouteElement in nestedRoutes) {
        final childPopResult = vRouteElement.getPathFromPop(
          elementToPop,
          pathParameters: pathParameters,
          parentPathResult: newParentPathFromAlias,
        );
        if (childPopResult is ValidPopResult) {
          print(
              'Found ValidPopResult in VNester nested routes, alias: ${aliases[i]}');
          print('childPopResult.path: ${childPopResult.path}');
          if (childPopResult.didPop) {
            // if the nestedRoute popped, we should pop too
            if (parentPathResult is ValidParentPathResult) {
              return ValidPopResult(path: parentPathResult.path, didPop: true);
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
            return ValidPopResult(path: childPopResult.path, didPop: false);
          }
        } else {
          popErrorResults.add(childPopResult);
        }
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
    return ErrorNotFoundGetPathFromPopResult();
  }
}
