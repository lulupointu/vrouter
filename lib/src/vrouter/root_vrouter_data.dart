part of '../main.dart';

/// An [InheritedWidget] which should not be accessed by end developers
///
/// [RootVRouterData] holds methods and parameters from [VRouterState]
class RootVRouterData extends InheritedWidget {
  final VRouterState _state;

  RootVRouterData({
    Key? key,
    required Widget child,
    required VRouterState state,
    required this.url,
    required this.previousUrl,
    required this.historyState,
    required this.pathParameters,
    required this.queryParameters,
  })   : _state = state,
        super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(RootVRouterData old) {
    return (old.url != url ||
        old.previousUrl != previousUrl ||
        old.historyState != historyState ||
        old.pathParameters != pathParameters ||
        old.queryParameters != queryParameters);
  }

  /// Url currently synced with the state
  /// This url can differ from the once of the browser if
  /// the state has been yet been updated
  final String? url;

  /// Previous url that was synced with the state
  final String? previousUrl;

  /// This state is saved in the browser history. This means that if the user presses
  /// the back or forward button on the navigator, this historyState will be the same
  /// as the last one you saved.
  ///
  /// It can be changed by using [context.vRouter.replaceHistoryState(newState)]
  final Map<String, String> historyState;

  /// Maps all route parameters (i.e. parameters of the path
  /// mentioned as ":someId")
  final Map<String, String> pathParameters;

  /// Contains all query parameters (i.e. parameters after
  /// the "?" in the url) of the current url
  final Map<String, String> queryParameters;

  /// The duration of the transition which happens when this page
  /// is put in the widget tree
  ///
  /// This should be the default one, i.e. the one of [VRouter]
  Duration? get _defaultPageTransitionDuration =>
      _state.widget.transitionDuration;

  /// The duration of the transition which happens when this page
  /// is removed from the widget tree
  ///
  /// This should be the default one, i.e. the one of [VRouter]
  Duration? get _defaultPageReverseTransitionDuration =>
      _state.widget.reverseTransitionDuration;

  /// A function to build the transition to or from this route
  ///
  /// This should be the default one, i.e. the one of [VRouter]git
  Widget Function(Animation<double> animation,
          Animation<double> secondaryAnimation, Widget child)?
      get _defaultPageBuildTransition => _state.widget.buildTransition;

  /// See [VRouterState.push]
  void push(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      _state.push(newUrl,
          queryParameters: queryParameters, historyState: historyState);

  /// See [VRouterState.pushNamed]
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      _state.pushNamed(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          historyState: historyState);

  /// See [VRouterState.pushReplacement]
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      _state.pushReplacement(newUrl,
          queryParameters: queryParameters, historyState: historyState);

  /// See [VRouterState.pushReplacementNamed]
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      _state.pushReplacementNamed(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          historyState: historyState);

  /// See [VRouterState.pushExternal]
  void pushExternal(String newUrl, {bool openNewTab = false}) =>
      _state.pushExternal(newUrl, openNewTab: openNewTab);

  /// See [VRouterState._pop]
  void pop(
    VRouteElement itemToPop, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) =>
      _state._pop(
        itemToPop,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newHistoryState: newHistoryState,
      );

  /// See [VRouterState._systemPop]
  Future<void> systemPop(
    VRouteElement itemToPop, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) =>
      _state._systemPop(
        itemToPop,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newHistoryState: newHistoryState,
      );

  /// See [VRouterState.replaceHistoryState]
  void replaceHistoryState(Map<String, String> historyState) =>
      _state.replaceHistoryState(historyState);

  static RootVRouterData of(BuildContext context) {
    final rootVRouterData =
        context.dependOnInheritedWidgetOfExactType<RootVRouterData>();
    if (rootVRouterData == null) {
      throw FlutterError(
          'RootVRouterData.of(context) was called with a context which does not contain a VRouter.\n'
          'The context used to retrieve RootVRouterData must be that of a widget that '
          'is a descendant of a VRouter widget.');
    }
    return rootVRouterData;
  }
}
