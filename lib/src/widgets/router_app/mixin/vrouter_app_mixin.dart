import 'package:flutter/widgets.dart';
import 'package:vrouter/src/vlogs.dart';
import 'package:vrouter/src/vrouter_core.dart';
import 'package:vrouter/src/vrouter_scope.dart';
import 'package:vrouter/src/vrouter_vroute_elements.dart';

/// An interface to represent what the widget which state creates
/// the [VRouterDelegate] should implement
abstract class VRouterApp extends StatefulWidget
    with VRouteElement, VRouteElementSingleSubRoute {
  VRouterApp({Key? key}) : super(key: key);

  /// This list holds every possible routes of your app
  List<VRouteElement> get routes;

  /// If implemented, this becomes the default transition for every route transition
  /// except those who implement there own buildTransition
  /// Also see:
  ///   * [VRouteElement.buildTransition] for custom local transitions
  ///
  /// Note that if this is not implemented, every route which does not implement
  /// its own buildTransition will be given a default transition: this of a
  /// [MaterialPage] or a [CupertinoPage] depending on the platform
  Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? get buildTransition;

  /// The duration of [VRouter.buildTransition]
  Duration? get transitionDuration;

  /// The reverse duration of [VRouter.buildTransition]
  Duration? get reverseTransitionDuration;

  /// Two router mode are possible:
  ///    - "hash": This is the default, the url will be serverAddress/#/localUrl
  ///    - "history": This will display the url in the way we are used to, without
  ///       the #. However note that you will need to configure your server to make this work.
  ///       Follow the instructions here: [https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations]
  VRouterMode get mode;

  /// The VRouter logs that are to be shown
  ///
  ///
  /// Most of the logs are navigation event such as
  /// successful navigation
  ///
  ///
  /// Use VLogs to easily set the logs to show:
  ///   - VLogs.none opts out of logs
  ///   - VLogs.info (default) shows every logs
  ///   - VLogs.warning shows only warning logs
  List<VLogLevel> get logs;

  @override
  Future<void> beforeEnter(VRedirector vRedirector) =>
      _beforeEnter(vRedirector);

  Future<void> Function(VRedirector vRedirector) get _beforeEnter;

  @override
  Future<void> beforeLeave(
    VRedirector vRedirector,
    void Function(Map<String, String> historyState) saveHistoryState,
  ) =>
      _beforeLeave(vRedirector, saveHistoryState);

  Future<void> Function(
    VRedirector vRedirector,
    void Function(Map<String, String> historyState) saveHistoryState,
  ) get _beforeLeave;

  @override
  void afterEnter(BuildContext context, String? from, String to) =>
      _afterEnter(context, from, to);

  void Function(BuildContext context, String? from, String to) get _afterEnter;

  @override
  Future<void> onPop(VRedirector vRedirector) => _onPop(vRedirector);

  Future<void> Function(VRedirector vRedirector) get _onPop;

  @override
  Future<void> onSystemPop(VRedirector vRedirector) =>
      _onSystemPop(vRedirector);

  Future<void> Function(VRedirector vRedirector) get _onSystemPop;

  /// This allows you to change the initial url
  ///
  /// The default is '/'
  String get initialUrl;

  /// Use this key to update the [routes]
  ///
  /// If your [routes] should change in a declarative fashion based on some variable,
  /// you should change [appRouterKey] to update [routes]
  /// Note that you should change [appRouterKey] as little as possible
  ///
  /// It will be used in [WidgetsApp] and NOT [WidgetsVRouter]
  /// This is because [WidgetsVRouter] should never update
  Key? get appRouterKey;

  /// A key given to the root navigator
  ///
  ///
  /// This can be used to access a context in which you can call [Navigator]
  ///
  /// This can also be used if you need your [routes] to update, in this case change this key
  /// Note however that you should change [navigatorKey] as little as possible
  GlobalKey<NavigatorState>? get navigatorKey;

  /// {@macro flutter.widgets.widgetsApp.builder}
  ///
  /// Material specific features such as [showDialog] and [showMenu], and widgets
  /// such as [Tooltip], [PopupMenuButton], also require a [Navigator] to properly
  /// function.
  Widget Function(BuildContext context, Widget child)? get builder;

  /// {@macro flutter.widgets.widgetsApp.navigatorObservers}
  List<NavigatorObserver> get navigatorObservers;
}

