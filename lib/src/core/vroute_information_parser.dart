import 'package:flutter/widgets.dart';

class VRouteInformationParser extends RouteInformationParser<RouteInformation> {
  // Url to navigation state
  @override
  Future<RouteInformation> parseRouteInformation(
      RouteInformation routeInformation) async {
    return routeInformation;
  }

  // Navigation state to url
  @override
  RouteInformation? restoreRouteInformation(
      RouteInformation? routeInformation) {
    return routeInformation;
  }
}
