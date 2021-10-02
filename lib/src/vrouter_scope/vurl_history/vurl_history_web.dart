import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:vrouter/src/wrappers/browser_helpers/browser_helpers.dart';

import 'vrouter_modes.dart';
import 'vurl_history.dart';

/// Implementation of [VHistory] which should be used
/// on the web
class VHistoryWeb extends VHistory {
  /// An ID which identifies this application instance
  final int applicationInstanceId;

  VHistoryWeb({
    required VRouterMode vRouterMode,
  })  : applicationInstanceId = _getInitialApplicationInstanceId(),
        super(
          vRouterMode: vRouterMode,
          // The serial count might not be 0 (the page might be refreshed)
          initialHistoryIndex: _getInitialHistoryIndex(),
          // The initialHistoryLength might not be 1 (the page might be refreshed)
          initialHistoryLength: _getInitialHistoryLength(
            applicationInstanceId: _getInitialApplicationInstanceId(),
          ),
          // We can't get the VRouteInformation except for the history entry we are in
          initialLocations: _initialLocations(
            historyIndex: _getInitialHistoryIndex(),
            vRouterMode: vRouterMode,
          ),
        );

  static List<VRouteInformation?> _initialLocations({
    required int historyIndex,
    required VRouterMode vRouterMode,
  }) {
    return List<VRouteInformation?>.generate(
        _getInitialHistoryLength(
          applicationInstanceId: _getInitialApplicationInstanceId(),
        ),
        (int i) => i == historyIndex
            ? VRouteInformation(
                url: BrowserHelpers.getPathAndQuery(routerMode: vRouterMode),
                state: _getInitialHistoryState(),
              )
            : null);
  }

  static int _getInitialHistoryLength({required int applicationInstanceId}) {
    late int historyLength;
    try {
      historyLength = BrowserHelpers.getHistoryLength(
        applicationInstanceId: applicationInstanceId,
      );
    } on Exception {
      // We get an exception if the applicationInstanceId does not already exist
      historyLength = 1;
      BrowserHelpers.setHistoryLength(
        applicationInstanceId: applicationInstanceId,
        historyLength: historyLength,
      );
    }

    return historyLength;
  }

  static Map<String, String> _getInitialHistoryState() {
    late Map<String, String> historyState;
    try {
      historyState = BrowserHelpers.getAppHistoryState();
    } on Exception {
      // We get an exception if the applicationInstanceId does not already exist
      historyState = {};
      BrowserHelpers.setAppHistoryState(historyState);
    }

    return historyState;
  }

  static int _getInitialApplicationInstanceId() {
    late int applicationInstanceId;
    try {
      applicationInstanceId = BrowserHelpers.getApplicationInstanceId();
    } on Exception {
      // We get an exception if the applicationInstanceId does not already exist
      applicationInstanceId = Random().nextInt(10000000);
      BrowserHelpers.setApplicationInstanceId(applicationInstanceId);
    }

    return applicationInstanceId;
  }

  static int _getInitialHistoryIndex() {
    late int historyIndex;
    try {
      historyIndex = BrowserHelpers.getHistoryIndex();
    } on Exception {
      // We get an exception if the historyIndex has never been set, if which case
      // this is a new app so it should be 0
      historyIndex = 0;
      BrowserHelpers.setHistoryIndex(historyIndex);
    }

    return historyIndex;
  }

  @override
  void pushLocation(VRouteInformation vRouteInformation) {
    // Pushes the location in _locations and increases the serial count
    super.pushLocation(vRouteInformation);

    // At this point we don't know if the browser is synced
    // Is the browser already pushed, the historyIndex should not be accessible
    late final bool isBrowserSynced;
    try {
      isBrowserSynced = BrowserHelpers.getHistoryIndex() == historyIndex;
    } on Exception {
      isBrowserSynced = true;
    }

    // Save the url
    BrowserHelpers.pushUrl(
      Uri.parse(vRouteInformation.url).toString(),
      routerMode: vRouterMode,
      isReplacement: isBrowserSynced,
    );

    // Save the appHistoryState
    BrowserHelpers.setAppHistoryState(vRouteInformation.state);

    // Save the historyIndex
    BrowserHelpers.setHistoryIndex(historyIndex);

    // Save the new history length
    BrowserHelpers.setHistoryLength(
      applicationInstanceId: applicationInstanceId,
      historyLength: locations.length,
    );

    // Save applicationInstanceId
    BrowserHelpers.setApplicationInstanceId(applicationInstanceId);
  }

  @override
  FutureOr<void> replaceLocation(VRouteInformation vRouteInformation) async {
    super.replaceLocation(vRouteInformation);

    await _doWhileBrowserInSync(() {
      // Save the url
      BrowserHelpers.pushUrl(
        Uri.parse(vRouteInformation.url).toString(),
        routerMode: vRouterMode,
        isReplacement: true,
      );

      // Save the appHistoryState
      BrowserHelpers.setAppHistoryState(vRouteInformation.state);
    });
  }

  // @override
  // Future<void> syncBrowser() async {
  //   await super.syncBrowser();
  //
  //   final browserHistoryIndex = BrowserHelpers.getHistoryIndex();
  //
  //   if (browserHistoryIndex != historyIndex) {
  //     BrowserHelpers.browserGo(historyIndex - browserHistoryIndex);
  //     await BrowserHelpers.onBrowserPopState.firstWhere((element) {
  //       return BrowserHelpers.getHistoryIndex() == historyIndex;
  //     });
  //   }
  // }

  Future<void> _doWhileBrowserInSync(VoidCallback action) async {
    final browserHistoryIndex = BrowserHelpers.getHistoryIndex();

    // Ensure browser in sync
    if (browserHistoryIndex != historyIndex) {
      BrowserHelpers.browserGo(historyIndex - browserHistoryIndex);
      await BrowserHelpers.onBrowserPopState.firstWhere((element) {
        return BrowserHelpers.getHistoryIndex() == historyIndex;
      });
    }

    // Action
    action();

    assert(
      BrowserHelpers.getHistoryIndex() == historyIndex,
      'doWhileBrowserInSync was called with an action which modified the browser historyIndex, this should never happen',
    );

    // Put browser in its original state
    if (browserHistoryIndex != historyIndex) {
      BrowserHelpers.browserGo(browserHistoryIndex - historyIndex);
      await BrowserHelpers.onBrowserPopState.firstWhere((element) {
        return BrowserHelpers.getHistoryIndex() == browserHistoryIndex;
      });
    }
  }
}
