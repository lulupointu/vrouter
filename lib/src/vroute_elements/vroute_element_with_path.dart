part of '../main.dart';

/// If the [VRouteElement] contains a path, it should extend this class
///
/// What is does is:
///   - Requiring attributes [path], [name], [aliases]
///   - Computing attributes [pathRegExp], [aliasesRegExp], [pathParametersKeys] and [aliasesPathParametersKeys]
///   - implementing a default [buildRoute] and [getPathFromName] methods for them
@immutable
abstract class VRouteElementWithPath extends VRouteElement {
  /// The path (relative or absolute) or this [VRouteElement]
  ///
  /// If the path of a subroute is exactly matched, this will be used in
  /// the route but might be covered by another [VRouteElement.widget]
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
  /// '.*' will match any route, '/user/:id(\d+)' will match any route starting with user
  /// and followed by a digit. Here is a recap:
  /// |     pattern 	  | matched path | 	[VRouter.pathParameters]
  /// | /user/:username |  /user/evan  | 	 { username: 'evan' }
  /// | /user/:id(\d+)  |  /user/123   | 	     { id: '123' }
  /// |     .*          |  every path  |             -
  final String? path;

  /// A name for the route which will allow you to easily navigate to it
  /// using [VRouter.of(context).pushNamed]
  ///
  /// Note that [name] should be unique w.r.t every [VRouteElement]
  final String? name;

  /// Alternative paths that will be matched to this route
  ///
  /// Note that path is match first, then every aliases in order
  final List<String> aliases;

  /// A boolean to indicate whether this can be a valid [VRouteElement] of the [VRoute] if no
  /// [VRouteElement] in its [stackedRoute] is matched
  ///
  /// This is mainly useful for [VRouteElement]s which are NOT [VRouteElementWithPage]
  final bool mustMatchStackedRoute;

  /// See [VRouteElement.stackedRoutes]
  final List<VRouteElement> stackedRoutes;

  VRouteElementWithPath({
    required this.path,
    this.name,
    this.stackedRoutes = const [],
    this.aliases = const [],
    this.mustMatchStackedRoute = false,
  })  : pathRegExp = (path != null) ? pathToRegExp(path, prefix: true) : null,
        aliasesRegExp = [
          for (var alias in aliases) pathToRegExp(alias, prefix: true)
        ],
        pathParametersKeys = <String>[],
        aliasesPathParametersKeys =
            List<List<String>>.generate(aliases.length, (_) => []) {
    // Get local parameters
    if (path != null) {
      final localPath = path!.startsWith('/') ? path!.substring(1) : path!;
      pathToRegExp(localPath, parameters: pathParametersKeys);
    }

    for (var i = 0; i < aliases.length; i++) {
      final alias = aliases[i];
      final localPath = alias[i].startsWith('/') ? alias.substring(1) : alias;
      pathToRegExp(localPath, parameters: aliasesPathParametersKeys[i]);
    }
  }

  /// RegExp version of the path
  /// It is created automatically
  /// If the path starts with '/', it is removed from
  /// this regExp.
  final RegExp? pathRegExp;

  /// RegExp version of the aliases
  /// It is created automatically
  /// If an alias starts with '/', it is removed from
  /// this regExp.
  final List<RegExp> aliasesRegExp;

  /// Parameters of the path
  /// It is created automatically
  final List<String> pathParametersKeys;

  /// Parameters of the aliases if any
  /// It is created automatically
  final List<List<String>> aliasesPathParametersKeys;

