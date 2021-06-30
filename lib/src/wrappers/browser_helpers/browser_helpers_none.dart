import 'package:url_launcher/url_launcher.dart';
import 'package:vrouter/src/vrouter_core.dart';
import 'package:vrouter/src/vrouter_scope.dart';

/// List of static methods to interact with the browser
/// Only one is implemented for mobile: pushExternal

class BrowserHelpers {
  /// This is used to reset flutter serialCount in the history state to 0
  ///
  /// This is needed to allow path restoration on hot reload on flutter web
  static void resetFlutterSerialCount() =>
      throw (Exception('replaceHistoryState should only be used on the web'));

  static void replaceHistoryState(String state) =>
      throw (Exception('replaceHistoryState should only be used on the web'));

  static String? getHistoryState() =>
      throw (Exception('getHistoryState should only be used on the web'));

  static int? getHistorySerialCount() =>
      throw (Exception('getHistorySerialCount should only be used on the web'));

  static String getPathAndQuery({required VRouterModes routerMode}) =>
      throw (Exception('getHistorySerialCount should only be used on the web'));

  static void browserGo(int delta) =>
      throw (Exception('browserGo should only be used on the web'));

  static Stream get onBrowserPopState =>
      throw (Exception('onBrowserPopState should only be used on the web'));

  static Stream get onBrowserBeforeUnload =>
      throw (Exception('onBrowserBeforeUnload should only be used on the web'));

  /// This uses the launch method from the [url_launcher] package to open a given link
  /// [openNewTab] does nothing here since we open a window anyway
  static Future<void> pushExternal(String url,
      {required bool openNewTab}) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw Exception('Could not launch $url');
    }
  }

  static void pushReplacement(
    String url, {
    required VRouterModes routerMode,
    required String state,
  }) =>
      throw (Exception('pushReplacement should only be used on the web'));

  static void push(
    String url, {
    required VRouterModes routerMode,
    String? state,
  }) =>
      throw (Exception('push should only be used on the web'));

  static int getHistoryLength() =>
      throw (Exception('getHistoryLength should only be used on the web'));
}
