part of 'main.dart';

/// For each [VRouteElement], a [RouteElementWidget] will be inserted
/// in the widget tree
///
/// This class handles the [VRouteElementData] which gives you local
/// information about the [VRouteElement]
class RouteElementWidget extends StatefulWidget {
  /// See [VRouteElementData.vChild]
  final Widget? vChild;

  /// See [VRouteElementData.vChildName]
  final String? vChildName;

  /// See [VRouteElementData.name]
  final String? name;

  /// See [VRouteElementData.pathParameters]
  final Map<String, String> pathParameters;

  /// See [VRouteElementData.child]
  final Widget? child;

  final Function? childBuilder;

  /// The key which allows us to access the state of this widget
  final GlobalKey<_RouteElementWidgetState>? stateKey;

  /// The history state that we got back from the browser
  /// If the user navigate using a browser history entry, and
  /// you previously saved a history state, this will have this value
  /// Otherwise this will be null.
  final String? initialHistorySate;

  /// The depth from the start of the route
  /// This is used to save and restore the historyState
  final int depth;

  const RouteElementWidget({
    required this.pathParameters,
    required this.depth,
    this.child,
    this.childBuilder,
    this.vChild,
    this.vChildName,
    this.name,
    this.stateKey,
    this.initialHistorySate,
  }) : super(key: stateKey);

  @override
  _RouteElementWidgetState createState() =>
      _RouteElementWidgetState(historyState: initialHistorySate);
}

class _RouteElementWidgetState extends State<RouteElementWidget> {
  /// List of all the [VNavigationGuard] which are associated to the [VRouteElement]
  List<VNavigationGuardMessage> vNavigationGuardMessages = [];

  /// See [VRouteElementData.historyState]
  String? historyState;

  _RouteElementWidgetState({this.historyState});

  @override
  Widget build(BuildContext context) {
    return NotificationListener<VNavigationGuardMessage>(
      // This listen to [VNavigationGuardNotification] which is a notification
      // that a [VNavigationGuard] sends when it is created
      // When this happens, we store the VNavigationGuard and its context
      // This will be used to call its afterUpdate and beforeLeave in particular.
      onNotification: (VNavigationGuardMessage vNavigationGuardMessage) {
        vNavigationGuardMessages.removeWhere((message) =>
            message.vNavigationGuard.key ==
            vNavigationGuardMessage.vNavigationGuard.key);
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          setState(() {
            vNavigationGuardMessages.add(vNavigationGuardMessage);
          });
        });

        return true;
      },
      child: VRouteElementData(
        child: widget.child ?? widget.childBuilder!(context),
        pathParameters: widget.pathParameters,
        name: widget.name,
        vChild: widget.vChild,
        vChildName: widget.vChildName,
        replaceHistoryState: _replaceHistoryState,
        historyState: historyState,
      ),
    );
  }

  /// See [VRouteElementData.replaceHistoryState]
  void _replaceHistoryState(String newLocalState) {
    if (kIsWeb) {
      final allHistoryStates = BrowserHelpers.getHistoryState() ?? '{}';
      final historyStateMap =
          Map<String, String?>.from(jsonDecode(allHistoryStates));
      historyStateMap['${widget.depth}'] = newLocalState;
      final newAllHistoryState = jsonEncode(historyStateMap);
      BrowserHelpers.replaceHistoryState(newAllHistoryState);
    }
    setState(() {
      historyState = newLocalState;
    });
  }
}

class VRouteElementData extends InheritedWidget {
  /// If the subroute [VRouteElement] is [VChild], then you can
  /// access it using this attribute
  /// Note that the type of this vChild is not the same as the widget you
  /// placed in [VChild.widget]. Is you need to identify this vChild, use
  /// the name attribute of this [VChild] (see [vChildName])
  final Widget? vChild;

  /// This is the name, if given, of the [VChild] of the subroute
  /// This is useful when you might have different vChild in the same
  /// subroute and you want to know which one is currently active
  /// without looking at the url
  final String? vChildName;

  /// The name you gave in the [VRouteElement]
  final String? name;

  /// The pathParameters of this [VRouteElement]
  /// Example:
  ///     * Parent [VRouteElement.path] = /games
  ///     * this [VRouteElement.path] = 'user/:id'
  ///     * The current url is /games/user/123
  ///     Then [VRouteElement.pathParameters] = {'id': '123'}
  final Map<String, String> pathParameters;

  /// This state is saved in the browser history. This means that if the user presses
  /// the back or forward button on the navigator, this historyState will be the same
  /// as the last one you saved.
  ///
  /// It can be changed by using [VRouteElementWidgetData.of(context).replaceHistoryState(newState)]
  ///
  /// Also see:
  ///   * [VRouterData.historyState] if you want to use a router level
  ///      version of the historyState
  ///   * [VRouteData.historyState] if you want to use a route level
  ///      version of the historyState
  final String? historyState;

  /// This replaces the current history state of this [VRouteElementData] with given one
  final void Function(String newState) replaceHistoryState;

  /// DON'T use this to access a [VChild], instead use the [vChild] attribute
  @protected
  @override
  final Widget child;

  VRouteElementData({
    Key? key,
    required this.pathParameters,
    required this.replaceHistoryState,
    required this.child,
    this.vChild,
    this.vChildName,
    this.name,
    this.historyState,
  }) : super(key: key, child: child);

  static VRouteElementData of(BuildContext context) {
    final vRouteElementWidgetData =
        context.dependOnInheritedWidgetOfExactType<VRouteElementData>();
    if (vRouteElementWidgetData == null) {
      throw FlutterError(
          'VRouteElementWidgetData.of(context) was called with a context which does not contain a VRouteElementWidgetData.\n'
          'The context used to retrieve VRouteElementWidgetData must be that of a widget that '
          'is a descendant of a VRouteElementWidgetData widget.');
    }
    return vRouteElementWidgetData;
  }

  @override
  bool updateShouldNotify(VRouteElementData old) => (old.vChild != vChild ||
      old.vChildName != vChildName ||
      old.name != name ||
      old.pathParameters != pathParameters ||
      old.historyState != historyState);
}
