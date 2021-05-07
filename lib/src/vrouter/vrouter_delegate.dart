part of '../main.dart';

class VRouterDelegate extends RouterDelegate<RouteInformation> with ChangeNotifier {
  /// This list holds every possible routes of your app
  final List<VRouteElement> routes;

  /// If implemented, this becomes the default transition for every route transition
  /// except those who implement there own buildTransition
  /// Also see:
  ///   * [VRouteElement.buildTransition] for custom local transitions
  ///
  /// Note that if this is not implemented, every route which does not implement
  /// its own buildTransition will be given a default transition: this of a
  /// [MaterialPage] or a [CupertinoPage] depending on the platform
  final Widget Function(
          Animation<double> animation, Animation<double> secondaryAnimation, Widget child)?
      buildTransition;

  /// The duration of [VRouter.buildTransition]
  final Duration? transitionDuration;

  /// The reverse duration of [VRouter.buildTransition]
  final Duration? reverseTransitionDuration;

  /// Two router mode are possible:
  ///    - "hash": This is the default, the url will be serverAddress/#/localUrl
  ///    - "history": This will display the url in the way we are used to, without
  ///       the #. However note that you will need to configure your server to make this work.
  ///       Follow the instructions here: [https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations]
  final VRouterModes mode;

  /// This allows you to change the initial url
  ///
  /// The default is '/'
  final String initialUrl;

  /// {@macro flutter.widgets.widgetsApp.navigatorObservers}
  final List<NavigatorObserver> navigatorObservers;

  /// This is a context which contains the VRouter.
  /// It is used is VRouter.beforeLeave for example.
  late BuildContext _rootVRouterContext;

  /// Designates the number of page we navigated since
  /// entering the app.
  /// If is only used in the web to know where we are when
  /// the user interacts with the browser instead of the app
  /// (e.g back button)
  late int _serialCount;

  /// When set to true, urlToAppState will be ignored
  /// You must manually reset it to true otherwise it will
  /// be ignored forever.
  bool _ignoreNextBrowserCalls = false;

  /// When set to false, appStateToUrl will be "ignored"
  /// i.e. no new history entry will be created
  /// You must manually reset it to true otherwise it will
  /// be ignored forever.
  bool _doReportBackUrlToBrowser = true;

  /// Build widget before the pages
  /// The context can be used to access VRouter.of
  final TransitionBuilder? builder;

