import 'dart:convert';

import 'package:vrouter/src/core/vrouter_modes.dart';
import 'package:vrouter/src/wrappers/browser_helpers/browser_helpers.dart';
import 'package:vrouter/src/wrappers/platform/platform.dart';

class VLocations {
  final VRouterModes vRouterMode;

  VLocations({required this.vRouterMode})
      : _serialCount = (Platform.isWeb) ? (BrowserHelpers.getHistorySerialCount() ?? 0) : 0,
        _locations = List<VRouteInformation?>.filled(
                ((Platform.isWeb) ? (BrowserHelpers.getHistorySerialCount() ?? 0) : 0), null) +
            [
              (Platform.isWeb)
                  ? VRouteInformation(
                      location: BrowserHelpers.getPathAndQuery(routerMode: vRouterMode),
                      state: Map<String, String>.from(
                          jsonDecode((BrowserHelpers.getHistoryState() ?? '{}'))),
                    )
                  : null
            ];

  int _serialCount;

  int get serialCount => _serialCount;

  set serialCount(int newSerialCount) {
    assert(0 <= newSerialCount && newSerialCount < _locations.length);
    _serialCount = newSerialCount;
  }

  List<VRouteInformation?> _locations;

  void _addLocation(VRouteInformation routeInformation) {
    _locations = _locations.sublist(0, serialCount + 1) + [routeInformation];
    serialCount++;
  }

  void _replaceLocation(VRouteInformation routeInformation) {
    _locations.removeAt(serialCount);
    _locations = _locations.sublist(0, serialCount) +
        [routeInformation] +
        _locations.sublist(serialCount);
  }

  void setLocationAt(int serialCount, VRouteInformation routeInformation) {
    assert(0 <= serialCount && serialCount <= this.serialCount + 1);
    if (serialCount == this.serialCount + 1) {
      _addLocation(routeInformation);
    } else {
      this.serialCount = serialCount;
      _replaceLocation(routeInformation);
    }
  }

  VRouteInformation get currentLocation => _locations.elementAt(serialCount)!;

  List<VRouteInformation?> get locations => _locations;
}

class VRouteInformation {
  final String location;
  final Map<String, String> state;

  VRouteInformation({required this.location, required this.state});
}
