export 'vurl_history_non_web.dart' if (dart.library.js) 'vurl_history_web.dart';
export 'vrouter_modes.dart';

import 'package:vrouter/src/vrouter_scope.dart';
import 'package:vrouter/src/vrouter_scope/vurl_history/vurl_history_web.dart';
import 'package:vrouter/src/wrappers/platform/platform.dart';

import 'vrouter_modes.dart';

/// Contract which describes [VUrlHistory]
abstract class VUrlHistory {
  final VRouterModes vRouterMode;

  factory VUrlHistory.implementation(VRouterModes vRouterMode) => Platform.isWeb
      ? VUrlHistoryWeb(vRouterMode: vRouterMode)
      : VUrlHistoryNonWeb(vRouterMode: vRouterMode);

  VUrlHistory(
      {required this.vRouterMode,
      required int initialSerialCount,
      required List<VRouteInformation?> initialLocations})
      : _serialCount = initialSerialCount,
        _locations = initialLocations;

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

  /// Returns a boolean indicating whether the url history position
  /// can be modified by delta (<=0 or >=0)
  bool canGo(int delta) {
    final newSerialCount = serialCount + delta;
    return newSerialCount >= 0 && newSerialCount < locations.length;
  }

  /// Return the [String] corresponding to the url at the url history
  /// position [serialCount] + delta
  ///
  ///
  /// If the String cannot be known, return [null]
  ///
  ///
  /// If jumping in the url history by delta is not possible, returns
  /// [UrlHistoryNavigationError]
  ///
  /// To check whether jumping from delta is actually possible, use
  /// [conGo]
  String? go(int delta) {
    if (!canGo(delta)) throw UrlHistoryNavigationError(delta: delta);

    serialCount += delta;

    return locations[serialCount]?.location;
  }
}

class VRouteInformation {
  final String location;
  final Map<String, String> state;

  VRouteInformation({required this.location, required this.state});
}

class UrlHistoryNavigationError implements Exception {
  final int delta;

  UrlHistoryNavigationError({required this.delta});

  @override
  String toString() => 'Tried jumping in the url history by $delta but this is not possible'
      'To check whether it is before going, use [canGo]';
}
