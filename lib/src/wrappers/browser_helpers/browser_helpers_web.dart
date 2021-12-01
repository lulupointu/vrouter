// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:vrouter/src/vrouter_core.dart';
import 'package:vrouter/src/vrouter_scope.dart';

/// List of static methods to interact with the browser
/// Only one is implemented for mobile: pushExternal

class BrowserHelpers {
  /// Gets every part of the url apart from the hostname
  /// If we are in hash mode, we remove the # as well
  /// Always starts with '/'
  ///
  /// Note that this is the url of the browser, which might not be always
  /// in sync with [VRouterSailor.url]
  static String getPathAndQuery({required VRouterMode routerMode}) {
    // If the mode is hash, it's easy we just take whatever is after the hash
    if (routerMode == VRouterMode.hash) {
      return html.window.location.hash.isEmpty
          ? ''
          : html.window.location.hash.substring(1);
    }

    // else, we have to be careful with the basePath

    // Get the entire url (http...)
    final entireUrl = _getEntireUrl();

    // Remove the basePath
    final basePath = _getBasePath();
    final pathAndQuery = (basePath.length <
            entireUrl.length) // This might happen during first app startup
        ? entireUrl.substring(basePath.length)
        : '';

    return pathAndQuery.startsWith('/') ? pathAndQuery : '/$pathAndQuery';
  }

  /// Allows us to tell the browser to navigate in the browser history
  static void browserGo(int delta) => html.window.history.go(delta);

  /// Fires an event when the url changes
  static Stream<html.PopStateEvent> get onBrowserPopState =>
      html.window.onPopState;

  /// Fires an event when a page will be unloaded
  ///
  /// This mainly occurs when a user types a url in the browser on closes the browser
  static Stream<html.Event> get onBrowserBeforeUnload =>
      html.window.onBeforeUnload;

  /// Pushes a url which is from another website
  ///
  /// If [openNewTab] is true, this url in opened in a new tab
  static Future<void> pushExternal(String url,
      {required bool openNewTab}) async {
    final targetUrl = url.startsWith('http') ? url : 'http://$url';
    if (openNewTab) {
      html.window.open(targetUrl, '_blank');
    } else {
      html.window.location.href = targetUrl;
    }
  }

  /// This pushes a url to the browser
  ///
  ///
  ///
  /// Note that the new route WONT be reported back to flutter
  static void pushUrl(
    String url, {
    required VRouterMode routerMode,
    required bool isReplacement,
  }) {
    // Either push or replace depending on [isReplacement]
    final historyMethod = isReplacement
        ? html.window.history.replaceState
        : html.window.history.pushState;

    historyMethod(
      html.window.history.state, // Note that we don't change the historyState
      'flutter',
      _getBasePath() +
          ((routerMode == VRouterMode.hash) ? '#/' : '') +
          (url.startsWith('/') ? url.substring(1) : url),
    );
  }

  /// Returns the base path (ending with a '/')
  ///
  /// The base path is:
  ///   protocol + '//' + host + basePath (uri from the first <base> tag)
  static String _getBasePath() {
    final baseTags = html.document.getElementsByTagName('base');

    return baseTags.isEmpty ? '/' : (baseTags[0].baseUri ?? '/');
  }

  /// Returns the entire url
  static String _getEntireUrl() => html.window.location.href;

  /// Get the number of history entries for this app
  ///
  ///
  /// Note that this is NOT the history length of the browser
  static int getHistoryLength({required int applicationInstanceId}) {
    final String? historyLengthString =
        html.window.localStorage['$applicationInstanceId'];

    if (historyLengthString == null) {
      throw Exception('Tried to get historyLength but it has not been set');
    }

    return int.parse(historyLengthString);
  }

  /// Set the number of history entries for this app
  ///
  ///
  /// Note that this is NOT the history length of the browser
  static void setHistoryLength({
    required int applicationInstanceId,
    required int historyLength,
  }) {
    html.window.localStorage
        .addAll({'$applicationInstanceId': '$historyLength'});
  }

  /// This replace the current history state by the new given one
  ///
  /// Note that flutter uses a map in the browser history and that
  /// only 'state' should be changed
  static void setAppHistoryState(Map<String, String> state) {
    final historyState = _getHistoryState();
    historyState['app'] = state;
    _setHistoryState(historyState);
  }

  static Map<String, String> getAppHistoryState() {
    final Map<String, String>? appHistoryState =
        (_getHistoryState()['app'] as Map<dynamic, dynamic>?)?.map(
      (key, value) => MapEntry(
        key.toString(),
        value.toString(),
      ),
    );

    if (appHistoryState == null) {
      throw Exception('Tried to get appHistoryState but it has not been set');
    }

    return appHistoryState;
  }

  static void setHistoryIndex(int historyIndex) {
    final historyState = _getHistoryState();
    historyState['historyIndex'] = historyIndex;
    _setHistoryState(historyState);
  }

  /// We use a custom state entry called 'historyIndex'
  /// This is used by this plugin to keep track of where we are
  /// in the browser history
  static int getHistoryIndex() => _getHistoryState()['historyIndex'] ?? 0;

  static void setApplicationInstanceId(int applicationInstanceId) {
    final historyState = _getHistoryState();
    historyState['applicationInstanceId'] = applicationInstanceId;
    _setHistoryState(historyState);
  }

  static int getApplicationInstanceId() {
    final int? applicationInstanceId =
        _getHistoryState()['applicationInstanceId'];

    if (applicationInstanceId == null) {
      throw Exception(
          'Tried to get applicationInstanceId but it has not been set');
    }
    return applicationInstanceId;
  }

  static Map<String, dynamic> _getHistoryState() {
    var globalState = html.window.history.state;

    // If no history state has ever been created and
    // Flutter has not been initialized
    if (globalState == null) {
      return <String, dynamic>{};
    }

    // If globalState is NOT null but globalState['state'] is null
    // Flutter has just hot reloaded and is therefore globalState['state']
    // was placed in globalState
    if (!globalState.containsKey('state') || globalState['state'] == null) {
      return _mapDynamicDynamicToMapStringDynamic(globalState);
    }

    // If a history state exist and Flutter has restored it
    return _mapDynamicDynamicToMapStringDynamic(globalState['state']);
  }

  static void _setHistoryState(Map<String, dynamic> historyState) {
    var globalState = html.window.history.state ?? <String, dynamic>{};

    // If Flutter has not yet restored the history state
    if (!globalState?.containsKey('state')) {
      return html.window.history.replaceState(historyState, 'flutter', null);
    }

    // If a history state exist and Flutter has restored it
    globalState['state'] = historyState;
    globalState['serialCount'] =
        0; // Reset to 0 to avoid issues with flutter hot reload
    return html.window.history.replaceState(globalState, 'flutter', null);
  }

  static Map<String, dynamic> _mapDynamicDynamicToMapStringDynamic(
          Map<dynamic, dynamic> map) =>
      map.map((key, value) => MapEntry(key.toString(), value));
}
