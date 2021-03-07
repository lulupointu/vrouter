import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vrouter/src/new_vrouter/vroute.dart';
import 'package:vrouter/src/new_vrouter/vrouter.dart';

abstract class VRouteElement {
  /// The subroutes of this [VRouteElement]
  ///
  /// Every subroute path is relative to the one of this [VRouteElement]
  List<VRouteElement> get subroutes;

  /// The list of the keys corresponding to the path parameters of [path]
  late final List<String> pathParametersKeys;

  /// The path in its RegExp form
  ///
  /// every * have been replaced by (.*)
  /// every :pathParam have been replaced by (.*?)(?=[\/]|$)
  late final RegExp pathRegExp;

  /// The path of this route
  /// It is always relative to the parent [VPage] or (if no parent
  /// [VPage]) [VRouter.basePath]
  ///
  /// It cannot be empty
  /// If you want to match the parent route, use "/"
  /// If you want to match anything use a splat (*). A splat can only be used at the end of
  /// the path
  ///
  /// Note that this path will always be formatted to start with a "/" and to end without a "/"
  final String path;

  /// The list of the pathParameters
  ///
  /// It will be re-populated each time "potentialRoutes" is called
  Map<String, String> pathParameters = {};

  // TODO: describe this
  final int pathScore;

  VRouteElement({
    required this.path,
  }) : pathScore = 5 +
            [for (var pathSegment in path.split('/')) pathSegmentToScore(pathSegment)].fold(
              0,
              (score, segmentScore) => score + segmentScore,
            ) {
    pathParametersKeys = []; // This is filled when instantiating pathRegExp

    final pathSegments = path.split('/');
    final List<String> pathSegmentsRegExpString = [
      for (var pathSegment in pathSegments) pathSegmentsToRegExpString(pathSegment)
    ];

    pathRegExp = RegExp(pathSegmentsRegExpString.join('/'));
  }

  List<VRoute> potentialRoutes(
    String path,
    VRouterState parentVRouterState, {
    VRoute? parentVRoute,
  });

  /// Matches the path parameters (e.g ":id" or "book:id")
  final pathParametersToRegexp = RegExp(r'(:.*?)(?=$)');

  /// Matches the splat at the end of a string (e.g "route/* or "/book*")
  final splatRegExp = RegExp(r'(\*.*?)(?=$)');

  String pathSegmentsToRegExpString(String pathSegment) {
    var outputPath = pathSegment;

    // Replace path parameters
    final stringPathParameterMatch = pathParametersToRegexp.stringMatch(pathSegment);
    if (stringPathParameterMatch != null) {
      pathParametersKeys.add(stringPathParameterMatch);
      outputPath = outputPath.replaceFirst(stringPathParameterMatch, r'(.*?)(?=[\/]|$)');
    }

    // Replace splat
    final stringSplatMatch = splatRegExp.stringMatch(pathSegment);
    if (stringSplatMatch != null) {
      pathParametersKeys.add(stringSplatMatch);
      outputPath = outputPath.replaceFirst(stringSplatMatch, r'(.*?)(?=[\/]|$)');
    }

    return outputPath;
  }

  static int pathSegmentToScore(String pathSegment) =>
      4 +
      (pathSegment.isEmpty
          ? 1
          : pathSegment.startsWith(':')
              ? 2
              : pathSegment.endsWith('*')
                  ? -1
                  : 3);
}

class VPage extends VRouteElement {
  /// The widget that will be displayed if this path matches
  final Page page;

  @override
  final List<VRouteElement> subroutes;

  VPage({required String path, required this.page, this.subroutes = const []})
      : super(path: path);

  // /// Get the every routes from this and its subroute which match the given path
  // ///
  // /// This function is in charge of resetting and populating [pathParameters]
  // ///
  // /// The path given here must be an absolute path
  // List<VRoute> potentialRoutes(
  //   String path,
  //   VRouterState parentVRouterState, {
  //   VRoute? parentVRoute,
  // }) {
  //   List<VRoute> potentialRoutes = [];
  //   pathParameters = {};
  //
  //   print(
  //       'Searching potentialRoutes for path $path with path ${this.path}, basePath ${parentVRouterState.basePath} and parentVRoute route ${parentVRoute?.route}');
  //
  //   // Since [path] is a local path, we first find the absolute path corresponding
  //   // to this route
  //   late final RegExp thisAbsolutePath;
  //   if (this.path.startsWith('/')) {
  //     // If the path starts with "/", the path is relative to the base path
  //     thisAbsolutePath = RegExp(parentVRouterState.basePath + this.path);
  //   } else {
  //     // Else it is relative to the parent path
  //     thisAbsolutePath = RegExp(parentVRouterState.basePath +
  //         '/' +
  //         (parentVRoute?.path ?? '') +
  //         this.pathRegExp.pattern);
  //   }
  //
  //   // Get the path match if any
  //   final pathMatch = thisAbsolutePath.matchAsPrefix(path);
  //
  //   // If there is no match, return an empty string
  //   if (pathMatch == null) {
  //     return [];
  //   }
  //
  //   // If there is a match, get the path parameters
  //   pathParameters = {
  //     for (var keyIndex = 0; keyIndex < pathParametersKeys.length; keyIndex++) ...{
  //       pathParametersKeys[keyIndex]: pathMatch.group(keyIndex + 1)!
  //     }
  //   };
  //
  //   // If the match is exact, we add this a VRoute ending with this VRouteElement
  //   // to the potential routes
  //   if (pathMatch.end == path.length) {
  //     potentialRoutes.add(VRoute(
  //         route: (parentVRoute?.route ?? []) + [this],
  //         path: (parentVRoute?.path ?? '') + this.path));
  //   }
  //
  //   // Check in the subroutes if there are potential routes
  //   for (var route in subroutes) {
  //     potentialRoutes.addAll(route.potentialRoutes(path, parentVRouterState));
  //   }
  //
  //   return potentialRoutes;
  // }

