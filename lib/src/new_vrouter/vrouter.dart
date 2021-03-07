import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vrouter/src/new_vrouter/vroute.dart';
import 'package:vrouter/src/new_vrouter/vrouter_scope.dart';
import 'package:vrouter/src/new_vrouter/vrouter_helper.dart';

import 'vroute_element.dart';

// TODO: write description
class VRouter extends StatefulWidget {
  // TODO: write description
  final List<VRouteElement> routes;

  /// The base path for the routes.
  /// You can use this to customize the base path but you should mainly let it
  /// automatically be retrieved.
  ///
  /// If null, this is retrieved automatically as follows:
  ///     - If this is the root router, the base path is '/'
  ///     - Else it is the part of the path of the parent
  ///           [VRouteElement] which proceeds the ending splat
  ///
  /// Note that it is formatted to start with '/' and end without '/'
  final String? basePath;

  const VRouter({Key? key, required this.routes, this.basePath}) : super(key: key);

  @override
  VRouterState createState() => VRouterState();
}

class VRouterState extends State<VRouter> {
  late Map<String, String> pathParameters;
  late String basePath;

  VRoute? vRoute;

  @override
  Widget build(BuildContext context) {
    // Get the base path
    if (widget.basePath != null) {
      // If a basePath was given to VRouter, take it
      basePath = widget.basePath!;
    } else {
      try {
        // If we are a nested router, the parent path ended with '*'
        // If not it matched perfectly in which case the router's base path is the current path
        final parentPath = VRouterData.of(context).pathParameters['*'] ?? '';
        final path = VRouterScopeData.of(context).path;
        basePath = path.substring(0, path.length - 1 - parentPath.length);

      } on FlutterError {
        // Else we are the first router, the base path is ''
        basePath = '';
      }
    }

    print('Searching for path ${VRouterScopeData.of(context).path} with basePath $basePath');

    // From the path we have, get the potential routes
    final List<VRoute> potentialRoutes = widget.routes.fold(
      [],
      (previousPotentialRoutes, vRouteElement) =>
          previousPotentialRoutes +
          vRouteElement.potentialRoutes(VRouterScopeData.of(context).path, this),
    );

    // If potential route is empty, this must mean that:
    // - Either this route if about to be exited and just used for animation so we 
    //            just display with the vRoute we already have
    // - There was an error in the path, in which case we don't have a previous vRoute so we 
    //            display the error widget if any is given (// TODO: provide a way to customize error widget)
    late VRoute newVRoute;
    if (potentialRoutes.isNotEmpty) {
      // Get the route with the higher path score
      newVRoute = potentialRoutes.fold(
        potentialRoutes[0],
        (highestScoredVRoute, route) =>
            (highestScoredVRoute.pathScore > route.pathScore) ? highestScoredVRoute : route,
      );


      // If the last element is a vRedirector, we shall redirect
      while (newVRoute.route.last is VRedirector) {
        VRedirector vRedirector = newVRoute.route.last as VRedirector;

        VRouterScopeData.of(context).notifyUrlChange(vRedirector.to);

        // From the path we have, get the potential routes
        final List<VRoute> potentialRoutes = widget.routes.fold(
          [],
              (previousPotentialRoutes, vRouteElement) =>
          previousPotentialRoutes +
              vRouteElement.potentialRoutes(vRedirector.to, this),
        );
        // Get the route with the higher path score
        newVRoute = potentialRoutes.fold(
          potentialRoutes[0],
              (highestScoredVRoute, route) =>
          (highestScoredVRoute.pathScore > route.pathScore) ? highestScoredVRoute : route,
        );
      }

      vRoute = newVRoute;
      pathParameters = vRoute!.getPathParameters();
    }

    return VRouterData(
      pathParameters: pathParameters,
      child: VRouterHelper(
        pages: [
          for (var vRouteElement in vRoute!.route)
            if (vRouteElement is VPage)
              vRouteElement.page,
        ],
        onPopPage: (_, __) {
          return false;
        },
      ),
    );
  }
}

/// Holds the information about a router
///
/// Note that those information might not be global, only [VRouterScopeData] hold general information
class VRouterData extends InheritedWidget {
  const VRouterData({
    Key? key,
    required Widget child,
    required this.pathParameters,
  }) : super(key: key, child: child);

  static VRouterData of(BuildContext context) {
    final vRouterData = context.dependOnInheritedWidgetOfExactType<VRouterData>();
    if (vRouterData == null) {
      throw FlutterError(
          'VRouterData.of(context) was called with a context which does not contain a VRouter.\n'
          'The context used to retrieve VRouterData must be that of a widget that '
          'is a descendant of a VRouter widget.');
    }
    return vRouterData;
  }

  final Map<String, String> pathParameters;

  @override
  bool updateShouldNotify(VRouterData old) => true;
}
