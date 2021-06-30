
import 'package:flutter/widgets.dart';

import 'vrouter_modes.dart';
import 'vurl_history.dart';

/// Implementation of [VUrlHistory] which should be used
/// on every platform which is NOT the web
class VUrlHistoryNonWeb extends VUrlHistory {
  VUrlHistoryNonWeb({
    required VRouterModes vRouterMode,
  }) : super(
          vRouterMode: vRouterMode,
          // Always 0 when the app is started
          initialSerialCount: 0,
          // We use [Navigator.defaultRouteName] to enable mobile deep-linking
          initialLocations: [
            VRouteInformation(
              location: Navigator.defaultRouteName,
              state: {},
            ),
          ],
        );
}
