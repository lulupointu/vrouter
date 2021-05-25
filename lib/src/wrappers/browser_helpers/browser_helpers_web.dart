@JS()
library web_helpers;

import 'dart:convert';

import 'package:js/js.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

import 'package:vrouter/src/vrouter_core.dart';

/// List of static methods to interact with the browser
/// Only one is implemented for mobile: pushExternal

class BrowserHelpers {
  /// This replace the current history state by the new given one
  ///
  /// Note that flutter uses a map in the browser history and that
  /// only 'state' should be changed
  static void replaceHistoryState(String state) {
    var globalState = html.window.history.state;
    globalState['state'] = state;
    html.window.history.replaceState(globalState, 'flutter', null);
  }

  /// Gets the current history state if any, null otherwise
  static String? getHistoryState() {
    return (html.window.history.state != null)
        ? html.window.history.state['state']
        : null;
  }

  /// We use a custom state entry called 'serialCount'
  /// This is used by this plugin to keep track of where we are
  /// in the browser history
  static int? getHistorySerialCount() {
    if (html.window.history.state == null) {
      return null;
    }
    int? newSerialCount;
    try {
      newSerialCount =
          jsonDecode(html.window.history.state['state'] ?? '{}')['serialCount'];
      // ignore: empty_catches
    } on FormatException {} on TypeError {
      /// Catch and fix error with flutter sdk, see https://github.com/flutter/flutter/issues/78620
      newSerialCount = jsonDecode(html.window.history.state)["serialCount"];
    }
    return newSerialCount;
  }

  /// Gets every part of the url apart from the hostname
  /// If we are in hash mode, we remove the # as well
  ///
  /// Note that this is the url of the browser, which might not be always
  /// in sync with [VRouterData.url]
  static String getPathAndQuery({required VRouterModes routerMode}) {
    return (routerMode == VRouterModes.hash)
        ? html.window.location.hash.isEmpty
            ? html.window.location.hash
            : html.window.location.hash.substring(1)
        : ((html.window.location.pathname ?? '') +
            (html.window.location.search ?? '') +
            html.window.location.hash);
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

  /// This replace the current url by the given one
  /// Meaning that while the url changes, no new history entry is created
  static void pushReplacement(String url, {required VRouterModes routerMode}) =>
      html.window.history.replaceState(html.window.history.state, "",
          (routerMode == VRouterModes.hash) ? '/#$url' : url);

  /// This pushes a url to the browser
  ///
  /// This should rarely be needed has Flutter handles this.
  /// This IS useful when you really need to push a identical url and you want to create a root
  /// entry, since flutter does not allow this
  ///
  /// Note that the new route wont be reported back to flutter
  static void push(
    String url, {
    required VRouterModes routerMode,
    String? state,
  }) {
    var globalState = html.window.history.state;
    globalState['state'] = state ?? '';
    html.window.history.pushState(
        globalState, "", (routerMode == VRouterModes.hash) ? '/#$url' : url);
  }
}
