import 'package:vrouter/src/core/vpop_data.dart';
import 'package:vrouter/src/core/vroute_element_node.dart';
import 'package:vrouter/src/core/vrouter_data.dart';
import 'package:vrouter/src/core/vrouter_delegate.dart';

/// A class which helps you in beforeLeave or beforeEnter functions
/// This class contain 2 main functionality:
///   1. It allows you to redirect using [VRedirector.to], [VRedirector.toNamed], ...
///   2. It gives you access to information about the previous route and the new route
///
/// Note that you should use this object to redirect in beforeLeave and beforeEnter. Never
/// use VRouterData to do so.
class VRedirector implements VRouterNavigator {
  VRedirector({
    required this.fromUrl,
    required this.toUrl,
    required this.previousVRouterData,
    required this.newVRouterData,
    required VRouterDelegate vRouterDelegate,
  }) : _vRouterDelegate = vRouterDelegate;

  VRouterDelegate _vRouterDelegate;

  /// If [_shouldUpdate] is set to false, the current url updating is stopped
  ///
  /// You should NOT modify this, instead use [stopRedirection], or other methods
  /// such as [to], [toNamed], ...
  bool _shouldUpdate = true;

  bool get shouldUpdate => _shouldUpdate;

  /// The url we are coming from
  @Deprecated('Use fromUrl instead')
  String? get from => fromUrl;

  /// The url we are coming from
  final String? fromUrl;

  /// The url we are going to
  final String? toUrl;

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

  /// Function which will be executed after stopping the redirection
  /// if [to], [toNamed], ... have been used.
  void Function(
      {required VRouterDelegate vRouterDelegate,
      required VRouteElementNode vRouteElementNode})? _redirectFunction;

  void Function(
          {required VRouterDelegate vRouterDelegate,
          required VRouteElementNode vRouteElementNode})?
      get redirectFunction => _redirectFunction;

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
  @Deprecated('Use to (vRedirector.to) instead')
  void push(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      to(
        newUrl,
        queryParameters: queryParameters,
        historyState: historyState,
      );

  /// Prevent the current redirection and push a new url based on url segments
  ///
  /// For example: pushSegments(['home', 'bob']) ~ push('/home/bob')
  ///
  /// The advantage of using this over push is that each segment gets encoded.
  /// For example: pushSegments(['home', 'bob marley']) ~ push('/home/bob%20marley')
  ///
  /// Also see:
  ///  - [push] to see want happens when you push a new url
  @Deprecated('Use toSegments (vRedirector.toSegments) instead')
  void pushSegments(
    List<String> segments, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      toSegments(
        segments,
        queryParameters: queryParameters,
        historyState: historyState,
      );

  /// Prevent the current redirection and pushNamed a route instead
  ///
  /// See [VRouter.push] for more information on push
  @Deprecated('Use toNamed (vRedirector.toNamed) instead')
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      toNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        historyState: historyState,
      );

  /// Prevent the current redirection and pushReplacement a route instead
  ///
  /// See [VRouter.push] for more information on push
  @Deprecated('Use to(..., isReplacement: true) instead')
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      to(
        newUrl,
        queryParameters: queryParameters,
        historyState: historyState,
      );

  /// Prevent the current redirection and pushReplacementNamed a route instead
  ///
  /// See [VRouter.push] for more information on push
  @Deprecated('Use toNamed(..., isReplacement: true) instead')
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      toNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        historyState: historyState,
        isReplacement: true,
      );

  /// Prevent the current redirection and pushExternal instead
  ///
  /// See [VRouter.push] for more information on push
  @Deprecated('Use toExternal instead')
  void pushExternal(String newUrl, {bool openNewTab = false}) => toExternal(
        newUrl,
        openNewTab: openNewTab,
      );