  /// What this [buildRoute] does is look if any path or alias can give a valid [VRoute]
  /// considering this and the stackedRoutes
  ///
  /// For more about buildRoute, see [VRouteElement.buildRoute]
  @override
  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required String? parentRemainingPath,
    required Map<String, String> parentPathParameters,
  }) {
    // This will hold the GetPathMatchResult for the path so that we compute it only once
    late final GetPathMatchResult pathGetPathMatchResult;

    // This will hold every GetPathMatchResult for the aliases so that we compute them only once
    List<GetPathMatchResult> aliasesGetPathMatchResult = [];

    // Try to find valid VRoute from stackedRoutes

    // Check for the path
    pathGetPathMatchResult = getPathMatch(
      entirePath: vPathRequestData.path,
      remainingPathFromParent: parentRemainingPath,
      selfPath: path,
      selfPathRegExp: pathRegExp,
      selfPathParametersKeys: pathParametersKeys,
      parentPathParameters: parentPathParameters,
    );
    final VRoute? stackedRouteVRoute = getVRouteFromRoutes(
      vPathRequestData,
      routes: stackedRoutes,
      getPathMatchResult: pathGetPathMatchResult,
    );
    if (stackedRouteVRoute != null) {
      return VRoute(
        vRouteElementNode: VRouteElementNode(
          this,
          localPath: pathGetPathMatchResult.localPath,
          stackedVRouteElementNode: stackedRouteVRoute.vRouteElementNode,
        ),
        pages: stackedRouteVRoute.pages,
        pathParameters: stackedRouteVRoute.pathParameters,
        vRouteElements:
            <VRouteElement>[this] + stackedRouteVRoute.vRouteElements,
      );
    }

    // Check for the aliases
    for (var i = 0; i < aliases.length; i++) {
      aliasesGetPathMatchResult.add(
        getPathMatch(
          entirePath: vPathRequestData.path,
          remainingPathFromParent: parentRemainingPath,
          selfPath: aliases[i],
          selfPathRegExp: aliasesRegExp[i],
          selfPathParametersKeys: aliasesPathParametersKeys[i],
          parentPathParameters: parentPathParameters,
        ),
      );
      final VRoute? stackedRouteVRoute = getVRouteFromRoutes(
        vPathRequestData,
        routes: stackedRoutes,
        getPathMatchResult: aliasesGetPathMatchResult[i],
      );
      if (stackedRouteVRoute != null) {
        return VRoute(
          vRouteElementNode: VRouteElementNode(
            this,
            localPath: pathGetPathMatchResult.localPath,
            stackedVRouteElementNode: stackedRouteVRoute.vRouteElementNode,
          ),
          pages: stackedRouteVRoute.pages,
          pathParameters: stackedRouteVRoute.pathParameters,
          vRouteElements:
              <VRouteElement>[this] + stackedRouteVRoute.vRouteElements,
        );
      }
    }

    // Else, if no subroute is valid

    // check if this is an exact match with path
    final vRoute = getVRouteFromSelf(
      vPathRequestData,
      parentPathParameters: parentPathParameters,
      getPathMatchResult: pathGetPathMatchResult,
    );
    if (vRoute != null) {
      return vRoute;
    }

    // Check exact match for the aliases
    for (var i = 0; i < aliases.length; i++) {
      final vRoute = getVRouteFromSelf(
        vPathRequestData,
        parentPathParameters: parentPathParameters,
        getPathMatchResult: aliasesGetPathMatchResult[i],
      );
      if (vRoute != null) {
        return vRoute;
      }
    }

    // Else return null
    return null;
  }

  /// Searches for a valid [VRoute] by asking [VRouteElement]s is [routes] if they can form a valid [VRoute]
  VRoute? getVRouteFromRoutes(
    VPathRequestData vPathRequestData, {
    required List<VRouteElement> routes,
    required GetPathMatchResult getPathMatchResult,
  }) {
    for (var vRouteElement in routes) {
      final childVRoute = vRouteElement.buildRoute(
        vPathRequestData,
        parentRemainingPath: getPathMatchResult.remainingPath,
        parentPathParameters: getPathMatchResult.pathParameters,
      );
      if (childVRoute != null) return childVRoute;
    }
  }

  /// Try to form a [VRoute] where this [VRouteElement] is the last [VRouteElement]
  /// This is possible is:
  ///   - [mustMatchStackedRoute] is false
  ///   - There is a match of the path and it is exact
  VRoute? getVRouteFromSelf(
    VPathRequestData vPathRequestData, {
    required Map<String, String> parentPathParameters,
    required GetPathMatchResult getPathMatchResult,
  }) {
    if (!mustMatchStackedRoute &&
        (getPathMatchResult.remainingPath?.isEmpty ?? false)) {
      return VRoute(
        vRouteElementNode:
            VRouteElementNode(this, localPath: getPathMatchResult.localPath),
        pages: [],
        pathParameters: getPathMatchResult.pathParameters,
        vRouteElements: <VRouteElement>[this],
      );
    }
  }

  /// Returns path information given a local path.
  ///
  /// [entirePath] is the whole path, useful when [selfPathRegExp] is absolute
  /// [remainingPathFromParent] is the path that remain after removing the parent paths, useful when [selfPathRegExp] relative
  /// [selfPathRegExp] the RegExp corresponding to the path that should be tested
  ///
  /// Returns a [GetPathMatchResult] which holds two information:
  ///   - The remaining path, after having removed the [selfPathRegExp] (null if there is no match)
  ///   - The path parameters gotten from [selfPathRegExp] and the path, added to the parentPathParameters if relative path
  GetPathMatchResult getPathMatch({
    required String entirePath,
    required String? remainingPathFromParent,
    required String? selfPath,
    required RegExp? selfPathRegExp,
    required List<String> selfPathParametersKeys,
    required Map<String, String> parentPathParameters,
  }) {
    late final Match? match;

    // remainingPath is null if there is no match
    late String? remainingPath;
    // localPath is null if there is no match
    final String? localPath;
    late final Map<String, String> newPathParameters;
    if (selfPath == null) {
      // This is ugly but the only way to return a non-null empty match...
      match = RegExp('').matchAsPrefix('');
      remainingPath = remainingPathFromParent;
      localPath = '';
      newPathParameters = parentPathParameters;
    } else if ((selfPath.startsWith('/'))) {
      // If our path starts with '/', this is an absolute path
      match = selfPathRegExp!.matchAsPrefix(entirePath);
      remainingPath = (match != null) ? entirePath.substring(match.end) : null;
      localPath =
          (match != null) ? entirePath.substring(match.start, match.end) : null;
      newPathParameters =
          (match != null) ? extract(selfPathParametersKeys, match) : {}
            ..updateAll((key, value) => Uri.decodeComponent(value));
    } else if ((remainingPathFromParent != null)) {
      // If it does not start with '/', the path is relative
      // We try to remove this part of the path from the remainingPathFromParent
      match = selfPathRegExp!.matchAsPrefix(remainingPathFromParent);
      remainingPath =
          (match != null) ? remainingPathFromParent.substring(match.end) : null;
      localPath = (match != null)
          ? remainingPathFromParent.substring(match.start, match.end)
          : null;
      newPathParameters = (match != null)
          ? {
              ...parentPathParameters,
              ...extract(selfPathParametersKeys, match)
                ..updateAll((key, value) => Uri.decodeComponent(value)),
            }
          : {};
    } else {
      // If remainingPathFromParent is null and the path is relative
      // the parent did not match, so there is no match
      match = null;
      remainingPath = null;
      localPath = null;
      newPathParameters = {};
    }

    // Remove the trailing '/' in remainingPath if needed
    if (remainingPath != null && remainingPath.startsWith('/'))
      remainingPath = remainingPath.replaceFirst('/', '');

    return GetPathMatchResult(
      remainingPath: remainingPath,
      pathParameters: newPathParameters,
      localPath: localPath,
    );
  }

  /// Tries to a path from a name
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

    final localPath = pathToFunction(thisPath)(pathParameters);
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

  GetPathFromPopResult getPathFromPop(
    VRouteElement elementToPop, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
  }) {
    // If vRouteElement is this, then this is the element to pop so we return null
    if (elementToPop == this) {
      if (parentPathResult is ValidParentPathResult) {
        return ValidPopResult(path: parentPathResult.path, didPop: true);
      } else if (parentPathResult is PathParamsErrorNewParentPath) {
        return PathParamsPopErrors(
          values: [
            MissingPathParamsError(
              pathParams: pathParameters.keys.toList(),
              missingPathParams: parentPathResult.pathParameters,
            ),
          ],
        );
      } else {
        throw 'Get an unexpected GetNewParentPathResult class: ${parentPathResult.runtimeType}';
      }
    }

    final List<GetPathFromPopResult> childPopResults = [];

    // Try to match the path given the path parameters
    final newParentPathResult = getNewParentPath(
      parentPathResult,
      thisPath: path,
      thisPathParametersKeys: pathParametersKeys,
      pathParameters: pathParameters,
    );

    // If the path matched and produced a non null newParentPath, try to pop from the stackedRoutes
    for (var vRouteElement in stackedRoutes) {
      final childPopResult = vRouteElement.getPathFromPop(
        elementToPop,
        pathParameters: pathParameters,
        parentPathResult: newParentPathResult,
      );
      if (childPopResult is ValidPopResult) {
        return ValidPopResult(path: childPopResult.path, didPop: false);
      } else {
        childPopResults.add(childPopResult);
      }
    }

    // Try to match the aliases given the path parameters
    for (var i = 0; i < aliases.length; i++) {
      final newParentPathResultFromAlias = getNewParentPath(
        parentPathResult,
        thisPath: aliases[i],
        thisPathParametersKeys: aliasesPathParametersKeys[i],
        pathParameters: pathParameters,
      );

      // If an alias matched and produced a non null newParentPath, try to pop from the stackedRoutes
      // Try to pop from the stackedRoutes
      for (var vRouteElement in stackedRoutes) {
        final childPopResult = vRouteElement.getPathFromPop(
          elementToPop,
          pathParameters: pathParameters,
          parentPathResult: newParentPathResultFromAlias,
        );
        if (childPopResult is ValidPopResult) {
          return ValidPopResult(path: childPopResult.path, didPop: false);
        } else {
          childPopResults.add(childPopResult);
        }
      }
    }

    // If we don't have any valid result

    // If some stackedRoute returned PathParamsPopError, aggregate them
    final pathParamsPopErrors = PathParamsPopErrors(
      values: childPopResults.fold<List<MissingPathParamsError>>(
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

/// Return type for [VRouteElementWithPath.getPathMatch]
class GetPathMatchResult {
  /// The remaining of the path after having remove the part of the path that this
  /// [VRouteElementWithPath] has matched
  final String? remainingPath;

  /// The path parameters of the valid [VRoute] which are
  ///   - Empty if no valid [VRoute] has been found
  ///   - This [VRouteElementWithPath.pathParameters] if [VRouteElement.extendedPath] is absolute
  ///   - This [VRouteElementWithPath.pathParameters] and the parent pathParameters if  [VRouteElement.extendedPath] is relative
  final Map<String, String> pathParameters;

  /// The local path is the one of the current VRouteElement
  /// If the path has path parameters, those should be replaced
  final String? localPath;

  GetPathMatchResult({
    required this.remainingPath,
    required this.pathParameters,
    required this.localPath,
  });
}

/// The value of the new parentPath in [VRouteElement.getPathFromPop] and [VRouteElement.getPathFromName]
/// If this path is invalid:
///   - return [ValidGetNewParentPathResult(value: parentPathParameter)]
/// If this path starts with '/':
///   - Either the path parameters from [pathParameters] include those of this path and
///       we return the corresponding path
///   - Or we return [InvalidGetNewParentPathResult(missingPathParameters: this missing path parameters)]
/// If this path does not start with '/':
///   - If the parent path is invalid:
///   _  * [InvalidGetNewParentPathResult(missingPathParameters: parentPathParameterResult.missingPathParameters + this missingPathParameters)]
///   - If the parent path is not invalid:
///   _  * Either the path parameters from [pathParameters] include those of this path and
///             we return [ValidGetNewParentPathResult(the parent path + this path)]
///   _  * Or we return [InvalidGetNewParentPathResult(missingPathParameters: this missing path parameters)]
abstract class GetNewParentPathResult {}

class ValidParentPathResult extends GetNewParentPathResult {
  /// Null is a valid value, it just means that this path is null and the parent one was as well
  final String? path;

  final Map<String, String> pathParameters;

  ValidParentPathResult({required this.path, required this.pathParameters});
}

class PathParamsErrorNewParentPath extends GetNewParentPathResult {
  /// The missing path parameters that prevents us from creating the path
  final List<String> pathParameters;

  PathParamsErrorNewParentPath({required this.pathParameters});
}
