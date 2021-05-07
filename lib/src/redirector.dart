part of 'main.dart';

/// A class which helps you in beforeLeave or beforeEnter functions
/// This class contain 2 main functionality:
///   1. It allows you to redirect using [VRedirector.push], [VRedirector.pushNamed], ...
///   2. It gives you access to information about the previous route and the new route
///
/// Note that you should use this object to redirect in beforeLeave and beforeEnter. Never
/// use VRouterData to do so.
class VRedirector {
  VRedirector({
    required BuildContext context,
    required this.from,
    required this.to,
    required this.previousVRouterData,
    required this.newVRouterData,
  }) : _context = context;

  /// If [_shouldUpdate] is set to false, the current url updating is stopped
  ///
  /// You should NOT modify this, instead use [stopRedirection], or other methods
  /// such as [push], [pushNamed], ...
  bool _shouldUpdate = true;

  bool get shouldUpdate => _shouldUpdate;

  /// The url we are coming from
  final String? from;

  /// The url we are going to
  final String? to;

  /// The [VRouterData] of the previous route
  /// Useful information is:
  ///   * [VRouterData.pathParameters]
  ///   * [VRouterData.queryParameters]
  ///   * [VRouterData.historyState]
  ///
  /// Note that you should NOT call [newVRouterData.replaceHistoryState]
  ///   If you are in beforeLeave, call [saveHistoryState] instead
  ///   If you are in beforeEnter, you can't save an history state here
  final RootVRouterData? previousVRouterData;

  /// The [VRouterData] of the new route
  /// Useful information is:
  ///   * [VRouterData.pathParameters]
  ///   * [VRouterData.queryParameters]
  ///   * [VRouterData.historyState]
  ///
  /// Note that you should NOT call [newVRouterData.replaceHistoryState]
  ///   If you are in beforeLeave, call [saveHistoryState] instead
  ///   If you are in beforeEnter, you can't save an history state here
  final RootVRouterData? newVRouterData;

  /// A context which gives us access to VRouter and the current VRoute
  /// This is local because we don't want developers to use VRouterData to redirect
  final BuildContext _context;

  /// Function which will be executed after stopping the redirection
  /// if [push], [pushNamed], ... have been used.
  void Function(VRouteElementNode vRouteElementNode)? _redirectFunction;

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
  /// See [VRouter.push] for more information on push
  void push(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) {
    stopRedirection();
    _redirectFunction = (_) => RootVRouterData.of(_context).push(newUrl,
        queryParameters: queryParameters, historyState: historyState);
  }


  /// Prevent the current redirection and push a new url based on url segments
  ///
  /// For example: pushSegments(['home', 'bob']) ~ push('/home/bob')
  ///
  /// The advantage of using this over push is that each segment gets encoded.
  /// For example: pushSegments(['home', 'bob marley']) ~ push('/home/bob%20marley')
  ///
  /// Also see:
  ///  - [push] to see want happens when you push a new url
  void pushSegments(
      List<String> segments, {
        Map<String, String> queryParameters = const {},
        Map<String, String> historyState = const {},
      }) {
    // Forming the new url by encoding each segment and placing "/" between them
    final newUrl = segments.map((segment) => Uri.encodeComponent(segment)).join('/');

    // Calling push with this newly formed url
    return push(newUrl, queryParameters: queryParameters, historyState: historyState);
  }

  /// Prevent the current redirection and pushNamed a route instead
  ///
  /// See [VRouter.push] for more information on push
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) {
    stopRedirection();
    _redirectFunction = (_) => RootVRouterData.of(_context).pushNamed(name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        historyState: historyState);
  }

  /// Prevent the current redirection and pushReplacement a route instead
  ///
  /// See [VRouter.push] for more information on push
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) {
    stopRedirection();
    _redirectFunction = (_) => RootVRouterData.of(_context).pushReplacement(
        newUrl,
        queryParameters: queryParameters,
        historyState: historyState);
  }

  /// Prevent the current redirection and pushReplacementNamed a route instead
  ///
  /// See [VRouter.push] for more information on push
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) {
    stopRedirection();
    _redirectFunction =
        (_) => RootVRouterData.of(_context).pushReplacementNamed(
              name,
              pathParameters: pathParameters,
              queryParameters: queryParameters,
              historyState: historyState,
            );
  }

  /// Prevent the current redirection and pushExternal instead
  ///
  /// See [VRouter.push] for more information on push
  void pushExternal(String newUrl, {bool openNewTab = false}) {
    stopRedirection();
    _redirectFunction = (_) => RootVRouterData.of(_context)
        .pushExternal(newUrl, openNewTab: openNewTab);
  }

  /// Prevent the current redirection and call pop instead
  ///
  /// See [VRouter.pop] for more information on push
  void pop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) {
    stopRedirection();
    _redirectFunction = (VRouteElementNode vRouteElementNode) =>
        RootVRouterData.of(_context).popFromElement(
          vRouteElementNode.getVRouteElementToPop(),
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          newHistoryState: newHistoryState,
        );
  }

  /// Prevent the current redirection and call systemPop instead
  ///
  /// See [VRouter.systemPop] for more information on push
  Future<void> systemPop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) async {
    stopRedirection();
    _redirectFunction = (VRouteElementNode vRouteElementNode) =>
        RootVRouterData.of(_context).systemPopFromElement(
          vRouteElementNode.getVRouteElementToPop(),
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          newHistoryState: newHistoryState,
        );
  }
}
