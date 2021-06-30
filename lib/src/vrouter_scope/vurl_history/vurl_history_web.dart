import 'dart:convert';

import 'package:vrouter/src/wrappers/browser_helpers/browser_helpers.dart';

import 'vrouter_modes.dart';
import 'vurl_history.dart';

/// Implementation of [VUrlHistory] which should be used
/// on the web
class VUrlHistoryWeb extends VUrlHistory {
  VUrlHistoryWeb({
    required VRouterModes vRouterMode,
  }) : super(
          vRouterMode: vRouterMode,
          // The serial count might not be 0 (the page might be refreshed)
          initialSerialCount: BrowserHelpers.getHistorySerialCount() ?? 0,
          // We can't get the VRouteInformation except for the history entry we are in
          initialLocations:
              List<VRouteInformation?>.filled(BrowserHelpers.getHistoryLength(), null)
                ..replaceRange(
                  BrowserHelpers.getHistorySerialCount() ?? 0,
                  (BrowserHelpers.getHistorySerialCount() ?? 0) + 1,
                  [
                    VRouteInformation(
                      location: BrowserHelpers.getPathAndQuery(routerMode: vRouterMode),
                      state: Map<String, String>.from(
                        jsonDecode(
                          (BrowserHelpers.getHistoryState() ?? '{}'),
                        ),
                      ),
                    ),
                  ],
                ),
        );
}
