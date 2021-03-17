part of '../main.dart';

@immutable
class VNesterPage extends VPage {
  final List<VRouteElement> nestedRoutes;
  final Widget Function(Widget child) widgetBuilder;

  VNesterPage({
    required Page Function(LocalVRouterData child) pageBuilder,
    required this.widgetBuilder,
    required String? path,
    required this.nestedRoutes,
    String? name,
    List<VRouteElement> stackedRoutes = const [],
    List<String> aliases = const [],
    bool mustMatchSubRoute = false,
  })  : assert(nestedRoutes.isNotEmpty,
            'The stackedRoutes of a VNester should not be null, otherwise it can\'t nest'),
        navigatorKey = GlobalKey<NavigatorState>(),
        heroController = HeroController(),
        super(
          pageBuilder: pageBuilder,
          widget: widgetBuilder(Container()),
          path: path,
          name: name,
          stackedRoutes: stackedRoutes,
          aliases: aliases,
          mustMatchSubRoute: mustMatchSubRoute,
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

    // This will hold every GetPathMatchResult for the aliases so that we compute them only once
    List<GetPathMatchResult> aliasesGetPathMatchResult = [];

    // Try to find valid VRoute from nestedRoutes

    // Check for the path
    final pathGetPathMatchResult = getPathMatch(
      entirePath: vPathRequestData.path,
      remainingPathFromParent: parentRemainingPath,
      selfPath: path,
      selfPathRegExp: pathRegExp,
      selfPathParametersKeys: pathParametersKeys,
    );
    final VRoute? vRoute = getVRouteFromRoutes(
      vPathRequestData,
      routes: nestedRoutes,
      parentPathParameters: parentPathParameters,
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
        );
        final VRoute? vRoute = getVRouteFromRoutes(
          vPathRequestData,
          routes: nestedRoutes,
          parentPathParameters: parentPathParameters,
          getPathMatchResult: aliasesGetPathMatchResult[i],
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
    final VRoute? subRouteVRoute = getVRouteFromRoutes(
      vPathRequestData,
      routes: stackedRoutes,
      parentPathParameters: {
        ...parentPathParameters,
        ...getPathMatchResult.pathParameters,
      },
      getPathMatchResult: getPathMatchResult,
    );

    if (subRouteVRoute == null) {
      final allPathParameters = {
        ...parentPathParameters,
        ...getPathMatchResult.pathParameters,
        ...nestedRouteVRoute.pathParameters,
      };
      final newVRouteElements = VRouteElementNode(this,
          nestedVRouteElementNode: nestedRouteVRoute.vRouteElementNode);

      // If vPageRouteC is null, create a VRoute with the nestedVRoute
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
                            MaterialPage(child: Center(child: CircularProgressIndicator())),
                          ],
                    navigatorKey: navigatorKey,
                    observers: [heroController],
                    backButtonDispatcher:
                        ChildBackButtonDispatcher(Router.of(context).backButtonDispatcher!),
                    onPopPage: (_, __) {
                      RootVRouterData.of(context)
                          .pop(nestedRouteVRoute!.vRouteElementNode.getVRouteElementToPop());

                      // We always prevent popping because we handle it in VRouter
                      return false;
                    },
                    onSystemPopPage: () async {
                      await RootVRouterData.of(context).systemPop(
                          nestedRouteVRoute!.vRouteElementNode.getVRouteElementToPop());

                      // We always prevent popping because we handle it in VRouter
                      return true;
                    },
                  );
                },
              ),
            ),
            vPathRequestData: vPathRequestData,
            pathParameters: allPathParameters,
            vRouteElementNode: newVRouteElements,
          ),
        ],
        pathParameters: allPathParameters,
        vRouteElements: <VRouteElement>[this] + nestedRouteVRoute.vRouteElements,
      );
    } else {
      // If vPageRouteC is NOT null, create a VRoute by mixing nestedVRoute and vPageVRoute

      final allPathParameters = {
        ...parentPathParameters,
        ...getPathMatchResult.pathParameters,
        ...nestedRouteVRoute.pathParameters,
        ...subRouteVRoute.pathParameters,
      };
      final newVRouteElementNode = VRouteElementNode(
        this,
        nestedVRouteElementNode: nestedRouteVRoute.vRouteElementNode,
        subVRouteElementNode: subRouteVRoute.vRouteElementNode,
      );

      return VRoute(
        vRouteElementNode: newVRouteElementNode,
        pages: [
          buildPage(
            widget: Builder(
              builder: (BuildContext context) {
                return VRouterHelper(
                  pages: nestedRouteVRoute!.pages,
                  navigatorKey: navigatorKey,
                  observers: [heroController],
                  backButtonDispatcher:
                      ChildBackButtonDispatcher(Router.of(context).backButtonDispatcher!),
                  onPopPage: (_, __) {
                    RootVRouterData.of(context)
                        .pop(newVRouteElementNode.getVRouteElementToPop());
                    return false;
                  },
                  onSystemPopPage: () async {
                    await RootVRouterData.of(context)
                        .systemPop(newVRouteElementNode.getVRouteElementToPop());
                    return true;
                  },
                );
              },
            ),
            vPathRequestData: vPathRequestData,
            pathParameters: allPathParameters,
            vRouteElementNode: newVRouteElementNode,
          ),
          ...subRouteVRoute.pages,
        ],
        pathParameters: allPathParameters,
        vRouteElements: <VRouteElement>[this] +
            nestedRouteVRoute.vRouteElements +
            subRouteVRoute.vRouteElements,
      );
    }
  }

  String? getPathFromName(
    String nameToMatch, {
    required Map<String, String> pathParameters,
    required String? parentPath,
    required Map<String, String> remainingPathParameters,
  }) {
    // A variable to store the new parentPath from the path
    late final String? newParentPathFromPath;
    late final Map<String, String> newRemainingPathParametersFromPath;

    // A variable to store the new parent path from the aliases
    final List<String?> newParentPathFromAliases = [];
    final List<Map<String, String>> newRemainingPathParametersFromAliases = [];

    // Get the new parent path by taking this path into account
    newParentPathFromPath = getNewParentPath(parentPath,
        path: path, pathParametersKeys: pathParametersKeys, pathParameters: pathParameters);

    newRemainingPathParametersFromPath = Map<String, String>.from(remainingPathParameters)
      ..removeWhere((key, value) => pathParametersKeys.contains(key));

    // Check if any nested route matches the name using path
    for (var vRouteElement in nestedRoutes) {
      String? childPathFromName = vRouteElement.getPathFromName(
        nameToMatch,
        pathParameters: pathParameters,
        parentPath: newParentPathFromPath,
        remainingPathParameters: newRemainingPathParametersFromPath,
      );
      if (childPathFromName != null) {
        return childPathFromName;
      }
    }

    // Check if any subroute matches the name using path
    for (var vRouteElement in stackedRoutes) {
      String? childPathFromName = vRouteElement.getPathFromName(
        nameToMatch,
        pathParameters: pathParameters,
        parentPath: newParentPathFromPath,
        remainingPathParameters: newRemainingPathParametersFromPath,
      );
      if (childPathFromName != null) {
        return childPathFromName;
      }
    }

    for (var i = 0; i < aliases.length; i++) {
      // Get the new parent path by taking this alias into account
      newParentPathFromAliases.add(getNewParentPath(
        parentPath,
        path: aliases[i],
        pathParametersKeys: aliasesPathParametersKeys[i],
        pathParameters: pathParameters,
      ));
      newRemainingPathParametersFromAliases.add(
        Map<String, String>.from(remainingPathParameters)
          ..removeWhere((key, value) => pathParametersKeys.contains(key)),
      );

      // Check if any nested route matches the name using aliases
      for (var vRouteElement in nestedRoutes) {
        String? childPathFromName = vRouteElement.getPathFromName(
          nameToMatch,
          pathParameters: pathParameters,
          parentPath: newParentPathFromAliases[i],
          remainingPathParameters: newRemainingPathParametersFromAliases[i],
        );
        if (childPathFromName != null) {
          return childPathFromName;
        }
      }

      // Check if any subroute matches the name using aliases
      for (var vRouteElement in stackedRoutes) {
        String? childPathFromName = vRouteElement.getPathFromName(
          nameToMatch,
          pathParameters: pathParameters,
          parentPath: newParentPathFromAliases[i],
          remainingPathParameters: newRemainingPathParametersFromAliases[i],
        );
        if (childPathFromName != null) {
          return childPathFromName;
        }
      }
    }

    // If no subroute matches the name, try to match this name
    if (name == nameToMatch) {
      // Note that newParentPath will be null if this path can't be included so the return value
      // is the right one
      if (newParentPathFromPath != null && newRemainingPathParametersFromPath.isEmpty) {
        return newParentPathFromPath;
      }
      for (var i = 0; i < aliases.length; i++) {
        if (newParentPathFromAliases[i] != null &&
            newRemainingPathParametersFromAliases[i].isNotEmpty) {
          return newParentPathFromAliases[i];
        }
      }
    }

    // Else we return null
    return null;
  }

  GetPathFromPopResult? getPathFromPop(
    VRouteElement elementToPop, {
    required Map<String, String> pathParameters,
    required String? parentPath,
  }) {
    // If vRouteElement is this, then this is the element to pop so we return null
    if (elementToPop == this) {
      return GetPathFromPopResult(path: parentPath, didPop: true);
    }

    // Try to match the path given the path parameters
    final newParentPathFromPath = getNewParentPath(
      parentPath,
      path: path,
      pathParametersKeys: pathParametersKeys,
      pathParameters: pathParameters,
    );

    // If the path matched and produced a non null newParentPath, try to pop from the stackedRoutes or the nestedRoutes
    if (newParentPathFromPath != null) {
      // Try to pop from the stackedRoutes
      for (var vRouteElement in stackedRoutes) {
        final childPopResult = vRouteElement.getPathFromPop(
          elementToPop,
          pathParameters: pathParameters,
          parentPath: newParentPathFromPath,
        );
        if (childPopResult != null) {
          return GetPathFromPopResult(path: childPopResult.path, didPop: false);
        }
      }

      // Try to pop from the nestedRoutes
      for (var vRouteElement in nestedRoutes) {
        final childPopResult = vRouteElement.getPathFromPop(
          elementToPop,
          pathParameters: pathParameters,
          parentPath: newParentPathFromPath,
        );
        if (childPopResult != null) {
          if (childPopResult.didPop) {
            // if the nestedRoute popped, we should pop too
            return GetPathFromPopResult(path: parentPath, didPop: true);
          } else {
            return GetPathFromPopResult(path: childPopResult.path, didPop: false);
          }
        }
      }
    }

    // Try to match the aliases given the path parameters
    for (var i = 0; i < aliases.length; i++) {
      final newParentPathFromAlias = getNewParentPath(
        parentPath,
        path: aliases[i],
        pathParametersKeys: aliasesPathParametersKeys[i],
        pathParameters: pathParameters,
      );

      // If an alias matched and produced a non null newParentPath, try to pop from the stackedRoutes or the nestedRoutes
      if (newParentPathFromAlias != null) {
        // Try to pop from the stackedRoutes
        for (var vRouteElement in stackedRoutes) {
          final childPopResult = vRouteElement.getPathFromPop(
            elementToPop,
            pathParameters: pathParameters,
            parentPath: newParentPathFromAlias,
          );
          if (childPopResult != null) {
            return GetPathFromPopResult(path: childPopResult.path, didPop: false);
          }
        }

        // Try to pop from the nested routes
        for (var vRouteElement in nestedRoutes) {
          final childPopResult = vRouteElement.getPathFromPop(
            elementToPop,
            pathParameters: pathParameters,
            parentPath: newParentPathFromAlias,
          );
          if (childPopResult != null) {
            if (childPopResult.didPop) {
              // if the nestedRoute popped, we should pop too
              return GetPathFromPopResult(path: parentPath, didPop: true);
            } else {
              return GetPathFromPopResult(path: childPopResult.path, didPop: false);
            }
          }
        }
      }
    }

    // If none of the stackedRoutes nor the nestedRoutes popped and this did not pop, return a null result
    return null;
  }
}