  List<VRouteElement> geti(VRoute parentVRoute) {
      pathParameters = {};

      late int localPathScore;

      if (this.path.startsWith('/')) {
        // Get the path match if any
        final pathMatch = this.path.matchAsPrefix(parentVRoute.path);

        // If no match, just check the children
        if (pathMatch == null) {
          localPathScore = 0;
        } else {

        }

      }

      // Since [path] is a local path, we first find the absolute path corresponding
      // to this route
      late final RegExp thisAbsolutePath;
      if (this.path.startsWith('/')) {
        // If the path starts with "/", the path is relative to the base path
        thisAbsolutePath = RegExp(parentVRouterState.basePath + this.path);
      } else {
        // Else it is relative to the parent path
        thisAbsolutePath = RegExp(parentVRouterState.basePath +
            '/' +
            (parentVRoute?.matchedPath ?? '') +
            this.pathRegExp.pattern);
      }

      // Get the path match if any
      final pathMatch = thisAbsolutePath.matchAsPrefix(path);

      // If there is no match, return an empty string
      if (pathMatch == null) {
        return [];
      }

      // If there is a match, get the path parameters
      pathParameters = {
        for (var keyIndex = 0; keyIndex < pathParametersKeys.length; keyIndex++) ...{
          pathParametersKeys[keyIndex]: pathMatch.group(keyIndex + 1)!
        }
      };

      // If the match is exact, we add this a VRoute ending with this VRouteElement
      // to the potential routes
      if (pathMatch.end == path.length) {
        potentialRoutes.add(VRoute(
            route: (parentVRoute?.route ?? []) + [this],
            matchedPath: (parentVRoute?.matchedPath ?? '') + this.path));
      }

      // Check in the subroutes if there are potential routes
      for (var route in subroutes) {
        potentialRoutes.addAll(route.potentialRoutes(path, parentVRouterState));
      }

      return potentialRoutes;
  }
}

class VWidget extends VPage {
  /// The widget that will be displayed if this path matches
  final Widget child;

  @override
  final List<VRouteElement> subroutes;

  VWidget({required String path, required this.child, this.subroutes = const []})
      : super(
          path: path,
          page: MaterialPage(child: child, key: ValueKey(path)),
        );
}

class VRedirector extends VRouteElement {
  final String path;
  final String to;

  VRedirector({required this.path, required this.to}) : super(path: path);

  @override
  List<VRoute> potentialRoutes(String path, VRouterState parentVRouterState,
      {VRoute? parentVRoute}) {
    List<VRoute> potentialRoutes = [];

    print(
        'potentialRoutes with path $path, basePath ${parentVRouterState.basePath} and parentVRoute route ${parentVRoute?.route}');

    // Since [path] is a local path, we first find the absolute path corresponding
    // to this route
    late final RegExp thisAbsolutePath;
    if (this.path == '/') {
      // If the path is "/", we match the parent path
      thisAbsolutePath = RegExp(parentVRouterState.basePath + (parentVRoute?.matchedPath ?? ''));
    } else {
      thisAbsolutePath = RegExp(
          parentVRouterState.basePath + (parentVRoute?.matchedPath ?? '') + this.pathRegExp.pattern);
    }

    // Get the path match if any
    final pathMatch = thisAbsolutePath.matchAsPrefix(path);

    // If there is no match, return an empty string
    if (pathMatch == null) {
      return [];
    }

    // If the match is exact, we add this a VRoute ending with this VRouteElement
    // to the potential routes
    if (pathMatch.end == path.length) {
      potentialRoutes.add(VRoute(
          route: (parentVRoute?.route ?? []) + [this],
          matchedPath: (parentVRoute?.matchedPath ?? '') + this.path));
    }

    return potentialRoutes;
  }

  @override
  List<VRouteElement> get subroutes => [];
}

class VRedirect extends Error {
  final String to;

  VRedirect(this.to);
}
