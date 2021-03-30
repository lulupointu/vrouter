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

    // Check if any subroute matches the name using path

    // Get the new parent path by taking this path into account
    newParentPathFromPath = getNewParentPath(parentPath,
        path: path,
        pathParametersKeys: pathParametersKeys,
        pathParameters: pathParameters);

    newRemainingPathParametersFromPath = (path != null && path!.startsWith('/'))
        ? Map<String, String>.from(pathParameters)
        : Map<String, String>.from(remainingPathParameters)
      ..removeWhere((key, value) => pathParametersKeys.contains(key));

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

    // Check if any subroute matches the name using aliases

    for (var i = 0; i < aliases.length; i++) {
      // Get the new parent path by taking this alias into account
      newParentPathFromAliases.add(getNewParentPath(
        parentPath,
        path: aliases[i],
        pathParametersKeys: aliasesPathParametersKeys[i],
        pathParameters: pathParameters,
      ));
      newRemainingPathParametersFromAliases.add(
        (aliases[i].startsWith('/'))
            ? Map<String, String>.from(pathParameters)
            : Map<String, String>.from(remainingPathParameters)
          ..removeWhere(
              (key, value) => aliasesPathParametersKeys[i].contains(key)),
      );
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
      if (newParentPathFromPath != null &&
          newRemainingPathParametersFromPath.isEmpty) {
        return newParentPathFromPath;
      }
      for (var i = 0; i < aliases.length; i++) {
        if (newParentPathFromAliases[i] != null &&
            newRemainingPathParametersFromAliases[i].isEmpty) {
          return newParentPathFromAliases[i];
        }
      }
    }

    // Else we return null
    return null;
  }

  /// The goal is that, considering [path] and [parentPath] we can form a new parentPath
  ///
  /// If this path is null, then the new parentPath is the same as the old one
  /// If this path starts with '/':
  ///     - Either the path parameters from [pathParameters] include those of this path and
  ///       we return the corresponding path
  ///     - Or we return null
  /// If this path does not start with '/':
  ///     - If the parent path is null we return null
  ///     - If the parent path is not null:
  ///         * Either the path parameters from [pathParameters] include those of this path and
  ///             we return the parent path + this path
  ///         * Or we return null
  ///
  /// This method is used in [getPathFromPop]
  String? getNewParentPath(
    String? parentPath, {
    required String? path,
    required List<String> pathParametersKeys,
    required Map<String, String> pathParameters,
  }) {
    // First check that we have the path parameters needed to have this path
    final indexNoMatch = pathParametersKeys
        .indexWhere((key) => !pathParameters.containsKey(key));

    // If we have all the path parameters needed, get the local path
    final localPath = (indexNoMatch == -1 && path != null)
        ? pathToFunction(path)(pathParameters)
        : null;

    late final String? newParentPath;
    if (path == null) {
      // If the path is null, the new parent path is the same as the previous one
      newParentPath = parentPath;
    } else if (path.startsWith('/')) {
      newParentPath = localPath;
    } else if (parentPath == null) {
      // if we don't start with '/' and parent path is null, then newParentPath is also null
      newParentPath = null;
    } else {
      // If localPath is null, the pathParameters did not match so newParentPath is null
      newParentPath = (localPath != null)
          ? parentPath + (!parentPath.endsWith('/') ? '/' : '') + localPath
          : null;
    }

    return newParentPath;
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

    // If the path matched and produced a non null newParentPath, try to pop from the stackedRoutes
    if (newParentPathFromPath != null) {
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
    }

    // Try to match the aliases given the path parameters
    for (var i = 0; i < aliases.length; i++) {
      final newParentPathFromAlias = getNewParentPath(
        parentPath,
        path: aliases[i],
        pathParametersKeys: aliasesPathParametersKeys[i],
        pathParameters: pathParameters,
      );

      // If an alias matched and produced a non null newParentPath, try to pop from the stackedRoutes
      if (newParentPathFromAlias != null) {
        // Try to pop from the stackedRoutes
        for (var vRouteElement in stackedRoutes) {
          final childPopResult = vRouteElement.getPathFromPop(
            elementToPop,
            pathParameters: pathParameters,
            parentPath: newParentPathFromAlias,
          );
          if (childPopResult != null) {
            return GetPathFromPopResult(
                path: childPopResult.path, didPop: false);
          }
        }
      }
    }

    // If none of the stackedRoutes popped and this did not pop, return a null result
    return null;
  }
}

/// Return type for [VRouteElementWithPath.getPathMatch]
class GetPathMatchResult {
  /// The remaining of the path after having remove the part of the path that this
  /// [VRouteElementWithPath] has matched
  final String? remainingPath;

  /// The path parameters of the valid [VRoute] which are
  ///   - Empty if no valid [VRoute] has been found
  ///   - This [VRouteElementWithPath.pathParameters] if [VRouteElement.path] is absolute
  ///   - This [VRouteElementWithPath.pathParameters] and the parent pathParameters if  [VRouteElement.path] is relative
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
