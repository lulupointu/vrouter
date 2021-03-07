import 'package:vrouter/src/new_vrouter/vroute_element.dart';

class VRoute {
  // The list of VRouteElements forming this route
  final List<VRouteElement> route;

  String get path => matchedPath + remainingPath;
  
  // The part of the path that has been matched
  final String matchedPath;
  
  // Path that has not yet been matched or which has been match by a *
  final String remainingPath;

  // // To get the path score, we just sum the scores of the vRouteElements
  // int get pathScore => [for (var vRouteElement in route) vRouteElement.pathScore].fold(
  //       0,
  //       (score, vRouteElementScore) => score + vRouteElementScore,
  //     );

  final int pathScore;

  VRoute({
    required this.route,
    required this.matchedPath,
    required this.pathScore,
    required this.remainingPath,
  });

  Map<String, String> getPathParameters() {
    return {
      for (var vRouteElement in route)
        if (vRouteElement is VPage) ...vRouteElement.pathParameters
    };
  }
}