  VRouterDelegate({
    required this.routes,
    this.builder,
    this.navigatorObservers = const [],
    Future<void> Function(VRedirector vRedirector) beforeEnter = VGuard._voidBeforeEnter,
    Future<void> Function(
      VRedirector vRedirector,
      void Function(Map<String, String> historyState) saveHistoryState,
    )
        beforeLeave = VGuard._voidBeforeLeave,
    void Function(BuildContext context, String? from, String to) afterEnter =
        VGuard._voidAfterEnter,
    Future<void> Function(VRedirector vRedirector) onPop = VPopHandler._voidOnPop,
    Future<void> Function(VRedirector vRedirector) onSystemPop = VPopHandler._voidOnSystemPop,
    this.buildTransition,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.mode = VRouterModes.hash,
    this.initialUrl = '/',
  })  : _navigatorKey = GlobalKey<NavigatorState>(),
        _rootVRouter = RootVRouter(
          routes: routes,
          afterEnter: afterEnter,
          beforeEnter: beforeEnter,
          beforeLeave: beforeLeave,
          onPop: onPop,
          onSystemPop: onSystemPop,
        ) {
    // When the app starts, get the serialCount. Default to 0.
    _serialCount = (kIsWeb) ? (BrowserHelpers.getHistorySerialCount() ?? 0) : 0;

    // Setup the url strategy (if hash, do nothing since it is the default)
    if (mode == VRouterModes.history) {
      setPathUrlStrategy();
    }

    // Check if this is the first route
    if (_serialCount == 0) {
      // If it is, navigate to initial url if this is not the default one
      if (initialUrl != '/') {
        // If we are deep-linking, do not use initial url
        if (!kIsWeb || BrowserHelpers.getPathAndQuery(routerMode: mode).isEmpty) {
          WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
            pushReplacement(initialUrl);
          });
        }
      }
    }

    // If we are on the web, we listen to any unload event.
    // This allows us to call beforeLeave when the browser or the tab
    // is being closed for example
    if (kIsWeb) {
      BrowserHelpers.onBrowserBeforeUnload.listen((e) => _onBeforeUnload());
    }
  }

  /// Those are used in the root navigator
  /// They are here to prevent breaking animations
  final GlobalKey<NavigatorState> _navigatorKey;

  /// The VRouter associated to this VRouterDelegate
  final RootVRouter _rootVRouter;

  /// The child of this widget
  ///
  /// This will contain the navigator etc.
  //
  // When the app starts, before we process the '/' route, we display
  // nothing.
  // Ideally this should never be needed, or replaced with a splash screen
  // Should we add the option ?
  late VRoute _vRoute = VRoute(
    pages: [],
    pathParameters: {},
    vRouteElementNode: VRouteElementNode(_rootVRouter, localPath: null),
    vRouteElements: [_rootVRouter],
  );

  /// Every VWidgetGuard will be registered here
  List<VWidgetGuardMessageRoot> _vWidgetGuardMessagesRoot = [];

  /// Url currently synced with the state
  /// This url can differ from the once of the browser if
  /// the state has been yet been updated
  String? url;

  /// Previous url that was synced with the state
  String? previousUrl;

  /// This state is saved in the browser history. This means that if the user presses
  /// the back or forward button on the navigator, this historyState will be the same
  /// as the last one you saved.
  ///
  /// It can be changed by using [context.vRouter.replaceHistoryState(newState)]
  Map<String, String> historyState = {};

  /// Maps all route parameters (i.e. parameters of the path
  /// mentioned as ":someId")
  Map<String, String> pathParameters = <String, String>{};

  /// Contains all query parameters (i.e. parameters after
  /// the "?" in the url) of the current url
  Map<String, String> queryParameters = <String, String>{};

  /// Updates every state variables of [VRouter]
  ///
  /// Note that this does not call setState
  void _updateStateVariables(
    VRoute vRoute,
    String newUrl, {
    required Map<String, String> queryParameters,
    required Map<String, String> historyState,
    required List<VWidgetGuardMessageRoot> deactivatedVWidgetGuardsMessagesRoot,
  }) {
    // Update the vRoute
    this._vRoute = vRoute;

    // Update the urls
    previousUrl = url;
    url = newUrl;

    // Update the history state
    this.historyState = historyState;

    // Update the path parameters
    this.pathParameters = vRoute.pathParameters;

    // Update the query parameters
    this.queryParameters = queryParameters;

    // Update _vWidgetGuardMessagesRoot by removing the no-longer actives VWidgetGuards
    for (var deactivatedVWidgetGuardMessageRoot in deactivatedVWidgetGuardsMessagesRoot)
      _vWidgetGuardMessagesRoot.remove(deactivatedVWidgetGuardMessageRoot);
  }

  /// See [VRouterMethodsHolder.pushNamed]
  void _updateUrlFromName(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
    bool isReplacement = false,
  }) {
    // Encode the path parameters
    pathParameters =
        pathParameters.map((key, value) => MapEntry(key, Uri.encodeComponent(value)));

    // We use VRouteElement.getPathFromName
    final getPathFromNameResult = _rootVRouter.getPathFromName(
      name,
      pathParameters: pathParameters,
      parentPathResult: ValidParentPathResult(path: null, pathParameters: {}),
      remainingPathParameters: pathParameters,
    );

    if (getPathFromNameResult is ErrorGetPathFromNameResult) {
      throw getPathFromNameResult;
    }

    var newPath = (getPathFromNameResult as ValidNameResult).path;

    // Encode the path parameters
    final encodedPathParameters = pathParameters.map<String, String>(
      (key, value) => MapEntry(key, Uri.encodeComponent(value)),
    );

    // Inject the encoded path parameters into the new path
    newPath = pathToFunction(newPath)(encodedPathParameters);

    // Update the url with the found and completed path
    _updateUrl(newPath, queryParameters: queryParameters, isReplacement: isReplacement);
  }

  /// This should be the only way to change a url.
  /// Navigation cycle:
  /// 1. Call beforeLeave in all deactivated [VWidgetGuard]
  /// 2. Call beforeLeave in all deactivated [VRouteElement]
  /// 3. Call beforeLeave in the [VRouter]
  /// 4. Call beforeEnter in the [VRouter]
  /// 5. Call beforeEnter in all initialized [VRouteElement] of the new route
  /// 6. Call beforeUpdate in all reused [VWidgetGuard]
  /// 7. Call beforeUpdate in all reused [VRouteElement]
  ///
  /// ## The history state got in beforeLeave are stored
  /// ## The state is updated
  ///
  /// 8. Call afterEnter in all initialized [VWidgetGuard]
  /// 9. Call afterEnter all initialized [VRouteElement]
  /// 10. Call afterEnter in the [VRouter]
  /// 11. Call afterUpdate in all reused [VWidgetGuard]
  /// 12. Call afterUpdate in all reused [VRouteElement]
  Future<void> _updateUrl(
    String newUrl, {
    Map<String, String> newHistoryState = const {},
    bool fromBrowser = false,
    int? newSerialCount,
    Map<String, String> queryParameters = const {},
    bool isUrlExternal = false,
    bool isReplacement = false,
    bool openNewTab = false,
  }) async {
    assert(!kIsWeb || (!fromBrowser || newSerialCount != null));

    // Reset this to true, new url = new chance to report
    _doReportBackUrlToBrowser = true;

    // This should never happen, if it does this is in error in this package
    // We take care of passing the right parameters depending on the platform
    assert(kIsWeb || isReplacement == false,
        'This does not make sense to replace the route if you are not on the web. Please set isReplacement to false.');

    var newUri = Uri.parse(newUrl);
    final newPath = newUri.path;
    assert(!(newUri.queryParameters.isNotEmpty && queryParameters.isNotEmpty),
        'You used the queryParameters attribute but the url already contained queryParameters. The latter will be overwritten by the argument you gave');
    if (queryParameters.isEmpty) {
      queryParameters = newUri.queryParameters;
    }
    // Decode queryParameters
    queryParameters = queryParameters.map(
      (key, value) => MapEntry(key, Uri.decodeComponent(value)),
    );

    // Add the queryParameters to the url if needed
    if (queryParameters.isNotEmpty) {
      newUri = Uri(path: newPath, queryParameters: queryParameters);
    }

    // Get only the path from the url
    final path = (url != null) ? Uri.parse(url!).path : null;

    late final List<VRouteElement> deactivatedVRouteElements;
    late final List<VRouteElement> reusedVRouteElements;
    late final List<VRouteElement> initializedVRouteElements;
    late final List<VWidgetGuardMessageRoot> deactivatedVWidgetGuardsMessagesRoot;
    late final List<VWidgetGuardMessageRoot> reusedVWidgetGuardsMessagesRoot;
    VRoute? newVRoute;
    if (isUrlExternal) {
      newVRoute = null;
      deactivatedVRouteElements = <VRouteElement>[];
      reusedVRouteElements = <VRouteElement>[];
      initializedVRouteElements = <VRouteElement>[];
      deactivatedVWidgetGuardsMessagesRoot = <VWidgetGuardMessageRoot>[];
      reusedVWidgetGuardsMessagesRoot = <VWidgetGuardMessageRoot>[];
    } else {
      // Get the new route
      newVRoute = _rootVRouter.buildRoute(
        VPathRequestData(
          previousUrl: url,
          uri: newUri,
          historyState: newHistoryState,
          rootVRouterContext: _rootVRouterContext,
        ),
        parentVPathMatch: ValidVPathMatch(
          remainingPath: newPath,
          pathParameters: {},
          localPath: null,
        ),
        parentCanPop: false,
      );

      if (newVRoute == null) {
        throw UnknownUrlVError(url: newUrl);
      }

      // This copy is necessary in order not to modify newVRoute.vRouteElements
      final newVRouteElements = List<VRouteElement>.from(newVRoute.vRouteElements);

      deactivatedVRouteElements = <VRouteElement>[];
      reusedVRouteElements = <VRouteElement>[];
      if (_vRoute.vRouteElements.isNotEmpty) {
        for (var vRouteElement in _vRoute.vRouteElements.reversed) {
          try {
            reusedVRouteElements.add(
              newVRouteElements.firstWhere(
                (newVRouteElement) => (newVRouteElement == vRouteElement),
              ),
            );
          } on StateError {
            deactivatedVRouteElements.add(vRouteElement);
          }
        }
      }
      initializedVRouteElements = newVRouteElements
          .where(
            (newVRouteElement) =>
                _vRoute.vRouteElements
                    .indexWhere((vRouteElement) => vRouteElement == newVRouteElement) ==
                -1,
          )
          .toList();

      // Get deactivated and reused VWidgetGuards
      deactivatedVWidgetGuardsMessagesRoot = _vWidgetGuardMessagesRoot
          .where(
            (vWidgetGuardMessageRoot) => deactivatedVRouteElements
                .contains(vWidgetGuardMessageRoot.associatedVRouteElement),
          )
          .toList();
      reusedVWidgetGuardsMessagesRoot = _vWidgetGuardMessagesRoot
          .where(
            (vWidgetGuardMessageRoot) =>
                reusedVRouteElements.contains(vWidgetGuardMessageRoot.associatedVRouteElement),
          )
          .toList();
    }

    Map<String, String> historyStateToSave = {};
    void saveHistoryState(Map<String, String> historyState) {
      historyStateToSave.addAll(historyState);
    }

    // Instantiate VRedirector
    final vRedirector = VRedirector(
      context: _rootVRouterContext,
      from: url,
      to: newUri.toString(),
      previousVRouterData: RootVRouterData(
        child: Container(),
        historyState: historyState,
        pathParameters: _vRoute.pathParameters,
        queryParameters: this.queryParameters,
        state: this,
        url: url,
        previousUrl: previousUrl,
      ),
      newVRouterData: RootVRouterData(
        child: Container(),
        historyState: newHistoryState,
        pathParameters: newVRoute?.pathParameters ?? {},
        queryParameters: queryParameters,
        state: this,
        url: newUri.toString(),
        previousUrl: url,
      ),
    );

    if (url != null) {
      ///   1. Call beforeLeave in all deactivated [VWidgetGuard]
      for (var vWidgetGuardMessageRoot in deactivatedVWidgetGuardsMessagesRoot) {
        await vWidgetGuardMessageRoot.vWidgetGuard.beforeLeave(vRedirector, saveHistoryState);
        if (!vRedirector._shouldUpdate) {
          await _abortUpdateUrl(
            fromBrowser: fromBrowser,
            serialCount: _serialCount,
            newSerialCount: newSerialCount,
          );

          vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                  .getChildVRouteElementNode(
                      vRouteElement: vWidgetGuardMessageRoot.associatedVRouteElement) ??
              _vRoute.vRouteElementNode);
          return;
        }
      }

      ///   2. Call beforeLeave in all deactivated [VRouteElement]
      for (var vRouteElement in deactivatedVRouteElements) {
        await vRouteElement.beforeLeave(vRedirector, saveHistoryState);
        if (!vRedirector._shouldUpdate) {
          await _abortUpdateUrl(
            fromBrowser: fromBrowser,
            serialCount: _serialCount,
            newSerialCount: newSerialCount,
          );
          vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                  .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
              _vRoute.vRouteElementNode);
          return;
        }
      }

      /// 3. Call beforeLeave in the [VRouter]
      await _rootVRouter.beforeLeave(vRedirector, saveHistoryState);
      if (!vRedirector._shouldUpdate) {
        await _abortUpdateUrl(
          fromBrowser: fromBrowser,
          serialCount: _serialCount,
          newSerialCount: newSerialCount,
        );
        vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode);
        return;
      }
    }

    if (!isUrlExternal) {
      /// 4. Call beforeEnter in the [VRouter]
      await _rootVRouter.beforeEnter(vRedirector);
      if (!vRedirector._shouldUpdate) {
        await _abortUpdateUrl(
          fromBrowser: fromBrowser,
          serialCount: _serialCount,
          newSerialCount: newSerialCount,
        );
        vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode);
        return;
      }

      /// 5. Call beforeEnter in all initialized [VRouteElement] of the new route
      for (var vRouteElement in initializedVRouteElements) {
        await vRouteElement.beforeEnter(vRedirector);
        if (!vRedirector._shouldUpdate) {
          await _abortUpdateUrl(
            fromBrowser: fromBrowser,
            serialCount: _serialCount,
            newSerialCount: newSerialCount,
          );
          vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                  .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
              _vRoute.vRouteElementNode);
          return;
        }
      }

      /// 6. Call beforeUpdate in all reused [VWidgetGuard]
      for (var vWidgetGuardMessageRoot in reusedVWidgetGuardsMessagesRoot) {
        await vWidgetGuardMessageRoot.vWidgetGuard.beforeUpdate(vRedirector);
        if (!vRedirector._shouldUpdate) {
          await _abortUpdateUrl(
            fromBrowser: fromBrowser,
            serialCount: _serialCount,
            newSerialCount: newSerialCount,
          );

          vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                  .getChildVRouteElementNode(
                      vRouteElement: vWidgetGuardMessageRoot.associatedVRouteElement) ??
              _vRoute.vRouteElementNode);
          return;
        }
      }

      /// 7. Call beforeUpdate in all reused [VRouteElement]
      for (var vRouteElement in reusedVRouteElements) {
        await vRouteElement.beforeUpdate(vRedirector);
        if (!vRedirector._shouldUpdate) {
          await _abortUpdateUrl(
            fromBrowser: fromBrowser,
            serialCount: _serialCount,
            newSerialCount: newSerialCount,
          );

          vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                  .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
              _vRoute.vRouteElementNode);
          return;
        }
      }
    }

    final oldSerialCount = _serialCount;

    if (historyStateToSave.isNotEmpty && path != null) {
      if (!kIsWeb) {
        log(
          ' WARNING: Tried to store the state $historyStateToSave while not on the web. State saving/restoration only work on the web.\n'
          'You can safely ignore this message if you just want this functionality on the web.',
          name: 'VRouter',
        );
      } else {
        ///   The historyStates got in beforeLeave are stored   ///
        // If we come from the browser, chances are we already left the page
        // So we need to:
        //    1. Go back to where we were
        //    2. Save the historyState
        //    3. And go back again to the place
        if (kIsWeb && fromBrowser && oldSerialCount != newSerialCount) {
          _ignoreNextBrowserCalls = true;
          BrowserHelpers.browserGo(oldSerialCount - newSerialCount!);
          await BrowserHelpers.onBrowserPopState.firstWhere((element) {
            return BrowserHelpers.getHistorySerialCount() == oldSerialCount;
          });
        }
        BrowserHelpers.replaceHistoryState(jsonEncode({
          'serialCount': oldSerialCount,
          'historyState': jsonEncode(historyStateToSave),
        }));

        if (kIsWeb && fromBrowser && oldSerialCount != newSerialCount) {
          BrowserHelpers.browserGo(newSerialCount! - oldSerialCount);
          await BrowserHelpers.onBrowserPopState.firstWhere(
              (element) => BrowserHelpers.getHistorySerialCount() == newSerialCount);
          _ignoreNextBrowserCalls = false;
        }
      }
    }

    /// Leave if the url is external
    if (isUrlExternal) {
      _ignoreNextBrowserCalls = true;
      await BrowserHelpers.pushExternal(newUri.toString(), openNewTab: openNewTab);
      return;
    }

    ///   The state of the VRouter changes            ///
    final oldUrl = url;

    if (isReplacement) {
      _doReportBackUrlToBrowser = false;
      _ignoreNextBrowserCalls = true;
      if (BrowserHelpers.getPathAndQuery(routerMode: mode) != newUri.toString()) {
        BrowserHelpers.pushReplacement(newUri.toString(), routerMode: mode);
        if (BrowserHelpers.getPathAndQuery(routerMode: mode) != newUri.toString()) {
          await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
              BrowserHelpers.getPathAndQuery(routerMode: mode) == newUri.toString());
        }
      }
      BrowserHelpers.replaceHistoryState(jsonEncode({
        'serialCount': _serialCount,
        'historyState': jsonEncode(newHistoryState),
      }));
      _ignoreNextBrowserCalls = false;
    } else {
      // If this comes from the browser, newSerialCount is not null
      // If this comes from a user:
      //    - If he/she pushes the same url+historyState, flutter does not create a new history entry so the serialCount remains the same
      //    - Else the serialCount gets increased by 1
      _serialCount = newSerialCount ??
          _serialCount + ((newUrl != url || newHistoryState != historyState) ? 1 : 0);
    }
    _updateStateVariables(
      newVRoute!,
      newUri.toString(),
      historyState: newHistoryState,
      queryParameters: queryParameters,
      deactivatedVWidgetGuardsMessagesRoot: deactivatedVWidgetGuardsMessagesRoot,
    );
    notifyListeners();

    // We need to do this after rebuild as completed so that the user can have access
    // to the new state variables
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      /// 8. Call afterEnter in all initialized [VWidgetGuard]
      // This is done automatically by VNotificationGuard

      /// 9. Call afterEnter all initialized [VRouteElement]
      for (var vRouteElement in initializedVRouteElements) {
        vRouteElement.afterEnter(
          _rootVRouterContext,
          // TODO: Change this to local context? This might imply that we need a global key which is not ideal
          oldUrl,
          newUri.toString(),
        );
      }

      /// 10. Call afterEnter in the [VRouter]
      _rootVRouter.afterEnter(_rootVRouterContext, oldUrl, newUri.toString());

      /// 11. Call afterUpdate in all reused [VWidgetGuard]
      for (var vWidgetGuardMessageRoot in reusedVWidgetGuardsMessagesRoot) {
        vWidgetGuardMessageRoot.vWidgetGuard.afterUpdate(
          vWidgetGuardMessageRoot.localContext,
          oldUrl,
          newUri.toString(),
        );
      }

      /// 12. Call afterUpdate in all reused [VRouteElement]
      for (var vRouteElement in reusedVRouteElements) {
        vRouteElement.afterUpdate(
          _rootVRouterContext,
          // TODO: Change this to local context? This might imply that we need a global key which is not ideal
          oldUrl,
          newUri.toString(),
        );
      }
    });
  }

  /// This function is used in [updateUrl] when the update should be canceled
  /// This happens and vRedirector is used to stop the navigation
  ///
  /// On mobile nothing happens
  /// On the web, if the browser already navigated away, we have to navigate back to where we were
  ///
  /// Note that this should be called before setState, otherwise it is useless and cannot prevent a state spread
  ///
  /// newSerialCount should not be null if the updateUrl came from the Browser
  Future<void> _abortUpdateUrl({
    required bool fromBrowser,
    required int serialCount,
    required int? newSerialCount,
  }) async {
    // If the url change comes from the browser, chances are the url is already changed
    // So we have to navigate back to the old url (stored in _url)
    // Note: in future version it would be better to delete the last url of the browser
    //        but it is not yet possible
    if (kIsWeb &&
        fromBrowser &&
        (BrowserHelpers.getHistorySerialCount() ?? 0) != serialCount) {
      _ignoreNextBrowserCalls = true;
      BrowserHelpers.browserGo(serialCount - newSerialCount!);
      await BrowserHelpers.onBrowserPopState.firstWhere((element) {
        return BrowserHelpers.getHistorySerialCount() == serialCount;
      });
      _ignoreNextBrowserCalls = false;
    }
    return;
  }

  /// Performs a systemPop cycle:
  ///   1. Call onPop in all active [VWidgetGuards]
  ///   2. Call onPop in all [VRouteElement]
  ///   3. Call onPop of VRouter
  ///   4. Update the url to the one found in [_defaultPop]
  Future<void> _pop(
    VRouteElement elementToPop, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) async {
    assert(url != null);

    // Get information on where to pop from _defaultPop
    final defaultPopResult = _defaultPop(
      elementToPop,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      newHistoryState: newHistoryState,
    );

    final vRedirector = defaultPopResult.vRedirector;

    final poppedVRouteElements = defaultPopResult.poppedVRouteElements;

    final List<VWidgetGuardMessageRoot> poppedVWidgetGuardsMessagesRoot =
        _vWidgetGuardMessagesRoot
            .where((vWidgetGuardMessageRoot) =>
                poppedVRouteElements.contains(vWidgetGuardMessageRoot.associatedVRouteElement))
            .toList();

    /// 1. Call onPop in all popped [VWidgetGuards]
    for (var vWidgetGuardMessageRoot in poppedVWidgetGuardsMessagesRoot) {
      await vWidgetGuardMessageRoot.vWidgetGuard.onPop(vRedirector);
      if (!vRedirector.shouldUpdate) {
        vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                .getChildVRouteElementNode(
                    vRouteElement: vWidgetGuardMessageRoot.associatedVRouteElement) ??
            _vRoute.vRouteElementNode);
        return;
      }
    }

    /// 2. Call onPop in all popped [VRouteElement]
    for (var vRouteElement in poppedVRouteElements) {
      await vRouteElement.onPop(vRedirector);
      if (!vRedirector.shouldUpdate) {
        vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
            _vRoute.vRouteElementNode);
        return;
      }
    }

    /// 3. Call onPop of VRouter
    await _rootVRouter.onPop(vRedirector);
    if (!vRedirector.shouldUpdate) {
      vRedirector._redirectFunction?.call(
          _vRoute.vRouteElementNode.getChildVRouteElementNode(vRouteElement: _rootVRouter) ??
              _vRoute.vRouteElementNode);
      return;
    }

    /// 4. Update the url to the one found in [_defaultPop]
    if (vRedirector.newVRouterData != null) {
      _updateUrl(vRedirector.to!,
          queryParameters: queryParameters, newHistoryState: newHistoryState);
    } else if (Platform.isAndroid || Platform.isIOS) {
      // If we didn't find a url to go to, we are at the start of the stack
      // so we close the app on mobile
      MoveToBackground.moveTaskToBack();
    }
  }

  /// Performs a systemPop cycle:
  /// 1. Call onSystemPop in all active [VWidgetGuards] if implemented, else onPop
  /// 2. Call onSystemPop in all [VRouteElement] if implemented, else onPop
  /// 3. Call onSystemPop of VRouter if implemented, else onPop
  /// 4. Update the url to the one found in [_defaultPop]
  Future<void> _systemPop(
    VRouteElement elementToPop, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) async {
    assert(url != null);

    // Get information on where to pop from _defaultPop
    final defaultPopResult = _defaultPop(
      elementToPop,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      newHistoryState: newHistoryState,
    );

    final vRedirector = defaultPopResult.vRedirector;

    final poppedVRouteElements = defaultPopResult.poppedVRouteElements;

    final List<VWidgetGuardMessageRoot> poppedVWidgetGuardsMessagesRoot =
        _vWidgetGuardMessagesRoot
            .where((vWidgetGuardMessageRoot) =>
                poppedVRouteElements.contains(vWidgetGuardMessageRoot.associatedVRouteElement))
            .toList();

    /// 1. Call onSystemPop in all popping [VWidgetGuards] if implemented, else onPop
    for (var vWidgetGuardMessageRoot in poppedVWidgetGuardsMessagesRoot) {
      if (vWidgetGuardMessageRoot.vWidgetGuard.onSystemPop != VPopHandler._voidOnSystemPop) {
        await vWidgetGuardMessageRoot.vWidgetGuard.onSystemPop(vRedirector);
      } else {
        await vWidgetGuardMessageRoot.vWidgetGuard.onPop(vRedirector);
      }
      if (!vRedirector.shouldUpdate) {
        vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                .getChildVRouteElementNode(
                    vRouteElement: vWidgetGuardMessageRoot.associatedVRouteElement) ??
            _vRoute.vRouteElementNode);
        return;
      }
    }

    /// 2. Call onSystemPop in all popped [VRouteElement] if implemented, else onPop
    for (var vRouteElement in poppedVRouteElements) {
      if (vRouteElement.onSystemPop != VPopHandler._voidOnSystemPop) {
        await vRouteElement.onSystemPop(vRedirector);
      } else {
        await vRouteElement.onPop(vRedirector);
      }
      if (!vRedirector.shouldUpdate) {
        vRedirector._redirectFunction?.call(_vRoute.vRouteElementNode
                .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
            _vRoute.vRouteElementNode);
        return;
      }
    }

    /// 3. Call onSystemPop of VRouter if implemented, else onPop
    if (_rootVRouter.onSystemPop != VPopHandler._voidOnSystemPop) {
      await _rootVRouter.onSystemPop(vRedirector);
    } else {
      await _rootVRouter.onPop(vRedirector);
    }
    if (!vRedirector.shouldUpdate) {
      vRedirector._redirectFunction?.call(
          _vRoute.vRouteElementNode.getChildVRouteElementNode(vRouteElement: _rootVRouter) ??
              _vRoute.vRouteElementNode);
      return;
    }

    /// 4. Update the url to the one found in [_defaultPop]
    if (vRedirector.newVRouterData != null) {
      _updateUrl(vRedirector.to!,
          queryParameters: queryParameters, newHistoryState: newHistoryState);
    } else if (!kIsWeb) {
      // If we didn't find a url to go to, we are at the start of the stack
      // so we close the app on mobile
      MoveToBackground.moveTaskToBack();
    }
  }

  /// Uses [VRouteElement.getPathFromPop] to determine the new path after popping [elementToPop]
  ///
  /// See:
  ///   * [VWidgetGuard.onPop] to override this behaviour locally
  ///   * [VRouteElement.onPop] to override this behaviour on a on a route level
  ///   * [VRouter.onPop] to override this behaviour on a global level
  ///   * [VWidgetGuard.onSystemPop] to override this behaviour locally
  ///                               when the call comes from the system
  ///   * [VRouteElement.onSystemPop] to override this behaviour on a route level
  ///                               when the call comes from the system
  ///   * [VRouter.onSystemPop] to override this behaviour on a global level
  ///                               when the call comes from the system
  DefaultPopResult _defaultPop(
    VRouteElement elementToPop, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) {
    assert(url != null);
    // Encode the path parameters
    pathParameters =
        pathParameters.map((key, value) => MapEntry(key, Uri.encodeComponent(value)));

    // We don't use widget.getPathFromPop because widget.routes might have changed with a setState
    final popResult = _vRoute.vRouteElementNode.vRouteElement.getPathFromPop(
      elementToPop,
      pathParameters: pathParameters,
      parentPathResult: ValidParentPathResult(path: null, pathParameters: {}),
    );

    // The result should not be an error
    // If it is, it should be fixed by the dev
    if (popResult is ErrorPopResult) {
      throw popResult;
    }

    // If popResult is not ErrorPopResult, it is either
    // ValidPopResult or PoppingPopResult
    final newPath = (popResult is ValidPopResult) ? popResult.path : null;

    // This url will be not null if we find a route to go to
    late final String? newUrl;
    late final RootVRouterData? newVRouterData;

    // If newPath is empty then the app should be put in the background (for mobile)
    if (newPath != null) {
      // Integrate the given query parameters
      newUrl = Uri.tryParse(newPath)
          ?.replace(queryParameters: (queryParameters.isNotEmpty) ? queryParameters : null)
          .toString();

      newVRouterData = RootVRouterData(
        child: Container(),
        historyState: newHistoryState,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        url: newUrl,
        previousUrl: url,
        state: this,
      );
    } else {
      newUrl = null;
      newVRouterData = null;
    }

    final vNodeToPop =
        _vRoute.vRouteElementNode.getVRouteElementNodeFromVRouteElement(elementToPop);

    assert(vNodeToPop != null);

    // This is the list of [VRouteElement]s that where not necessary expected to pop but did because of
    // the pop of [elementToPop]
    final List<VRouteElement> poppedVRouteElementsFromPopResult =
        (popResult is FoundPopResult) ? popResult.poppedVRouteElements : [];

    // This is predictable list of [VRouteElement]s that are expected to pop because they are
    // in the nestedRoutes or stackedRoutes of [elementToPop] [VRouteElementNode]
    // We take the reversed because we when to call onPop in the deepest nested
    // [VRouteElement] first
    final poppedVRouteElementsFromVNode = vNodeToPop!.getVRouteElements().reversed.toList();

    // This is the list of every [VRouteElement] which should pop
    final poppedVRouteElements =
        poppedVRouteElementsFromVNode + poppedVRouteElementsFromPopResult;

    // elementToPop should have a duplicate so we remove it
    poppedVRouteElements.removeAt(poppedVRouteElements.indexOf(elementToPop));

    return DefaultPopResult(
      vRedirector: VRedirector(
        context: _rootVRouterContext,
        from: url,
        to: newUrl,
        previousVRouterData: RootVRouterData(
          child: Container(),
          historyState: historyState,
          pathParameters: _vRoute.pathParameters,
          queryParameters: queryParameters,
          state: this,
          previousUrl: previousUrl,
          url: url,
        ),
        newVRouterData: newVRouterData,
      ),
      poppedVRouteElements: poppedVRouteElements,
    );
  }

  /// This replaces the current history state of [VRouter] with given one
  void replaceHistoryState(Map<String, String> newHistoryState) {
    pushReplacement((url != null) ? Uri.parse(url!).path : '/', historyState: newHistoryState);
  }

  /// WEB ONLY
  /// Save the state if needed before the app gets unloaded
  /// Mind that this happens when the user enter a url manually in the
  /// browser so we can't prevent him from leaving the page
  void _onBeforeUnload() async {
    if (url == null) return;

    Map<String, String> historyStateToSave = {};
    void saveHistoryState(Map<String, String> historyState) {
      historyStateToSave.addAll(historyState);
    }

    // Instantiate VRedirector
    final vRedirector = VRedirector(
      context: _rootVRouterContext,
      from: url,
      to: null,
      previousVRouterData: RootVRouterData(
        child: Container(),
        historyState: historyState,
        pathParameters: _vRoute.pathParameters,
        queryParameters: this.queryParameters,
        state: this,
        url: url,
        previousUrl: previousUrl,
      ),
      newVRouterData: null,
    );

    ///   1. Call beforeLeave in all deactivated [VWidgetGuard]
    for (var vWidgetGuardMessageRoot in _vWidgetGuardMessagesRoot) {
      await vWidgetGuardMessageRoot.vWidgetGuard.beforeLeave(vRedirector, saveHistoryState);
    }

    ///   2. Call beforeLeave in all deactivated [VRouteElement] and [VRouter]
    for (var vRouteElement in _vRoute.vRouteElements.reversed) {
      await vRouteElement.beforeLeave(vRedirector, saveHistoryState);
    }

    if (historyStateToSave.isNotEmpty) {
      ///   The historyStates got in beforeLeave are stored   ///
      BrowserHelpers.replaceHistoryState(jsonEncode({
        'serialCount': _serialCount,
        'historyState': jsonEncode(historyStateToSave),
      }));
    }
  }

  /// Starts a pop cycle
  ///
  /// Pop cycle:
  ///   1. onPop is called in all [VNavigationGuard]s
  ///   2. onPop is called in all [VRouteElement]s of the current route
  ///   3. onPop is called in [VRouter]
  ///
  /// In any of the above steps, we can use [vRedirector] if you want to redirect or
  /// stop the navigation
  Future<void> pop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) async {
    _pop(
      _vRoute.vRouteElementNode.getVRouteElementToPop(),
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      newHistoryState: newHistoryState,
    );
  }

  /// Starts a systemPop cycle
  ///
  /// systemPop cycle:
  ///   1. onSystemPop (or onPop if not implemented) is called in all VNavigationGuards
  ///   2. onSystemPop (or onPop if not implemented) is called in the nested-most VRouteElement of the current route
  ///   3. onSystemPop (or onPop if not implemented) is called in VRouter
  ///
  /// In any of the above steps, we can use a [VRedirector] if you want to redirect or
  /// stop the navigation
  Future<void> systemPop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newHistoryState = const {},
  }) async {
    _systemPop(
      _vRoute.vRouteElementNode.getVRouteElementToSystemPop(),
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      newHistoryState: newHistoryState,
    );
  }

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
  }) {
    if (!newUrl.startsWith('/')) {
      if (url == null) {
        throw InvalidPushVError(url: newUrl);
      }
      final currentPath = Uri.parse(url!).path;
      newUrl = currentPath + (currentPath.endsWith('/') ? '' : '/') + '$newUrl';
    }

    _updateUrl(
      newUrl,
      queryParameters: queryParameters,
      newHistoryState: historyState,
    );
  }

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
  }) {
    _updateUrlFromName(name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newHistoryState: historyState);
  }

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
  }) {
    // If not on the web, this is the same as push
    if (!kIsWeb) {
      return push(newUrl, queryParameters: queryParameters, historyState: historyState);
    }

    if (!newUrl.startsWith('/')) {
      if (url == null) {
        throw InvalidPushVError(url: newUrl);
      }
      final currentPath = Uri.parse(url!).path;
      newUrl = currentPath + '/$newUrl';
    }

    // Update the url, setting isReplacement to true
    _updateUrl(
      newUrl,
      queryParameters: queryParameters,
      newHistoryState: historyState,
      isReplacement: true,
    );
  }

  /// Pushes a new url based on url segments
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
    return push('/$newUrl', queryParameters: queryParameters, historyState: historyState);
  }

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
  /// To specify a name, see [VPath.name]
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) {
    _updateUrlFromName(name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newHistoryState: historyState,
        isReplacement: true);
  }

  /// Goes to an url which is not in the app
  ///
  /// On the web, you can set [openNewTab] to true to open this url
  /// in a new tab
  void pushExternal(String newUrl, {bool openNewTab = false}) =>
      _updateUrl(newUrl, isUrlExternal: true, openNewTab: openNewTab);

  /// handles systemPop
  @override
  Future<bool> popRoute() async {
    await _systemPop(
      _vRoute.vRouteElementNode.getVRouteElementToSystemPop(),
      pathParameters: pathParameters,
    );
    return true;
  }

  /// Navigation state to app state
  @override
  Future<void> setNewRoutePath(RouteInformation routeInformation) async {
    if (routeInformation.location != null && !_ignoreNextBrowserCalls) {
      // Get the new state
      final newState = (kIsWeb)
          ? Map<String, dynamic>.from(jsonDecode((routeInformation.state as String?) ??
              (BrowserHelpers.getHistoryState() ?? '{}')))
          : <String, dynamic>{};

      // Get the new serial count
      int? newSerialCount;
      try {
        newSerialCount = newState['serialCount'];
        // ignore: empty_catches
      } on FormatException {}

      // Get the new history state
      final newHistoryState =
          Map<String, String>.from(jsonDecode(newState['historyState'] ?? '{}'));

      // Check if this is the first route
      if (newSerialCount == null || newSerialCount == 0) {
        // If so, check is the url reported by the browser is the same as the initial url
        // We check "routeInformation.location == '/'" to enable deep linking
        if (routeInformation.location == '/' && routeInformation.location != initialUrl) {
          return;
        }
      }

      // Update the app with the new url
      await _updateUrl(
        routeInformation.location!,
        newHistoryState: newHistoryState,
        fromBrowser: true,
        newSerialCount: newSerialCount ?? _serialCount + 1,
      );
    }
  }

  /// App state to navigation state
  @override
  RouteInformation? get currentConfiguration => _doReportBackUrlToBrowser
      ? RouteInformation(
          location: url ?? '/',
          state: jsonEncode({
            'serialCount': _serialCount,
            'historyState': jsonEncode(historyState),
          }),
        )
      : null;

  @override
  Widget build(BuildContext context) {
    return NotificationListener<VWidgetGuardMessageRoot>(
      onNotification: (VWidgetGuardMessageRoot vWidgetGuardMessageRoot) {
        if (_vWidgetGuardMessagesRoot.indexWhere(
              (message) =>
                  message.vWidgetGuard.key == vWidgetGuardMessageRoot.vWidgetGuard.key &&
                  message.associatedVRouteElement ==
                      vWidgetGuardMessageRoot.associatedVRouteElement,
            ) ==
            -1) {
          _vWidgetGuardMessagesRoot.add(vWidgetGuardMessageRoot);
          WidgetsBinding.instance?.addPostFrameCallback((_) {
            vWidgetGuardMessageRoot.vWidgetGuard
                .afterEnter(vWidgetGuardMessageRoot.localContext, previousUrl, url!);
          });
        }

        return true;
      },
      child: RootVRouterData(
        state: this,
        previousUrl: previousUrl,
        url: url,
        pathParameters: pathParameters,
        historyState: historyState,
        queryParameters: queryParameters,
        child: Builder(
          builder: (context) {
            _rootVRouterContext = context;

            final child = Navigator(
              pages: _vRoute.pages.isNotEmpty
                  ? _vRoute.pages
                  : [
                      MaterialPage(child: Container()),
                    ],
              key: _navigatorKey,
              observers: navigatorObservers,
              onPopPage: (_, __) {
                _pop(
                  _vRoute.vRouteElementNode.getVRouteElementToPop(),
                  pathParameters: pathParameters,
                );
                return false;
              },
            );

            return builder?.call(context, child) ?? child;
          },
        ),
      ),
    );
  }
}

class DefaultPopResult {
  VRedirector vRedirector;
  List<VRouteElement> poppedVRouteElements;

  DefaultPopResult({
    required this.vRedirector,
    required this.poppedVRouteElements,
  });
}