  /// Prevent the current redirection and redirects to [path] instead
  ///
  /// See [VRouterData.to] for more information on [to]
  @override
  void to(
    String path, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
    isReplacement = false,
  }) {
    stopRedirection();
    _redirectFunction = ({
      required VRouterDelegate vRouterDelegate,
      required VRouteElementNode vRouteElementNode,
    }) =>
        vRouterDelegate.to(
          path,
          queryParameters: queryParameters,
          historyState: historyState,
          isReplacement: isReplacement,
        );
  }

  /// Prevent the current redirection and redirects to the
  /// external [url] instead
  ///
  /// See [VRouterData.toExternal] for more information on [toExternal]
  @override
  void toExternal(
    String url, {
    bool openNewTab = false,
  }) {
    stopRedirection();
    _redirectFunction = ({
      required VRouterDelegate vRouterDelegate,
      required VRouteElementNode vRouteElementNode,
    }) =>
        vRouterDelegate.toExternal(
          url,
          openNewTab: openNewTab,
        );
  }

  /// Prevent the current redirection and redirects to the VRouteElement
  /// with [name] instead
  ///
  /// See [VRouterData.toNamed] for more information on [toNamed]
  @override
  void toNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
    bool isReplacement = false,
  }) {
    stopRedirection();
    _redirectFunction = ({
      required VRouterDelegate vRouterDelegate,
      required VRouteElementNode vRouteElementNode,
    }) =>
        vRouterDelegate.toNamed(
          name,
          queryParameters: queryParameters,
          historyState: historyState,
          isReplacement: isReplacement,
        );
  }

  /// Prevent the current redirection and redirects to the new path
  /// composed of the url-encoded [segments] instead
  ///
  /// See [VRouterData.toSegments] for more information on [toSegments]
  @override
  void toSegments(
    List<String> segments, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
    isReplacement = false,
  }) {
    stopRedirection();
    _redirectFunction = ({
      required VRouterDelegate vRouterDelegate,
      required VRouteElementNode vRouteElementNode,
    }) =>
        vRouterDelegate.toSegments(
          segments,
          queryParameters: queryParameters,
          historyState: historyState,
          isReplacement: isReplacement,
        );
  }

  @override
  void urlHistoryForward() {
    stopRedirection();
    _redirectFunction = ({
      required VRouterDelegate vRouterDelegate,
      required VRouteElementNode vRouteElementNode,
    }) =>
        vRouterDelegate.urlHistoryForward();
  }

  @override
  void urlHistoryBack() {
    stopRedirection();
    _redirectFunction = ({
      required VRouterDelegate vRouterDelegate,
      required VRouteElementNode vRouteElementNode,
    }) =>
        vRouterDelegate.urlHistoryBack();
  }

  @override
  void urlHistoryGo(int delta) {
    stopRedirection();
    _redirectFunction = ({
      required VRouterDelegate vRouterDelegate,
      required VRouteElementNode vRouteElementNode,
    }) =>
        vRouterDelegate.urlHistoryGo(delta);
  }

  @override
  bool urlHistoryCanForward() => _vRouterDelegate.urlHistoryCanForward();

  @override
  bool urlHistoryCanBack() => _vRouterDelegate.urlHistoryCanBack();

  @override
  bool urlHistoryCanGo(int delta) => _vRouterDelegate.urlHistoryCanGo(delta);

  /// Prevent the current redirection and call pop instead
  ///
  /// See [VRouter.pop] for more information on push
  void pop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) {
    stopRedirection();
    _redirectFunction = ({
      required VRouterDelegate vRouterDelegate,
      required VRouteElementNode vRouteElementNode,
    }) =>
        vRouterDelegate.navigatorKey.currentState!.pop(
          VPopData(
            elementToPop: vRouteElementNode.getVRouteElementToPop(),
            pathParameters: {
              ...pathParameters,
              ...vRouterDelegate
                  .pathParameters, // Include the previous path parameters when popping
            },
            queryParameters: queryParameters,
            newHistoryState: newHistoryState,
          ),
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
    _redirectFunction = ({
      required VRouterDelegate vRouterDelegate,
      required VRouteElementNode vRouteElementNode,
    }) =>
        vRouterDelegate.systemPop(
          // vRouteElementNode.getVRouteElementToPop(),
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          newHistoryState: newHistoryState,
        );
  }

  @override
  @Deprecated(
      'Use to(context.vRouter.url!, isReplacement: true, historyState: newHistoryState) instead')
  void replaceHistoryState(Map<String, String> historyState) => to(
        fromUrl ?? '/',
        historyState: historyState,
        isReplacement: true,
      );
}
