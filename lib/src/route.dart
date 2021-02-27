part of 'main.dart';

class VRoute extends StatefulWidget {
  /// See [VRouteData.pathParameters]
  final Map<String, String> pathParameters;

  /// See [VRouteData.queryParameters]
  final Map<String, String> queryParameters;

  /// The history state that we got back from the browser
  /// If the user navigate using a browser history entry (e.g. browser back button),
  /// and you previously saved a history state, this will have the stored value
  final String? initialHistorySate;

  /// The list of [VPage] of the current route (in a nested structure)
  final List<VPage> pages;

  /// See [VRouterState._navigatorKey] and [VRouterState._heroController]
  /// We need them here because the root navigator uses the same key and
  /// the same HeroController for every route.
  final GlobalKey<NavigatorState> _routerNavigatorKey;
  final HeroController _routerHeroController;

  @override
  final GlobalKey<_VRouteState> key;

  VRoute({
    required this.pathParameters,
    required this.queryParameters,
    required this.pages,
    required GlobalKey<NavigatorState> routerNavigatorKey,
    required HeroController routerHeroController,
    this.initialHistorySate,
  })  : _routerNavigatorKey = routerNavigatorKey,
        _routerHeroController = routerHeroController,
        key = GlobalKey<_VRouteState>();

  @override
  _VRouteState createState() => _VRouteState(historyState: initialHistorySate);
}

class _VRouteState extends State<VRoute> {
  /// See [VRouteData.historyState]
  String? historyState;

  _VRouteState({required this.historyState});

  @override
  Widget build(BuildContext context) {
    return VRouteData(
      historyState: historyState,
      replaceHistoryState: _replaceHistoryState,
      queryParameters: widget.queryParameters,
      pathParameters: widget.pathParameters,
      child: VRouterHelper(
        pages: widget.pages,
        navigatorKey: widget._routerNavigatorKey,
        observers: [widget._routerHeroController],
        backButtonDispatcher: RootBackButtonDispatcher(),
        onPopPage: (_, __) {
          VRouterData.of(context).pop();

          // We always prevent popping because we handle it in VRouter
          return false;
        },
        onSystemPopPage: () async {
          await VRouterData.of(context).systemPop();
          // We always prevent popping because we handle it in VRouter
          return true;
        },
      ),
    );
  }

  /// See [VRouteData.replaceHistoryState]
  void _replaceHistoryState(String newLocalState) {
    if (kIsWeb) {
      final allHistoryStates = BrowserHelpers.getHistoryState() ?? '{}';
      final historyStateMap = jsonDecode(allHistoryStates);
      historyStateMap['-1'] = newLocalState;
      final newAllHistoryState = jsonEncode(historyStateMap);
      BrowserHelpers.replaceHistoryState(newAllHistoryState);
    }
    setState(() {
      historyState = newLocalState;
    });
  }
}

class VRouteData extends InheritedWidget {
  /// This state is saved in the browser history. This means that if the user presses
  /// the back or forward button on the navigator, this historyState will be the same
  /// as the last one you saved.
  ///
  /// It can be changed by using [VRouteData.of(context).replaceHistoryState(newState)]
  ///
  /// Also see:
  ///   * [VRouterData.historyState] if you want to use a router level
  ///      version of the historyState
  ///   * [VRouteElementData.historyState] if you want to use a local
  ///      version of the historyState
  final String? historyState;

  /// This replaces the current history state of this [VRouteData] with given one
  final void Function(String newState) replaceHistoryState;

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

  const VRouteData({
    Key? key,
    required Widget child,
    required this.historyState,
    required this.replaceHistoryState,
    required this.pathParameters,
    required this.queryParameters,
  }) : super(key: key, child: child);

  static VRouteData of(BuildContext context) {
    final vRouteData = context.dependOnInheritedWidgetOfExactType<VRouteData>();
    if (vRouteData == null) {
      throw FlutterError(
          'VRouteData.of(context) was called with a context which does not contain a VRoute.\n'
          'The context used to retrieve VRouteData must be that of a widget that '
          'is a descendant of a VRoute widget.');
    }
    return vRouteData;
  }

  @override
  bool updateShouldNotify(VRouteData old) {
    return historyState != old.historyState ||
        replaceHistoryState != old.replaceHistoryState ||
        pathParameters != old.pathParameters ||
        queryParameters != old.queryParameters;
  }
}

/// A class containing all the informations for a given route
class _VRoutePath {
  /// The path of the route, as a regExp
  /// This can be used to get the parameters of a given url with the
  /// path_to_regexp package
  final RegExp pathRegExp;
  final String path;

  /// List of the name of all parameters of the route
  /// This is used to get the parameters of a given url with the
  /// path_to_regexp package
  final List<String> parameters;

  /// The name of the route is the name of the last [VRouteElement]
  /// of the list of VRouteElements corresponding to this route
  final String? name;

  /// The list (ordered) of the [VRouteElement]s composing this route
  final List<VRouteElement> vRouteElements;

  _VRoutePath({
    this.name,
    required this.pathRegExp,
    required this.path,
    required this.parameters,
    required this.vRouteElements,
  });
}
