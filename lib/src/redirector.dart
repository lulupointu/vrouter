part of 'main.dart';

/// A class which helps you in beforeLeave or beforeEnter functions
/// This class contain 2 main functionality:
///     1. It allows you to redirect using push, pushNamed, ...
///     2. It gives you access to information about the previous route and the new route
///
/// Note that you should use this object to redirect in beforeLeave and beforeEnter. Never
/// use VRouterData to do so.
class VRedirector {
  VRedirector({
    @required BuildContext context,
    @required this.from,
    @required this.to,
    @required this.previousVRouteData,
    @required this.newVRouteData,
  }) : _context = context;

  /// If [_shouldUpdate] is set to false, the current url updating is stopped
  ///
  /// You should NOT modify this, instead use [stopRedirection], or other methods
  /// such as [push], [pushNamed], ...
  bool _shouldUpdate = true;
  bool get shouldUpdate => _shouldUpdate;

  /// The url we are coming from
  final String from;

  /// The url we are going to
  final String to;

  /// The [VRouteData] of the previous route
  /// Useful information is:
  ///   * [VRouteData.pathParameters]
  ///   * [VRouteData.queryParameters]
  ///   * [VRouteData.historyState]
  ///
  /// Note that you should NOT call [newVRouteData.replaceHistoryState]
  ///   If you are in beforeLeave, call [saveHistoryState] instead
  ///   If you are in beforeEnter, you can't save an history state here
  final VRouteData previousVRouteData;

  /// The [VRouteData] of the new route
  /// Useful information is:
  ///   * [VRouteData.pathParameters]
  ///   * [VRouteData.queryParameters]
  ///   * [VRouteData.historyState]
  ///
  /// Note that you should NOT call [newVRouteData.replaceHistoryState]
  ///   If you are in beforeLeave, call [saveHistoryState] instead
  ///   If you are in beforeEnter, you can't save an history state here
  final VRouteData newVRouteData;

  /// A context which gives us access to VRouter and the current VRoute
  /// This is local because we don't want developers to use VRouterData to redirect
  final BuildContext _context;

  /// Function which will be executed after stopping the redirection
  /// if [push], [pushNamed], ... have been used.
  VoidCallback _redirectFunction;

  /// Stops the redirection
  ///
  /// This also checks that only one method which stops the redirection is used
  void stopRedirection() {
    if (!shouldUpdate) {
      throw 'You already stopped the redirection. You can only use one such action on VRedirector.';
    }
    _shouldUpdate = false;
  }

  /// Prevent the current redirection and push a route instead
  ///
  /// See [VRouterData.push] for more information on push
  void push(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    stopRedirection();
    _redirectFunction = () => VRouterData.of(_context).push(newUrl,
        queryParameters: queryParameters, routerState: routerState);
  }

  /// Prevent the current redirection and pushNamed a route instead
  ///
  /// See [VRouterData.push] for more information on push
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    stopRedirection();
    _redirectFunction = () => VRouterData.of(_context).pushNamed(name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        routerState: routerState);
  }

  /// Prevent the current redirection and pushReplacement a route instead
  ///
  /// See [VRouterData.push] for more information on push
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    stopRedirection();
    _redirectFunction = () => VRouterData.of(_context).pushReplacement(newUrl,
        queryParameters: queryParameters, routerState: routerState);
  }

  /// Prevent the current redirection and pushReplacementNamed a route instead
  ///
  /// See [VRouterData.push] for more information on push
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    stopRedirection();
    _redirectFunction = () => VRouterData.of(_context).pushReplacementNamed(
          name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          routerState: routerState,
        );
  }

  /// Prevent the current redirection and pushExternal instead
  ///
  /// See [VRouterData.push] for more information on push
  void pushExternal(String newUrl, {bool openNewTab = false}) {
    stopRedirection();
    _redirectFunction = () =>
        VRouterData.of(_context).pushExternal(newUrl, openNewTab: openNewTab);
  }

  /// Prevent the current redirection and call pop instead
  ///
  /// See [VRouterData.pop] for more information on push
  void pop() {
    stopRedirection();
    _redirectFunction = () => VRouterData.of(_context).pop();
  }

  /// Prevent the current redirection and call systemPop instead
  ///
  /// See [VRouterData.systemPop] for more information on push
  Future<void> systemPop() async {
    stopRedirection();
    _redirectFunction = () => VRouterData.of(_context).systemPop();
  }
}
