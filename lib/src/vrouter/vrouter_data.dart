part of '../main.dart';

abstract class VRouterData extends InheritedWidget {
  VRouterData({Key? key, required Widget child}) : super(key: key, child: child);


  /// Url currently synced with the state
  /// This url can differ from the once of the browser if
  /// the state has been yet been updated
  String?  get url;

  /// Previous url that was synced with the state
  String?  get  previousUrl;

  /// This state is saved in the browser history. This means that if the user presses
  /// the back or forward button on the navigator, this historyState will be the same
  /// as the last one you saved.
  ///
  /// It can be changed by using [context.vRouter.replaceHistoryState(newState)]
  Map<String, String>  get  historyState;

  /// Maps all route parameters (i.e. parameters of the path
  /// mentioned as ":someId")
  Map<String, String>  get  pathParameters;

  /// Contains all query parameters (i.e. parameters after
  /// the "?" in the url) of the current url
  Map<String, String>  get  queryParameters;

  /// See [VRouterState.push]
  void push(
      String newUrl, {
        Map<String, String> queryParameters = const {},
        Map<String, String> historyState = const {},
      });

  /// See [VRouterState.pushNamed]
  void pushNamed(
      String name, {
        Map<String, String> pathParameters = const {},
        Map<String, String> queryParameters = const {},
        Map<String, String> historyState = const {},
      });

  /// See [VRouterState.pushReplacement]
  void pushReplacement(
      String newUrl, {
        Map<String, String> queryParameters = const {},
        Map<String, String> historyState = const {},
      });

  /// See [VRouterState.pushReplacementNamed]
  void pushReplacementNamed(
      String name, {
        Map<String, String> pathParameters = const {},
        Map<String, String> queryParameters = const {},
        Map<String, String> historyState = const {},
      });

  /// See [VRouterState.pushExternal]
  void pushExternal(String newUrl, {bool openNewTab = false});

  /// See [VRouterState._pop]
  void pop(
      {
        Map<String, String> pathParameters = const {},
        Map<String, String> queryParameters = const {},
        Map<String, String> newHistoryState = const {},
      });

  /// See [VRouterState._systemPop]
  Future<void> systemPop(
      {
        Map<String, String> pathParameters = const {},
        Map<String, String> queryParameters = const {},
        Map<String, String> newHistoryState = const {},
      });

  /// See [VRouterState.replaceHistoryState]
  void replaceHistoryState(Map<String, String> historyState);
}