import 'package:url_launcher/url_launcher.dart';
import 'package:vrouter/src/vrouter_scope.dart';

/// List of static methods to interact with the browser
/// Only one is implemented for mobile: pushExternal

class BrowserHelpers {
  /// Gets every part of the url apart from the hostname
  /// If we are in hash mode, we remove the # as well
  /// Always starts with '/'
  ///
  /// Note that this is the url of the browser, which might not be always
  /// in sync with [VRouterData.url]
  static String getPathAndQuery({required VRouterMode routerMode}) =>
      throw (Exception('getPathAndQuery should only be used on the web'));

  /// Allows us to tell the browser to navigate in the browser history
  static void browserGo(int delta) =>
      throw (Exception('browserGo should only be used on the web'));

  /// Fires an event when the url changes
  static Stream get onBrowserPopState =>
      throw (Exception('onBrowserPopState should only be used on the web'));

  /// Fires an event when a page will be unloaded
  ///
  /// This mainly occurs when a user types a url in the browser on closes the browser
  static Stream get onBrowserBeforeUnload =>
      throw (Exception('onBrowserBeforeUnload should only be used on the web'));

  /// This uses the launch method from the [url_launcher] package to open a given link
  /// [openNewTab] does nothing here since we open a window anyway
  static Future<void> pushExternal(
    String url, {
    required bool openNewTab,
  }) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception('Could not launch $url');
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
  }) =>
      throw (Exception('pushUrl should only be used on the web'));

  /// Get the number of history entries for this app
  ///
  ///
  /// Note that this is NOT the history length of the browser
  static int getHistoryLength({required int applicationInstanceId}) =>
      throw (Exception('getHistoryLength should only be used on the web'));

  /// Set the number of history entries for this app
  ///
  ///
  /// Note that this is NOT the history length of the browser
  static void setHistoryLength({
    required int applicationInstanceId,
    required int historyLength,
  }) =>
      throw (Exception('setHistoryLength should only be used on the web'));

  /// This replace the current history state by the new given one
  ///
  /// Note that flutter uses a map in the browser history and that
  /// only 'state' should be changed
  static void setAppHistoryState(Map<String, String> state) =>
      throw (Exception('setAppHistoryState should only be used on the web'));

  static Map<String, String> getAppHistoryState() =>
      throw (Exception('getAppHistoryState should only be used on the web'));

  static void setHistoryIndex(int historyIndex) =>
      throw (Exception('setHistoryIndex should only be used on the web'));

  /// We use a custom state entry called 'historyIndex'
  /// This is used by this plugin to keep track of where we are
  /// in the browser history
  static int getHistoryIndex() =>
      throw (Exception('getHistoryIndex should only be used on the web'));

  static void setApplicationInstanceId(int applicationInstanceId) =>
      throw (Exception(
          'setApplicationInstanceId should only be used on the web'));

  static int getApplicationInstanceId() => throw (Exception(
      'getApplicationInstanceId should only be used on the web'));
}
