import 'dart:async';

import 'vurl_history_non_web.dart';
import 'vurl_history_web.dart';

import 'package:vrouter/src/vrouter_scope.dart';
import 'package:vrouter/src/vrouter_scope/vurl_history/vurl_history_web.dart';
import 'package:vrouter/src/wrappers/platform/platform.dart';

import 'vrouter_modes.dart';

/// Contract which describes [VHistory]
abstract class VHistory {
  final VRouterMode vRouterMode;

  factory VHistory.implementation(VRouterMode vRouterMode) => Platform.isWeb
      ? VHistoryWeb(vRouterMode: vRouterMode)
      : VHistoryNonWeb(vRouterMode: vRouterMode);

  VHistory({
    required this.vRouterMode,
    required int initialHistoryIndex,
    required int initialHistoryLength,
    required List<VRouteInformation?> initialLocations,
  })  : _historyIndex = initialHistoryIndex,
        _locations = initialLocations;

  int _historyIndex;

  int get historyIndex => _historyIndex;

  set historyIndex(int newHistoryIndex) {
    assert(0 <= newHistoryIndex && newHistoryIndex < _locations.length);
    _historyIndex = newHistoryIndex;
  }

  List<VRouteInformation?> _locations;

  // /// Changes the location to a new index
  // ///
  // ///
  // /// Note that the location we go to should be already known
  // ///
  // ///
  // /// [vRouteInformation] should be given because the web does
  // /// not allow us to see every location. However if the location
  // /// is already know, it should be equal to the given [vRouteInformation]
  // /// This function should NOT be used to change a [vRouteInformation]
  // Future<void> goToLocationAt(int historyIndex, VRouteInformation vRouteInformation) async {
  //   assert(0 <= historyIndex && historyIndex < locations.length);
  //
  //   this.historyIndex = historyIndex;
  //
  //   assert(
  //   locations[historyIndex] == null ||
  //       (vRouteInformation.location == locations[historyIndex]!.location &&
  //           DeepCollectionEquality().equals(vRouteInformation.state, locations[historyIndex]!.state)),
  //   'This function should NOT be used to change the VRouteInformation',
  //   );
  //
  //   // Insert the route information if it is not known
  //   locations[historyIndex] ??= vRouteInformation;
  // }

  void go(int delta) {
    this.historyIndex += delta;
  }

  void pushLocation(VRouteInformation vRouteInformation) {
    // Amputate the _locations of every VRouteInformation after index historyIndex
    _locations = _locations.sublist(0, historyIndex + 1);

    // Add the new vRouteInformation at the end of the list
    _locations += [vRouteInformation];

    // Place the serial count at the new current url history index
    historyIndex++;
  }

  FutureOr<void> replaceLocation(VRouteInformation vRouteInformation) {
    // Replace the vRouteInformation of the current historyIndex by the given one
    _locations
        .replaceRange(historyIndex, historyIndex + 1, [vRouteInformation]);
  }

  VRouteInformation get currentLocation => _locations.elementAt(historyIndex)!;

  List<VRouteInformation?> get locations => _locations;

  /// Returns a boolean indicating whether the url history position
  /// can be modified by delta (<=0 or >=0)
  bool canGo(int delta) {
    final newHistoryIndex = historyIndex + delta;
    return newHistoryIndex >= 0 && newHistoryIndex < locations.length;
  }

  /// Return the [String] corresponding to the url at the url history
  /// position [historyIndex] + delta
  ///
  ///
  /// If the String cannot be known, return [null]
  ///
  ///
  /// If jumping in the url history by delta is not possible, returns
  /// [HistoryNavigationError]
  ///
  /// To check whether jumping from delta is actually possible, use
  /// [canGo]
  VRouteInformation? vRouteInformationAt(int delta) {
    if (!canGo(delta)) throw HistoryNavigationError(delta: delta);

    return locations[historyIndex + delta];
  }
}

class VRouteInformation {
  final String url;
  final Map<String, String> state;

  VRouteInformation({required this.url, required this.state});
}

class HistoryNavigationError implements Exception {
  final int delta;

  HistoryNavigationError({required this.delta});

  @override
  String toString() =>
      'Tried jumping in the url history by $delta but this is not possible'
      'To check whether it is before going, use [canGo]';
}
