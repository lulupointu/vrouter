import 'package:flutter/foundation.dart';
import 'package:vrouter/src/path_to_regexp/path_to_regexp.dart';
import 'package:vrouter/src/vroute_elements/void_vguard.dart';
import 'package:vrouter/src/vroute_elements/void_vpop_handler.dart';
import 'package:vrouter/src/vrouter_core.dart';

/// If the [VRouteElement] contains a path, it should extend this class
///
/// What is does is:
///   - Requiring attributes [path], [name], [aliases]
///   - Computing attributes [pathRegExp], [aliasesRegExp], [pathParametersKeys] and [aliasesPathParametersKeys]
///   - implementing a default [buildRoute] and [getPathFromName] methods for them
@immutable
class VPath extends VRouteElement with VoidVGuard, VoidVPopHandler {
  /// The path (relative or absolute) or this [VRouteElement]
  ///
  /// If the path of a subroute is exactly matched, this will be used in
  /// the route but might be covered by another [VRouteElement._rootVRouter]
  /// The value of the path ca have three form:
  ///     * starting with '/': The path will be treated as a route path,
  ///       this is useful to take full advantage of nested routes while
  ///       conserving the freedom of path naming
  ///     * not starting with '/': The path corresponding to this route
  ///       will be the path of the parent route + this path. If this is used
  ///       directly in the [VRouter] routes, a '/' will be added anyway
  ///     * be null: In this case this path will match the parent path
  ///
  /// Note we use the package [path_to_regexp](https://pub.dev/packages/path_to_regexp)
  /// so you can use naming such as /user/:id to get the id (see [VRouteElementData.pathParameters]
  /// You can also use more advance technique using regexp directly in your path, for example
  /// '*' will match any route, '/user/:id(\d+)' will match any route starting with user
  /// and followed by a digit. Here is a recap:
  /// |     pattern 	  | matched path | 	[VRouter.pathParameters]
  /// | /user/:username |  /user/evan  | 	 { username: 'evan' }
  /// | /user/:id(\d+)  |  /user/123   | 	     { id: '123' }
  /// |     *          |  every path  |             -
  final String? path;

  /// Alternative paths that will be matched to this route
  ///
  /// Note that path is match first, then every aliases in order
  final List<String> aliases;

  /// A boolean to indicate whether this can be a valid [VRouteElement] of the [VRoute] if no
  /// [VRouteElement] in its [stackedRoute] is matched
  ///
  /// This is mainly useful for [VRouteElement]s which are NOT [VRouteElementWithPage]
  final bool mustMatchStackedRoute;

  /// The routes which should be included if the constraint on this path are met
  final List<VRouteElement> stackedRoutes;

  VPath({
    required this.path,
    this.aliases = const [],
    this.mustMatchStackedRoute = false,
    required this.stackedRoutes,
  }) {
    pathParametersKeys = <String>[];
    aliasesPathParametersKeys =
        List<List<String>>.generate(aliases.length, (_) => []);
    pathRegExp = (path != null)
        ? pathToRegExp(replaceWildcards(path!), pathParametersKeys)
        : null;
    aliasesRegExp = [
      for (var i = 0; i < aliases.length; i++)
        pathToRegExp(replaceWildcards(aliases[i]), aliasesPathParametersKeys[i])
    ];

    // // Get local parameters
    // if (path != null) {
    //   final localPath = path!.startsWith('/') ? path!.substring(1) : path!;
    //   pathToRegExp(localPath, parameters: pathParametersKeys);
    // }
    //
    // for (var i = 0; i < aliases.length; i++) {
    //   final alias = aliases[i];
    //   final localPath = alias[i].startsWith('/') ? alias.substring(1) : alias;
    //   pathToRegExp(localPath, parameters: aliasesPathParametersKeys[i]);
    // }
  }

  /// RegExp version of the path
  /// It is created automatically
  /// If the path starts with '/', it is removed from
  /// this regExp.
  late final RegExp? pathRegExp;

  /// RegExp version of the aliases
  /// It is created automatically
  /// If an alias starts with '/', it is removed from
  /// this regExp.
  late final List<RegExp> aliasesRegExp;

  /// Parameters of the path
  /// It is created automatically
  late final List<String> pathParametersKeys;

