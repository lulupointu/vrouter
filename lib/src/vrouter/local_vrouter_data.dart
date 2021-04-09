part of '../main.dart';

/// An [InheritedWidget] accessible via [VRouter.of(context)]
///
/// [LocalVRouterData] is placed on top of each [VRouteElement.widget], the main goal of having
/// local classes compared to a single one is that:
///   1. [_vRouteElementNode] is specific to the local [VRouteElement] to allow a different
///   _  pop event based on where the [VRouteElement] is in the [VRoute]
///   2. When a [VRouteElement] is no longer in the route, it has a page animation out. During
///   _  this, the old VRouterData should be used, which this [LocalVRouterData] holds
class LocalVRouterData extends VRouterData {
  /// The [VRouteElementNode] of the associated [VRouteElement]
  final VRouteElementNode _vRouteElementNode;

  /// A [BuildContext] which can be used to access the [RootVRouterData]
  final BuildContext _rootVRouterDataContext;

  LocalVRouterData({
    Key? key,
    required Widget child,
    required this.url,
    required this.previousUrl,
    required this.historyState,
    required this.pathParameters,
    required this.queryParameters,
    required VRouteElementNode vRouteElementNode,
    required BuildContext context,
  })   : _vRouteElementNode = vRouteElementNode,
        _rootVRouterDataContext = context,
        super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(LocalVRouterData old) {
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
  /// It can be changed by using [VRouteElementWidgetData.of(context).replaceHistoryState(newState)]
  ///
  /// Also see:
  ///   * [VRouteElementData.historyState] if you want to use a local level
  ///      version of the historyState
  ///   * [VRouterData.historyState] if you want to use a router level
  ///      version of the historyState
  final Map<String, String> historyState;

  /// Maps all route parameters (i.e. parameters of the path
  /// mentioned as ":someId")
  /// Note that if you have multiple parameters with the same
  /// name, only the last one will be visible here
  /// However every parameters is passed locally to VRouteElementWidgetData
  /// so you should find them there.
  /// See [VRouteElementData.pathParameters]
  final Map<String, String> pathParameters;

  /// Contains all query parameters (i.e. parameters after
  /// the "?" in the url) of the current url
  final Map<String, String> queryParameters;

  /// Pushes the new route of the given url on top of the current one
  /// A path can be of one of two forms:
  ///   * stating with '/', in which case we just navigate
  ///     to the given path
  ///   * not starting with '/', in which case we append the
  ///     current path to the given one
  ///
  /// We can also specify queryParameters, either by directly
  /// putting them is the url or by providing a Map using [queryParameters]
  ///
  /// We can also put a state to the next route, this state will
  /// be a router state (this is the only kind of state that we can
  /// push) accessible with VRouter.of(context).historyState
  void push(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      RootVRouterData.of(_rootVRouterDataContext).push(newUrl,
          queryParameters: queryParameters, historyState: historyState);

  /// Updates the url given a [VRouteElement] name
  ///
  /// We can also specify path parameters to inject into the new path
  ///
  /// We can also specify queryParameters, either by directly
  /// putting them is the url or by providing a Map using [queryParameters]
  ///
  /// We can also put a state to the next route, this state will
  /// be a router state (this is the only kind of state that we can
  /// push) accessible with VRouter.of(context).historyState
  ///
  /// After finding the url and taking charge of the path parameters,
  /// it updates the url
  ///
  /// To specify a name, see [VRouteElement.name]
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      RootVRouterData.of(_rootVRouterDataContext).pushNamed(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          historyState: historyState);

  /// Replace the current one by the new route corresponding to the given url
  /// The difference with [push] is that this overwrites the current browser history entry
  /// If you are on mobile, this is the same as push
  /// Path can be of one of two forms:
  ///   * stating with '/', in which case we just navigate
  ///     to the given path
  ///   * not starting with '/', in which case we append the
  ///     current path to the given one
  ///
  /// We can also specify queryParameters, either by directly
  /// putting them is the url or by providing a Map using [queryParameters]
  ///
  /// We can also put a state to the next route, this state will
  /// be a router state (this is the only kind of state that we can
  /// push) accessible with VRouter.of(context).historyState
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      RootVRouterData.of(_rootVRouterDataContext).pushReplacement(newUrl,
          queryParameters: queryParameters, historyState: historyState);

  /// Replace the url given a [VRouteElement] name
  /// The difference with [pushNamed] is that this overwrites the current browser history entry
  ///
  /// We can also specify path parameters to inject into the new path
  ///
  /// We can also specify queryParameters, either by directly
  /// putting them is the url or by providing a Map using [queryParameters]
  ///
  /// We can also put a state to the next route, this state will
  /// be a router state (this is the only kind of state that we can
  /// push) accessible with VRouter.of(context).historyState
  ///
  /// After finding the url and taking charge of the path parameters
  /// it updates the url
  ///
  /// To specify a name, see [VRouteElementWithPath.name]
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      RootVRouterData.of(_rootVRouterDataContext).pushReplacementNamed(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          historyState: historyState);

  /// Goes to an url which is not in the app
  ///
  /// On the web, you can set [openNewTab] to true to open this url
  /// in a new tab
  void pushExternal(String newUrl, {bool openNewTab = false}) =>
      RootVRouterData.of(_rootVRouterDataContext)
          .pushExternal(newUrl, openNewTab: openNewTab);

  /// Starts a pop cycle
  ///
  /// Pop cycle:
  ///   1. onPop is called in all [VWidgetGuard]s
  ///   2. onPop is called in the nested-most [VRouteElement] of the current route
  ///   3. onPop is called in [VRouter]
  ///   4. Default behaviour of pop is called: [VRouterState._defaultPop]
  ///
  /// In any of the above steps, we can use [vRedirector] if you want to redirect or
  /// stop the navigation
  void pop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) =>
      RootVRouterData.of(_rootVRouterDataContext).popFromElement(
        _vRouteElementNode.getVRouteElementToPop(),
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newHistoryState: newHistoryState,
      );

  /// Starts a systemPop cycle
  ///
  /// systemPop cycle:
  ///   1. onSystemPop is called in all VWidgetGuards
  ///   2. onSystemPop is called in the nested-most VRouteElement of the current route
  ///   3. onSystemPop is called in VRouter
  ///   4. [pop] is called
  ///
  /// In any of the above steps, we can use [vRedirector] if you want to redirect or
  /// stop the navigation
  Future<void> systemPop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) =>
      RootVRouterData.of(_rootVRouterDataContext).systemPopFromElement(
        _vRouteElementNode.getVRouteElementToPop(),
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newHistoryState: newHistoryState,
      );

  /// This replaces the current history state of [VRouter] with given one
  void replaceHistoryState(Map<String, String> historyState) =>
      RootVRouterData.of(_rootVRouterDataContext)
          .replaceHistoryState(historyState);

  static LocalVRouterData of(BuildContext context) {
    final localVRouterData =
        context.dependOnInheritedWidgetOfExactType<LocalVRouterData>();
    if (localVRouterData == null) {
      throw FlutterError(
          'LocalVRouter.of(context) was called with a context which does not contain a LocalVRouterData.\n'
          'The context used to retrieve LocalVRouterData must be that of a widget that '
          'is a descendant of a LocalVRouterData widget.');
    }
    return localVRouterData;
  }
}