/// A mixin to use on the [State]s which create the [VRouterDelegate]
mixin VRouterAppStateMixin<T extends VRouterApp> on State<T>
    implements VRouterSailor {
  late VRouterDelegate vRouterDelegate = VRouterDelegate(
    routes: widget.routes,
    builder: widget.builder,
    navigatorObservers: widget.navigatorObservers,
    beforeEnter: widget.beforeEnter,
    beforeLeave: widget.beforeLeave,
    afterEnter: widget.afterEnter,
    onPop: widget.onPop,
    onSystemPop: widget.onSystemPop,
    buildTransition: widget.buildTransition,
    transitionDuration: widget.transitionDuration,
    reverseTransitionDuration: widget.reverseTransitionDuration,
    initialUrl: widget.initialUrl,
    navigatorKey: widget.navigatorKey,
    logs: widget.logs,
  );

  @override
  void didUpdateWidget(covariant T oldWidget) {
    if (oldWidget.appRouterKey != widget.appRouterKey ||
        oldWidget.navigatorKey != widget.navigatorKey) {
      vRouterDelegate = VRouterDelegate(
        routes: widget.routes,
        builder: widget.builder,
        navigatorObservers: widget.navigatorObservers,
        beforeEnter: widget.beforeEnter,
        beforeLeave: widget.beforeLeave,
        afterEnter: widget.afterEnter,
        onPop: widget.onPop,
        onSystemPop: widget.onSystemPop,
        buildTransition: widget.buildTransition,
        transitionDuration: widget.transitionDuration,
        reverseTransitionDuration: widget.reverseTransitionDuration,
        initialUrl: widget.initialUrl,
        navigatorKey: widget.navigatorKey,
        logs: widget.logs,
      );
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  String? get url => vRouterDelegate.url;

  @override
  String? get previousUrl => vRouterDelegate.previousUrl;

  @override
  String? get path => url != null ? Uri.parse(url!).path : null;

  @override
  String? get previousPath => url != null ? Uri.parse(url!).path : null;

  @override
  Map<String, String> get historyState => vRouterDelegate.historyState;

  @override
  Map<String, String> get pathParameters => vRouterDelegate.pathParameters;

  @override
  Map<String, String> get queryParameters => vRouterDelegate.queryParameters;

  @override
  String? get hash =>
      url != null ? Uri.decodeComponent(Uri.parse(url!).fragment) : null;

  @override
  List<String> get names => vRouterDelegate.names;

  @override
  Future<void> pop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> newHistoryState = const {},
  }) async =>
      vRouterDelegate.pop(
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        newHistoryState: newHistoryState,
      );

  @override
  Future<void> systemPop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> newHistoryState = const {},
  }) async =>
      vRouterDelegate.systemPop(
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        newHistoryState: newHistoryState,
      );

  @override
  @Deprecated('Use to (vRouter.to) instead')
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

  @override
  @Deprecated('Use toSegments instead')
  void pushSegments(
    List<String> segments, {
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
  }) =>
      toSegments(
        segments,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
      );

  @override
  @Deprecated('Use toNamed instead')
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
  }) =>
      toNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
      );

  @override
  @Deprecated('Use vRouter.to(..., isReplacement: true) instead')
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
  }) =>
      to(
        newUrl,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
        isReplacement: true,
      );

  @override
  @Deprecated('Use vRouter.toNamed(..., isReplacement: true) instead')
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
  }) =>
      toNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
        isReplacement: true,
      );

  @override
  @Deprecated('Use toExternal instead')
  void pushExternal(String newUrl, {bool openNewTab = false}) =>
      toExternal(newUrl, openNewTab: openNewTab);

  @override
  @Deprecated(
      'Use to(context.vRouter.url!, isReplacement: true, historyState: newHistoryState) instead')
  void replaceHistoryState(Map<String, String> historyState) => to(
        url ?? '/',
        historyState: historyState,
        isReplacement: true,
      );

  @override
  void to(
    String path, {
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
    bool isReplacement = false,
  }) =>
      vRouterDelegate.to(
        path,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
        isReplacement: isReplacement,
      );

  @override
  void toSegments(
    List<String> segments, {
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
    isReplacement = false,
  }) =>
      vRouterDelegate.toSegments(
        segments,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
        isReplacement: isReplacement,
      );

  @override
  void toNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
    bool isReplacement = false,
  }) =>
      vRouterDelegate.toNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
        isReplacement: isReplacement,
      );

  @override
  void toExternal(String newUrl, {bool openNewTab = false}) =>
      vRouterDelegate.toExternal(
        newUrl,
        openNewTab: openNewTab,
      );

  @override
  void historyForward() => vRouterDelegate.historyForward();

  @override
  void historyBack() => vRouterDelegate.historyBack();

  @override
  void historyGo(int delta) => vRouterDelegate.historyGo(delta);

  @override
  bool historyCanForward() => vRouterDelegate.historyCanForward();

  @override
  bool historyCanBack() => vRouterDelegate.historyCanBack();

  @override
  bool historyCanGo(int delta) => vRouterDelegate.historyCanGo(delta);
}