  /// Parameters of the aliases if any
  /// It is created automatically
  late final List<List<String>> aliasesPathParametersKeys;

  /// What this [buildRoute] does is look if any path or alias can give a valid [VRoute]
  /// considering this and the stackedRoutes
  ///
  /// For more about buildRoute, see [VRouteElement.buildRoute]
  @override
  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required VPathMatch parentVPathMatch,
    required bool parentCanPop,
  }) {
    // This will hold the GetPathMatchResult for the path so that we compute it only once
    late final VPathMatch pathMatch;

    // This will hold every GetPathMatchResult for the aliases so that we compute them only once
    List<VPathMatch> aliasesMatch = [];

    // Try to find valid VRoute from stackedRoutes

    // Check for the path
    pathMatch = getPathMatch(
      entirePath: vPathRequestData.path,
      selfPath: path,
      selfPathRegExp: pathRegExp,
      selfPathParametersKeys: pathParametersKeys,
      parentVPathMatch: parentVPathMatch,
    );
    final VRoute? stackedRouteVRoute = getVRouteFromRoutes(
      vPathRequestData,
      routes: stackedRoutes,
      vPathMatch: pathMatch,
      parentCanPop: parentCanPop,
    );
    if (stackedRouteVRoute != null) {
      return VRoute(
        vRouteElementNode: VRouteElementNode(
          this,
          localPath: pathMatch.localPath,
          stackedVRouteElementNode: stackedRouteVRoute.vRouteElementNode,
        ),
        pages: stackedRouteVRoute.pages,
        pathParameters: stackedRouteVRoute.pathParameters,
        vRouteElements:
            <VRouteElement>[this] + stackedRouteVRoute.vRouteElements,
        names: stackedRouteVRoute.names,
      );
    }

    // Check for the aliases
    for (var i = 0; i < aliases.length; i++) {
      aliasesMatch.add(
        getPathMatch(
          entirePath: vPathRequestData.path,
          selfPath: aliases[i],
          selfPathRegExp: aliasesRegExp[i],
          selfPathParametersKeys: aliasesPathParametersKeys[i],
          parentVPathMatch: parentVPathMatch,
        ),
      );
      final VRoute? stackedRouteVRoute = getVRouteFromRoutes(
        vPathRequestData,
        routes: stackedRoutes,
        vPathMatch: aliasesMatch[i],
        parentCanPop: parentCanPop,
      );
      if (stackedRouteVRoute != null) {
        return VRoute(
          vRouteElementNode: VRouteElementNode(
            this,
            localPath: pathMatch.localPath,
            stackedVRouteElementNode: stackedRouteVRoute.vRouteElementNode,
          ),
          pages: stackedRouteVRoute.pages,
          pathParameters: stackedRouteVRoute.pathParameters,
          vRouteElements:
              <VRouteElement>[this] + stackedRouteVRoute.vRouteElements,
          names: stackedRouteVRoute.names,
        );
      }
    }

    // Else, if no subroute is valid

    // // check if this is an exact match with path
    // final vRoute = getVRouteFromSelf(
    //   vPathRequestData,
    //   vPathMatch: pathMatch,
    // );
    // if (vRoute != null) {
    //   return vRoute;
    // }
    //
    // // Check exact match for the aliases
    // for (var i = 0; i < aliases.length; i++) {
    //   final vRoute = getVRouteFromSelf(
    //     vPathRequestData,
    //     vPathMatch: aliasesMatch[i],
    //   );
    //   if (vRoute != null) {
    //     return vRoute;
    //   }
    // }

    // Else return null
    return null;
  }

  /// Searches for a valid [VRoute] by asking [VRouteElement]s is [routes] if they can form a valid [VRoute]
  VRoute? getVRouteFromRoutes(
    VPathRequestData vPathRequestData, {
    required List<VRouteElement> routes,
    required VPathMatch vPathMatch,
    required bool parentCanPop,
  }) {
    for (var vRouteElement in routes) {
      final childVRoute = vRouteElement.buildRoute(
        vPathRequestData,
        parentVPathMatch: vPathMatch,
        parentCanPop: parentCanPop,
      );
      if (childVRoute != null) return childVRoute;
    }
  }

  // /// Try to form a [VRoute] where this [VRouteElement] is the last [VRouteElement]
  // /// This is possible is:
  // ///   - [mustMatchStackedRoute] is false
  // ///   - There is a match of the path and it is exact
  // VRoute? getVRouteFromSelf(
  //   VPathRequestData vPathRequestData, {
  //   required VPathMatch vPathMatch,
  // }) {
  //   if (!mustMatchStackedRoute &&
  //       vPathMatch is ValidVPathMatch &&
  //       (vPathMatch.remainingPath.isEmpty)) {
  //     return VRoute(
  //       vRouteElementNode: VRouteElementNode(this, localPath: vPathMatch.localPath),
  //       pages: [],
  //       pathParameters: vPathMatch.pathParameters,
  //       vRouteElements: <VRouteElement>[this],
  //       names: [],
  //     );
  //   }
  // }

  /// Returns path information given a local path.
  ///
  /// [entirePath] is the whole path, useful when [selfPathRegExp] is absolute
  /// [remainingPathFromParent] is the path that remain after removing the parent paths, useful when [selfPathRegExp] relative
  /// [selfPathRegExp] the RegExp corresponding to the path that should be tested
  ///
  /// Returns a [VPathMatch] which holds two information:
  ///   - The remaining path, after having removed the [selfPathRegExp] (null if there is no match)
  ///   - The path parameters gotten from [selfPathRegExp] and the path, added to the parentPathParameters if relative path
  VPathMatch getPathMatch(
      {required String entirePath,
      required String? selfPath,
      required RegExp? selfPathRegExp,
      required List<String> selfPathParametersKeys,
      required VPathMatch parentVPathMatch}) {
    if (selfPath == null) {
      return parentVPathMatch;
    }

    // if selfPath is not null, neither should selfPathRegExp be
    assert(selfPathRegExp != null);

    // If our path starts with '/', this is an absolute path
    if ((selfPath.startsWith('/'))) {
      final match = selfPathRegExp!.matchAsPrefix(entirePath);

      if (match == null) {
        return InvalidVPathMatch(
          localPath: getConstantLocalPath(),
          names: parentVPathMatch.names,
        );
      }

      var remainingPath = entirePath.substring(match.end);
      final localPath = entirePath.substring(match.start, match.end);
      final pathParameters = extract(selfPathParametersKeys, match)
        ..updateAll((key, value) => Uri.decodeComponent(value));

      // Remove the trailing '/' in remainingPath if needed
      if (remainingPath.startsWith('/'))
        remainingPath = remainingPath.replaceFirst('/', '');

      return ValidVPathMatch(
        remainingPath: remainingPath,
        pathParameters: pathParameters,
        localPath: localPath,
        names: parentVPathMatch.names,
      );
    }

    // Else our path is relative
    final String? thisConstantLocalPath = getConstantLocalPath();
    final String? constantLocalPath =
        (parentVPathMatch.localPath == null && thisConstantLocalPath == null)
            ? null
            : (parentVPathMatch.localPath == null)
                ? thisConstantLocalPath
                : (thisConstantLocalPath == null)
                    ? parentVPathMatch.localPath
                    : parentVPathMatch.localPath! +
                        (parentVPathMatch.localPath!.endsWith('/') ? '' : '/') +
                        thisConstantLocalPath;

    if (parentVPathMatch is ValidVPathMatch) {
      // We try to remove this part of the path from the remainingPathFromParent
      final match =
          selfPathRegExp!.matchAsPrefix(parentVPathMatch.remainingPath);

      if (match == null) {
        return InvalidVPathMatch(
          localPath: constantLocalPath,
          names: parentVPathMatch.names,
        );
      }

      var remainingPath = parentVPathMatch.remainingPath.substring(match.end);
      final localPath =
          parentVPathMatch.remainingPath.substring(match.start, match.end);
      final pathParameters = {
        ...parentVPathMatch.pathParameters,
        ...extract(selfPathParametersKeys, match)
          ..updateAll((key, value) => Uri.decodeComponent(value)),
      };

      // Remove the trailing '/' in remainingPath if needed
      if (remainingPath.startsWith('/'))
        remainingPath = remainingPath.replaceFirst('/', '');

      return ValidVPathMatch(
        remainingPath: remainingPath,
        pathParameters: pathParameters,
        localPath: localPath,
        names: parentVPathMatch.names,
      );
    }

    return InvalidVPathMatch(
      localPath: constantLocalPath,
      names: parentVPathMatch.names,
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
    // A variable to store the new parentPath from the path and aliases
    final List<GetNewParentPathResult> newParentPathResults = [];
    final List<Map<String, String>> newRemainingPathParameters = [];

    final List<GetPathFromNameResult> nameErrorResults = [];

    // Check if any subroute matches the name using path

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
      (path != null && path!.startsWith('/'))
          ? Map<String, String>.from(pathParameters)
          : Map<String, String>.from(remainingPathParameters)
        ..removeWhere((key, value) => pathParametersKeys.contains(key)),
    );

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

    // Check if any subroute matches the name using aliases

    for (var i = 0; i < aliases.length; i++) {
      // Get the new parent path by taking this alias into account
      newParentPathResults.add(getNewParentPath(
        parentPathResult,
        thisPath: aliases[i],
        thisPathParametersKeys: aliasesPathParametersKeys[i],
        pathParameters: pathParameters,
      ));
      newRemainingPathParameters.add(
        (aliases[i].startsWith('/'))
            ? Map<String, String>.from(pathParameters)
            : Map<String, String>.from(remainingPathParameters)
          ..removeWhere(
              (key, value) => aliasesPathParametersKeys[i].contains(key)),
      );
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

    // // If no subroute matches the name, try to match this name
    // if (name == nameToMatch) {
    //   // If path or any alias is valid considering the given path parameters, return this
    //   for (int i = 0; i < newParentPathResults.length; i++) {
    //     var newParentPathResult = newParentPathResults[i];
    //     if (newParentPathResult is ValidParentPathResult) {
    //       if (newParentPathResult.path == null) {
    //         // If this path is null, we add a NullPathErrorNameResult
    //         nameErrorResults.add(NullPathErrorNameResult(name: nameToMatch));
    //       } else {
    //         final newRemainingPathParameter = newRemainingPathParameters[i];
    //         if (newRemainingPathParameter.isNotEmpty) {
    //           // If there are path parameters remaining, wee add a PathParamsErrorsNameResult
    //           nameErrorResults.add(
    //             PathParamsErrorsNameResult(
    //               name: nameToMatch,
    //               values: [
    //                 OverlyPathParamsError(
    //                   pathParams: pathParameters.keys.toList(),
    //                   expectedPathParams: newParentPathResult.pathParameters.keys.toList(),
    //                 ),
    //               ],
    //             ),
    //           );
    //         } else {
    //           // Else the result is valid
    //           return ValidNameResult(path: newParentPathResult.path!);
    //         }
    //       }
    //     } else {
    //       assert(newParentPathResult is PathParamsErrorNewParentPath);
    //       nameErrorResults.add(
    //         PathParamsErrorsNameResult(
    //           name: nameToMatch,
    //           values: [
    //             MissingPathParamsError(
    //               pathParams: pathParameters.keys.toList(),
    //               missingPathParams:
    //                   (newParentPathResult as PathParamsErrorNewParentPath).pathParameters,
    //             ),
    //           ],
    //         ),
    //       );
    //     }
    //   }
    // }

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

  /// The goal is that, considering [thisPath] and [parentPath] we can form a new parentPath
  ///
  /// For more details, see [GetNewParentPathResult]
  GetNewParentPathResult getNewParentPath(
    GetNewParentPathResult parentPathResult, {
    required String? thisPath,
    required List<String> thisPathParametersKeys,
    required Map<String, String> pathParameters,
  }) {
    // First check that we have the path parameters needed to have this path
    final missingPathParameters = thisPathParametersKeys
        .where((key) => !pathParameters.containsKey(key))
        .toList();

    if (missingPathParameters.isNotEmpty) {
      if (thisPath!.startsWith('/')) {
        return PathParamsErrorNewParentPath(
            pathParameters: missingPathParameters);
      } else {
        return PathParamsErrorNewParentPath(
          pathParameters: [
            if (parentPathResult is PathParamsErrorNewParentPath)
              ...parentPathResult.pathParameters,
            ...missingPathParameters
          ],
        );
      }
    }

    if (thisPath == null) {
      // If the path is null, the new parent path is the same as the previous one
      return parentPathResult;
    }

    final localPath =
        replacePathParameters(replaceWildcards(thisPath), pathParameters);
    final thisPathParameters = Map<String, String>.from(pathParameters)
      ..removeWhere((key, value) => !thisPathParametersKeys.contains(key));

    // If the path is absolute
    if (thisPath.startsWith('/')) {
      return ValidParentPathResult(
        path: localPath,
        pathParameters: thisPathParameters,
      );
    }

    // Else the path is relative

    // If the path is relative and the parent path is invalid, then this path is invalid
    if (parentPathResult is PathParamsErrorNewParentPath) {
      return parentPathResult;
    }

    // Else this path is valid
    final parentPathValue =
        (parentPathResult as ValidParentPathResult).path ?? '';
    return ValidParentPathResult(
      path: parentPathValue +
          (!parentPathValue.endsWith('/') ? '/' : '') +
          localPath,
      pathParameters: {
        ...parentPathResult.pathParameters,
        ...thisPathParameters
      },
    );
  }

  VPopResult getPathFromPop(
    VRouteElement elementToPop, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
  }) {
    // If vRouteElement is this, then this is the element to pop so we return null
    if (elementToPop == this) {
      return PoppingPopResult(poppedVRouteElements: [this]);
    }

    final List<GetNewParentPathResult> newParentPaths = [
      getNewParentPath(
        parentPathResult,
        thisPath: path,
        thisPathParametersKeys: pathParametersKeys,
        pathParameters: pathParameters,
      ),
      for (var i = 0; i < aliases.length; i++)
        getNewParentPath(
          parentPathResult,
          thisPath: aliases[i],
          thisPathParametersKeys: aliasesPathParametersKeys[i],
          pathParameters: pathParameters,
        ),
    ];

    for (var vRouteElement in stackedRoutes) {
      final List<MissingPathParamsError> missingPathParamsErrors = [];
      Set<VRouteElement> poppedVRouteElements = Set.of([]);

      for (var newParentPath in newParentPaths) {
        final childPopResult = vRouteElement.getPathFromPop(
          elementToPop,
          pathParameters: pathParameters,
          parentPathResult: newParentPath,
        );
        if (!(childPopResult is NotFoundPopResult)) {
          // If the VRouteElement to pop has been found

          // If it pops, we should pop
          if (childPopResult is PoppingPopResult) {
            // Add ourselves to the poppedVRouteElements in a PoppingPopResult
            return PoppingPopResult(
              poppedVRouteElements:
                  childPopResult.poppedVRouteElements + [this],
            );
          }

          // If ValidPopResult, return as is
          if (childPopResult is ValidPopResult) {
            return childPopResult;
          }

          // Else the childPopResult should be a PathParamsPopErrors
          poppedVRouteElements.addAll(
            (childPopResult as PathParamsPopErrors).poppedVRouteElements,
          );
          missingPathParamsErrors.addAll(childPopResult.values);
        }
      }

      // If missingPathParamsErrors is not empty, it means that we did found the VRouteElement
      // to pop in the current route but no ValidPopResult (only PathParamsPopErrors)
      // So return a PathParamsPopErrors with the aggregated missingPathParamsErrors
      if (missingPathParamsErrors.isNotEmpty) {
        return PathParamsPopErrors(
          poppedVRouteElements: poppedVRouteElements.toList(),
          values: missingPathParamsErrors,
        );
      }
    }

    // If none of the stackedRoutes popped and this did not pop, return a NotValidPopResult
    // This should never reach RootVRouter
    return NotFoundPopResult();
  }

  /// If this [VRouteElement] is in the route but its localPath is null
  /// we try to find a local path in [path, ...aliases]
  ///
  /// This is used in [buildPage] to form the LocalKey
  /// Note that
  ///   - We can't use this because animation won't play if path parameters change for example
  ///   - Using null is not ideal because if we pop from a absolute path, this won't animate as expected
  String? getConstantLocalPath() {
    if (pathParametersKeys.isEmpty) {
      return path;
    }
    for (var i = 0; i < aliasesPathParametersKeys.length; i++) {
      if (aliasesPathParametersKeys[i].isEmpty) {
        return aliases[i];
      }
    }
    return null;
  }
}
