import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:vrouter/src/core/errors.dart';
import 'package:vrouter/src/core/navigator_extension.dart';
import 'package:vrouter/src/core/vlogs.dart';
import 'package:vrouter/src/core/vpop_data.dart';
import 'package:vrouter/src/core/vredirector.dart';
import 'package:vrouter/src/core/root_vrouter.dart';
import 'package:vrouter/src/core/route.dart';
import 'package:vrouter/src/core/vroute_element.dart';
import 'package:vrouter/src/core/vroute_element_node.dart';
import 'package:vrouter/src/logs/vlog_printer.dart';
import 'package:vrouter/src/logs/vlogs.dart';
import 'package:vrouter/src/path_to_regexp/path_to_regexp.dart';
import 'package:vrouter/src/vrouter_scope.dart';
import 'package:vrouter/src/helpers/empty_page.dart';
import 'package:vrouter/src/vrouter_vroute_elements.dart';
import 'package:vrouter/src/vrouter_widgets.dart';
import 'package:vrouter/src/wrappers/move_to_background.dart';
import 'package:vrouter/src/wrappers/platform/platform.dart';
import 'package:vrouter/src/wrappers/browser_helpers/browser_helpers.dart';

import 'vrouter_sailor/vrouter_sailor.dart';

class VRouterDelegate extends RouterDelegate<RouteInformation>
    with ChangeNotifier {
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
  final Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? buildTransition;

  /// The duration of [VRouter.buildTransition]
  final Duration? transitionDuration;

  /// The reverse duration of [VRouter.buildTransition]
  final Duration? reverseTransitionDuration;

  /// This allows you to change the initial url
  ///
  /// The default is '/'
  final String initialUrl;

  /// {@macro flutter.widgets.widgetsApp.navigatorObservers}
  final List<NavigatorObserver> navigatorObservers;

  /// Build widget before the pages
  /// The context can be used to access VRouter.of
  final Widget Function(BuildContext context, Widget child)? builder;

  /// Those are used in the root navigator
  /// They are here to prevent breaking animations
  final GlobalKey<NavigatorState> navigatorKey;

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
  final List<VLogLevel> logs;

  VRouterDelegate({
    required this.routes,
    this.builder,
    this.navigatorObservers = const [],
    Future<void> Function(VRedirector vRedirector) beforeEnter =
        VoidVGuard.voidBeforeEnter,
    Future<void> Function(
      VRedirector vRedirector,
      void Function(Map<String, String> historyState) saveHistoryState,
    )
        beforeLeave = VoidVGuard.voidBeforeLeave,
    void Function(BuildContext context, String? from, String to) afterEnter =
        VoidVGuard.voidAfterEnter,
    Future<void> Function(VRedirector vRedirector) onPop =
        VoidVPopHandler.voidOnPop,
    Future<void> Function(VRedirector vRedirector) onSystemPop =
        VoidVPopHandler.voidOnSystemPop,
    this.buildTransition,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.initialUrl = '/',
    this.logs = VLogs.info,
    GlobalKey<NavigatorState>? navigatorKey,
  })  : navigatorKey = navigatorKey ?? GlobalKey<NavigatorState>(),
        _rootVRouter = RootVRouter(
          routes: routes,
          afterEnter: afterEnter,
          beforeEnter: beforeEnter,
          beforeLeave: beforeLeave,
          onPop: onPop,
          onSystemPop: onSystemPop,
        ) {
    // Set the logs to the desired ones
    VLogPrinter.showLevels = logs;

    // If we are on the web, we listen to any unload event.
    // This allows us to call beforeLeave when the browser or the tab
    // is being closed for example
    if (Platform.isWeb) {
      BrowserHelpers.onBrowserBeforeUnload.listen((e) => _onBeforeUnload());
    }
  }

  /// The VRouter associated to this VRouterDelegate
  final RootVRouter _rootVRouter;

  /// This is a context which contains the VRouter.
  /// It is used is VRouter.beforeLeave for example.
  late BuildContext _rootVRouterContext;

  /// Designates the number of page we navigated since
  /// entering the app.
  /// If is only used in the web to know where we are when
  /// the user interacts with the browser instead of the app
  /// (e.g back button)
  // late int _historyIndex;

  /// When set to true, urlToAppState will be ignored
  /// You must manually reset it to true otherwise it will
  /// be ignored forever.
  bool _ignoreNextBrowserCalls = false;

  /// The child of this widget
  ///
  /// This will contain the navigator etc.
  ///
  ///
  /// When the app starts it contains nothing so we put a dummy value
  /// All the remaining times, we use [VRouterScope.vRoute] since this
  /// will stand even a refresh
  //
  // When the app starts, before we process the '/' route, we display
  // nothing.
  // Ideally this should never be needed, or replaced with a splash screen
  // Should we add the option ?
  VRoute get _vRoute =>
      _vRouterScope.vRoute ??
      VRoute(
        pages: [],
        pathParameters: {},
        names: [],
        vRouteElementNode: VRouteElementNode(_rootVRouter, localPath: null),
        vRouteElements: [_rootVRouter],
      );

  /// Every VWidgetGuard will be registered here
  List<VWidgetGuardMessageRoot> _vWidgetGuardMessagesRoot = [];

  /// Url currently synced with the state
  ///
  ///
  /// This url can differ from the one of the browser if
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

  /// A list of every names corresponding to the [VRouteElement]s in
  /// the current stack
  List<String> get names => _vRoute.vRouteElementNode.getNames();

  /// Whether this [VRouterDelegate] is initialized
  ///
  ///
  /// Deals between [initialUrl] pushing OR deep linking
  /// This is also used to pick up the url on hot restart for flutter web
  ///
  /// It is safe to be called multiple times but should not
  bool _isInitialized = false;

  /// Represents information that should be longed lived and not be destroyed
  ///
  /// This should be gotten using context
  late VRouterScopeData _vRouterScope;

  /// Updates every state variables of [VRouter]
  ///
  /// Note that this does not call setState
  void _updateStateVariables(
    VRoute vRoute,
    Uri newUri, {
    required Map<String, String> historyState,
    required List<VWidgetGuardMessageRoot> deactivatedVWidgetGuardsMessagesRoot,
  }) {
    // Update the vRoute in VRouterScope
    _vRouterScope.setLatestVRoute(vRoute);

    // Update the urls
    previousUrl = url;
    url = newUri.toString();

    // Update the history state
    this.historyState = historyState;

    // Update the path parameters
    this.pathParameters = vRoute.pathParameters;

    // Update the query parameters
    this.queryParameters = newUri.queryParameters;

    // Update _vWidgetGuardMessagesRoot by removing the no-longer actives VWidgetGuards
    for (var deactivatedVWidgetGuardMessageRoot
        in deactivatedVWidgetGuardsMessagesRoot)
      _vWidgetGuardMessagesRoot.remove(deactivatedVWidgetGuardMessageRoot);
  }

  String _getUrlFromName(
    String name, {
    Map<String, String> pathParameters = const {},
  }) {
    // Encode the path parameters
    pathParameters = pathParameters
        .map((key, value) => MapEntry(key, Uri.encodeComponent(value)));

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
    newPath =
        replacePathParameters(replaceWildcards(newPath), encodedPathParameters);

    // Update the url with the found and completed path
    return newPath;
  }

  VRoute _getNewVRoute(
      {required Uri uri, required Map<String, String> historyState}) {
    final newVRoute = _rootVRouter.buildRoute(
      VPathRequestData(
        previousUrl: url,
        uri: uri,
        historyState: historyState,
        rootVRouterContext: _rootVRouterContext,
        navigatorObserversToReportTo:
            navigatorObservers, // This ensures that nested navigators report their events too
      ),
      parentVPathMatch: ValidVPathMatch(
        remainingPath: uri.path,
        pathParameters: {},
        localPath: null,
        names: [],
      ),
      parentCanPop: false,
    );

    if (newVRoute == null) {
      throw UnknownUrlVError(url: uri.toString());
    }

    return newVRoute;
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
    Uri newUri, {
    required VRoute? newVRoute,
    Map<String, String> newHistoryState = const {},
    required FutureOr<void> Function() onCancel,
    required VoidCallback onUpdate,
  }) async {
    final newUrl = newUri.toString();

    List<VRouteElement> deactivatedVRouteElements = [];
    List<VRouteElement> reusedVRouteElements = [];
    List<VRouteElement> initializedVRouteElements = [];
    List<VWidgetGuardMessageRoot> deactivatedVWidgetGuardsMessagesRoot = [];
    List<VWidgetGuardMessageRoot> reusedVWidgetGuardsMessagesRoot = [];
    if (newVRoute != null) {
      // This copy is necessary in order not to modify newVRoute.vRouteElements
      final newVRouteElements =
          List<VRouteElement>.from(newVRoute.vRouteElements);

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
                _vRoute.vRouteElements.indexWhere(
                    (vRouteElement) => vRouteElement == newVRouteElement) ==
                -1,
          )
          .toList();

      // Get deactivated and reused VWidgetGuards
      deactivatedVWidgetGuardsMessagesRoot = _vWidgetGuardMessagesRoot
          .where(
            (vWidgetGuardMessageRoot) =>
                deactivatedVRouteElements.contains(
                    vWidgetGuardMessageRoot.associatedVRouteElement) ||
                vWidgetGuardMessageRoot.associatedVRouteElement ==
                    _rootVRouter, // Any such vWidgetGuardMessageRoot belongs to a nav1 push and will therefore be removed
          )
          .toList();
      reusedVWidgetGuardsMessagesRoot = _vWidgetGuardMessagesRoot
          .where(
            (vWidgetGuardMessageRoot) => reusedVRouteElements
                .contains(vWidgetGuardMessageRoot.associatedVRouteElement),
          )
          .toList();
    }

    Map<String, String> historyStateToSave = {};
    void saveHistoryState(Map<String, String> historyState) {
      historyStateToSave.addAll(historyState);
    }

    // Instantiate VRedirector
    final vRedirector = VRedirector(
      vRouterDelegate: this,
      fromUrl: url,
      toUrl: newUrl,
      previousVRouterData: VRedirectorData(
        historyState: historyState,
        pathParameters: _vRoute.pathParameters,
        queryParameters: this.queryParameters,
        names: this.names,
        url: url,
        previousUrl: previousUrl,
      ),
      newVRouterData: VRedirectorData(
        historyState: newHistoryState,
        pathParameters: newVRoute?.pathParameters ?? {},
        queryParameters: newUri.queryParameters,
        names: newVRoute?.vRouteElementNode.getNames() ?? [],
        url: newUrl,
        previousUrl: url,
      ),
    );

    if (url != null) {
      ///   1. Call beforeLeave in all deactivated [VWidgetGuard]
      for (var vWidgetGuardMessageRoot
          in deactivatedVWidgetGuardsMessagesRoot) {
        await vWidgetGuardMessageRoot.vWidgetGuard
            .beforeLeave(vRedirector, saveHistoryState);
        if (!vRedirector.shouldUpdate) {
          await onCancel();

          return vRedirector.redirectFunction?.call(
            vRouterDelegate: this,
            vRouteElementNode:
                _vRoute.vRouteElementNode.getChildVRouteElementNode(
                      vRouteElement:
                          vWidgetGuardMessageRoot.associatedVRouteElement,
                    ) ??
                    _vRoute.vRouteElementNode,
          );
        }
      }

      ///   2. Call beforeLeave in all deactivated [VRouteElement]
      for (var vRouteElement in deactivatedVRouteElements) {
        await vRouteElement.beforeLeave(vRedirector, saveHistoryState);
        if (!vRedirector.shouldUpdate) {
          await onCancel();

          return vRedirector.redirectFunction?.call(
            vRouterDelegate: this,
            vRouteElementNode:
                _vRoute.vRouteElementNode.getChildVRouteElementNode(
                      vRouteElement: vRouteElement,
                    ) ??
                    _vRoute.vRouteElementNode,
          );
        }
      }

      /// 3. Call beforeLeave in the [VRouter]
      await _rootVRouter.beforeLeave(vRedirector, saveHistoryState);
      if (!vRedirector.shouldUpdate) {
        await onCancel();

        return vRedirector.redirectFunction?.call(
          vRouterDelegate: this,
          vRouteElementNode:
              _vRoute.vRouteElementNode.getChildVRouteElementNode(
                    vRouteElement: _rootVRouter,
                  ) ??
                  _vRoute.vRouteElementNode,
        );
      }
    }

    if (newVRoute != null) {
      /// 4. Call beforeEnter in the [VRouter]
      await _rootVRouter.beforeEnter(vRedirector);
      if (!vRedirector.shouldUpdate) {
        await onCancel();

        return vRedirector.redirectFunction?.call(
          vRouterDelegate: this,
          vRouteElementNode:
              _vRoute.vRouteElementNode.getChildVRouteElementNode(
                    vRouteElement: _rootVRouter,
                  ) ??
                  _vRoute.vRouteElementNode,
        );
      }

      /// 5. Call beforeEnter in all initialized [VRouteElement] of the new route
      for (var vRouteElement in initializedVRouteElements) {
        await vRouteElement.beforeEnter(vRedirector);
        if (!vRedirector.shouldUpdate) {
          await onCancel();

          return vRedirector.redirectFunction?.call(
            vRouterDelegate: this,
            vRouteElementNode:
                _vRoute.vRouteElementNode.getChildVRouteElementNode(
                      vRouteElement: vRouteElement,
                    ) ??
                    _vRoute.vRouteElementNode,
          );
        }
      }

      /// 6. Call beforeUpdate in all reused [VWidgetGuard]
      for (var vWidgetGuardMessageRoot in reusedVWidgetGuardsMessagesRoot) {
        await vWidgetGuardMessageRoot.vWidgetGuard.beforeUpdate(vRedirector);
        if (!vRedirector.shouldUpdate) {
          await onCancel();

          return vRedirector.redirectFunction?.call(
              vRouterDelegate: this,
              vRouteElementNode:
                  _vRoute.vRouteElementNode.getChildVRouteElementNode(
                        vRouteElement:
                            vWidgetGuardMessageRoot.associatedVRouteElement,
                      ) ??
                      _vRoute.vRouteElementNode);
        }
      }

      /// 7. Call beforeUpdate in all reused [VRouteElement]
      for (var vRouteElement in reusedVRouteElements) {
        await vRouteElement.beforeUpdate(vRedirector);
        if (!vRedirector.shouldUpdate) {
          await onCancel();

          return vRedirector.redirectFunction?.call(
            vRouterDelegate: this,
            vRouteElementNode:
                _vRoute.vRouteElementNode.getChildVRouteElementNode(
                      vRouteElement: vRouteElement,
                    ) ??
                    _vRoute.vRouteElementNode,
          );
        }
      }
    }

    if (historyStateToSave.isNotEmpty && url != null) {
      ///   The historyStates got in beforeLeave are stored   ///
      // If we come from the browser, chances are we already left the page
      // So we need to:
      //    1. Go back to where we were
      //    2. Save the historyState
      //    3. And go back again to the place
      _ignoreNextBrowserCalls = true;
      await _vRouterScope.vHistory.replaceLocation(
        VRouteInformation(url: newUrl, state: historyStateToSave),
      );
      _ignoreNextBrowserCalls = false;
    }

    /// Call afterLeave in all deactivated [VRouteElement]
    for (var vRouteElement in deactivatedVRouteElements) {
      vRouteElement.afterLeave(
        _rootVRouterContext,
        url,
        newUrl,
      );
    }

    /// Remove any Navigator 1.0 push
    navigatorKey.currentState?.popUntil((route) => route.settings is Page);

    ///   The state of the VRouter changes            ///
    final _oldUrl = url;

    if (newVRoute != null) {
      _updateStateVariables(
        newVRoute,
        newUri,
        historyState: newHistoryState,
        deactivatedVWidgetGuardsMessagesRoot:
            deactivatedVWidgetGuardsMessagesRoot,
      );
    }
    onUpdate();
    notifyListeners();

    // We need to do this after rebuild as completed so that the user can have access
    // to the new state variables
    WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
      /// 8. Call afterEnter in all initialized [VWidgetGuard]
      // This is done automatically by VNotificationGuard

      /// 9. Call afterEnter all initialized [VRouteElement]
      for (var vRouteElement in initializedVRouteElements) {
        vRouteElement.afterEnter(
          _rootVRouterContext,
          // TODO: Change this to local context? This might imply that we need a global key which is not ideal
          _oldUrl,
          newUrl,
        );
      }

      /// 10. Call afterEnter in the [VRouter]
      _rootVRouter.afterEnter(_rootVRouterContext, _oldUrl, newUrl);

      /// 11. Call afterUpdate in all reused [VWidgetGuard]
      for (var vWidgetGuardMessageRoot in reusedVWidgetGuardsMessagesRoot) {
        vWidgetGuardMessageRoot.vWidgetGuard.afterUpdate(
          vWidgetGuardMessageRoot.localContext,
          _oldUrl,
          newUrl,
        );
      }

      /// 12. Call afterUpdate in all reused [VRouteElement]
      for (var vRouteElement in reusedVRouteElements) {
        vRouteElement.afterUpdate(
          _rootVRouterContext,
          // TODO: Change this to local context? This might imply that we need a global key which is not ideal
          _oldUrl,
          newUrl,
        );
      }
    });
  }

  /// Performs a systemPop cycle:
  ///   1. Call onPop in all active [VWidgetGuards]
  ///   2. Call onPop in all [VRouteElement]
  ///   3. Call onPop of VRouter
  ///   4. Update the url to the one found in [_defaultPop]
  Future<void> _pop(VPopData vPopData) async {
    assert(url != null);

    // Get information on where to pop from _defaultPop
    final defaultPopResult = _defaultPop(vPopData);

    final vRedirector = defaultPopResult.vRedirector;

    final poppedVRouteElements = defaultPopResult.poppedVRouteElements;

    final List<VWidgetGuardMessageRoot> poppedVWidgetGuardsMessagesRoot =
        _vWidgetGuardMessagesRoot
            .where(
              (vWidgetGuardMessageRoot) =>
                  poppedVRouteElements.contains(
                      vWidgetGuardMessageRoot.associatedVRouteElement) ||
                  vWidgetGuardMessageRoot.associatedVRouteElement ==
                      _rootVRouter, // Any such vWidgetGuardMessageRoot belongs to a nav1 push and will therefore be removed
            )
            .toList();

    /// 1. Call onPop in all popped [VWidgetGuards]
    for (var vWidgetGuardMessageRoot in poppedVWidgetGuardsMessagesRoot) {
      await vWidgetGuardMessageRoot.vWidgetGuard.onPop(vRedirector);
      if (!vRedirector.shouldUpdate) {
        vRedirector.redirectFunction?.call(
          vRouterDelegate: this,
          vRouteElementNode: _vRoute.vRouteElementNode
                  .getChildVRouteElementNode(
                      vRouteElement:
                          vWidgetGuardMessageRoot.associatedVRouteElement) ??
              _vRoute.vRouteElementNode,
        );
        return;
      }
    }

    /// 2. Call onPop in all popped [VRouteElement]
    for (var vRouteElement in poppedVRouteElements) {
      await vRouteElement.onPop(vRedirector);
      if (!vRedirector.shouldUpdate) {
        vRedirector.redirectFunction?.call(
          vRouterDelegate: this,
          vRouteElementNode: _vRoute.vRouteElementNode
                  .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
              _vRoute.vRouteElementNode,
        );
        return;
      }
    }

    /// 3. Call onPop of VRouter
    await _rootVRouter.onPop(vRedirector);
    if (!vRedirector.shouldUpdate) {
      vRedirector.redirectFunction?.call(
        vRouterDelegate: this,
        vRouteElementNode: _vRoute.vRouteElementNode
                .getChildVRouteElementNode(vRouteElement: _rootVRouter) ??
            _vRoute.vRouteElementNode,
      );
      return;
    }

    /// 4. Update the url to the one found in [_defaultPop]
    if (defaultPopResult.error != null) {
      throw defaultPopResult.error!;
    } else if (vRedirector.newVRouterData != null) {
      final newUri = Uri.parse(vRedirector.toUrl!);

      _updateUrl(
        newUri,
        newVRoute: _getNewVRoute(
          uri: newUri,
          historyState: vPopData.newHistoryState,
        ),
        newHistoryState: vPopData.newHistoryState,
        onCancel: () {
          VLogPrinter.show(
            VStoppedNavigationTo(
              vNavigationMethod: VNavigationMethod.pop,
              url: vRedirector.toUrl!,
            ),
          );
        },
        onUpdate: () {
          _vRouterScope.vHistory.pushLocation(
            VRouteInformation(
              url: vRedirector.toUrl!,
              state: vPopData.newHistoryState,
            ),
          );
          VLogPrinter.show(
            VSuccessfulNavigationTo(
              vNavigationMethod: VNavigationMethod.pop,
              url: vRedirector.toUrl!,
            ),
          );
        },
      ); // We don't set query parameters because they are already in the url
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
  Future<void> _systemPop(VPopData vPopData) async {
    assert(url != null);

    // Get information on where to pop from _defaultPop
    final defaultPopResult = _defaultPop(vPopData);

    final vRedirector = defaultPopResult.vRedirector;

    final poppedVRouteElements = defaultPopResult.poppedVRouteElements;

    final List<VWidgetGuardMessageRoot> poppedVWidgetGuardsMessagesRoot =
        _vWidgetGuardMessagesRoot
            .where(
              (vWidgetGuardMessageRoot) =>
                  poppedVRouteElements.contains(
                      vWidgetGuardMessageRoot.associatedVRouteElement) ||
                  vWidgetGuardMessageRoot.associatedVRouteElement ==
                      _rootVRouter, // Any such vWidgetGuardMessageRoot belongs to a nav1 push and will therefore be removed
            )
            .toList();

    /// 1. Call onSystemPop in all popping [VWidgetGuards] if implemented, else onPop
    for (var vWidgetGuardMessageRoot in poppedVWidgetGuardsMessagesRoot) {
      if (vWidgetGuardMessageRoot.vWidgetGuard.onSystemPop !=
          VoidVPopHandler.voidOnSystemPop) {
        await vWidgetGuardMessageRoot.vWidgetGuard.onSystemPop(vRedirector);
      } else {
        await vWidgetGuardMessageRoot.vWidgetGuard.onPop(vRedirector);
      }
      if (!vRedirector.shouldUpdate) {
        vRedirector.redirectFunction?.call(
          vRouterDelegate: this,
          vRouteElementNode: _vRoute.vRouteElementNode
                  .getChildVRouteElementNode(
                      vRouteElement:
                          vWidgetGuardMessageRoot.associatedVRouteElement) ??
              _vRoute.vRouteElementNode,
        );
        return;
      }
    }

    /// 2. Call onSystemPop in all popped [VRouteElement] if implemented, else onPop
    for (var vRouteElement in poppedVRouteElements) {
      if (vRouteElement.onSystemPop != VoidVPopHandler.voidOnSystemPop) {
        await vRouteElement.onSystemPop(vRedirector);
      } else {
        await vRouteElement.onPop(vRedirector);
      }
      if (!vRedirector.shouldUpdate) {
        vRedirector.redirectFunction?.call(
          vRouterDelegate: this,
          vRouteElementNode: _vRoute.vRouteElementNode
                  .getChildVRouteElementNode(vRouteElement: vRouteElement) ??
              _vRoute.vRouteElementNode,
        );
        return;
      }
    }

    /// 3. Call onSystemPop of VRouter if implemented, else onPop
    if (_rootVRouter.onSystemPop != VoidVPopHandler.voidOnSystemPop) {
      await _rootVRouter.onSystemPop(vRedirector);
    } else {
      await _rootVRouter.onPop(vRedirector);
    }
    if (!vRedirector.shouldUpdate) {
      vRedirector.redirectFunction?.call(
        vRouterDelegate: this,
        vRouteElementNode: _vRoute.vRouteElementNode
                .getChildVRouteElementNode(vRouteElement: _rootVRouter) ??
            _vRoute.vRouteElementNode,
      );
      return;
    }

    /// 4. Update the url to the one found in [_defaultPop]
    if (defaultPopResult.error != null) {
      throw defaultPopResult.error!;
    } else if (vRedirector.newVRouterData != null) {
      final newUri = Uri.parse(vRedirector.toUrl!);

      _updateUrl(
        newUri,
        newVRoute: _getNewVRoute(
          uri: newUri,
          historyState: vPopData.newHistoryState,
        ),
        newHistoryState: vPopData.newHistoryState,
        onCancel: () {
          VLogPrinter.show(
            VStoppedNavigationTo(
              vNavigationMethod: VNavigationMethod.systemPop,
              url: vRedirector.toUrl!,
            ),
          );
        },
        onUpdate: () {
          _vRouterScope.vHistory.pushLocation(
            VRouteInformation(
              url: vRedirector.toUrl!,
              state: vPopData.newHistoryState,
            ),
          );
          VLogPrinter.show(
            VSuccessfulNavigationTo(
              vNavigationMethod: VNavigationMethod.systemPop,
              url: vRedirector.toUrl!,
            ),
          );
        },
      ); // We don't set query parameters because they are already in the url
    } else if (Platform.isAndroid || Platform.isIOS) {
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
  DefaultPopResult _defaultPop(VPopData vPopData) {
    assert(url != null);
    // Encode the path parameters
    final pathParameters = vPopData.pathParameters
        .map((key, value) => MapEntry(key, Uri.encodeComponent(value)));

    // We don't use widget.getPathFromPop because widget.routes might have changed with a setState
    final popResult = _vRoute.vRouteElementNode.vRouteElement.getPathFromPop(
      vPopData.elementToPop,
      pathParameters: pathParameters,
      parentPathResult: ValidParentPathResult(path: null, pathParameters: {}),
    );

    // If any popError has been encountered, we pass it in the result
    // We don't yield it here because a VRouteElement can still stop the popping
    late final ErrorPopResult? popError;
    popError = (popResult is ErrorPopResult) ? popResult : null;

    // If popResult is not ErrorPopResult, it is either
    // ValidPopResult or PoppingPopResult
    final newPath = (popResult is ValidPopResult) ? popResult.path : null;
    final newNames =
        (popResult is ValidPopResult) ? popResult.names : <String>[];

    // This url will be not null if we find a route to go to
    late final String? newUrl;
    late final VRedirectorData? newVRouterData;

    // If newPath is empty then the app should be put in the background (for mobile)
    if (newPath != null) {
      // Integrate the given query parameters
      newUrl = Uri.tryParse(newPath)
          ?.replace(
              queryParameters: (vPopData.queryParameters.isNotEmpty)
                  ? vPopData.queryParameters
                  : null)
          .toString();

      newVRouterData = VRedirectorData(
        historyState: vPopData.newHistoryState,
        pathParameters: vPopData.pathParameters,
        queryParameters: vPopData.queryParameters,
        // Remove the hash when popping
        url: newUrl,
        previousUrl: url,
        names: newNames,
      );
    } else {
      newUrl = null;
      newVRouterData = null;
    }

    final vNodeToPop = _vRoute.vRouteElementNode
        .getVRouteElementNodeFromVRouteElement(vPopData.elementToPop);

    assert(vNodeToPop != null);

    // This is the list of [VRouteElement]s that where not necessary expected to pop but did because of
    // the pop of [elementToPop]
    final List<VRouteElement> poppedVRouteElementsFromPopResult =
        (popResult is FoundPopResult) ? popResult.poppedVRouteElements : [];

    // This is predictable list of [VRouteElement]s that are expected to pop because they are
    // in the nestedRoutes or stackedRoutes of [elementToPop] [VRouteElementNode]
    // We take the reversed because we when to call onPop in the deepest nested
    // [VRouteElement] first
    final poppedVRouteElementsFromVNode =
        vNodeToPop!.getVRouteElements().reversed.toList();

    // This is the list of every [VRouteElement] which should pop
    final poppedVRouteElements =
        poppedVRouteElementsFromVNode + poppedVRouteElementsFromPopResult;

    // elementToPop should have a duplicate so we remove it
    poppedVRouteElements
        .removeAt(poppedVRouteElements.indexOf(vPopData.elementToPop));

    return DefaultPopResult(
      vRedirector: VRedirector(
        vRouterDelegate: this,
        fromUrl: url,
        toUrl: newUrl,
        previousVRouterData: VRedirectorData(
          historyState: historyState,
          pathParameters: _vRoute.pathParameters,
          queryParameters: queryParameters,
          previousUrl: previousUrl,
          url: url,
          names: names,
        ),
        newVRouterData: newVRouterData,
      ),
      poppedVRouteElements: poppedVRouteElements,
      error: popError,
    );
  }

  /// This replaces the current history state of [VRouter] with given one
  @Deprecated(
      'Use to(context.vRouter.url!, isReplacement: true, historyState: newHistoryState) instead')
  void replaceHistoryState(Map<String, String> newHistoryState) => to(
        (url != null) ? Uri.parse(url!).path : '/',
        historyState: newHistoryState,
        isReplacement: true,
      );

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
      vRouterDelegate: this,
      fromUrl: url,
      toUrl: null,
      previousVRouterData: VRedirectorData(
        historyState: historyState,
        pathParameters: _vRoute.pathParameters,
        queryParameters: this.queryParameters,
        url: url,
        previousUrl: previousUrl,
        names: names,
      ),
      newVRouterData: null,
    );

    ///   1. Call beforeLeave in all deactivated [VWidgetGuard]
    for (var vWidgetGuardMessageRoot in _vWidgetGuardMessagesRoot) {
      await vWidgetGuardMessageRoot.vWidgetGuard
          .beforeLeave(vRedirector, saveHistoryState);
    }

    ///   2. Call beforeLeave in all deactivated [VRouteElement] and [VRouter]
    for (var vRouteElement in _vRoute.vRouteElements.reversed) {
      await vRouteElement.beforeLeave(vRedirector, saveHistoryState);
    }

    if (historyStateToSave.isNotEmpty) {
      ///   The historyStates got in beforeLeave are stored   ///
      _vRouterScope.vHistory.replaceLocation(
        VRouteInformation(
          url: url!,
          state: historyStateToSave,
        ),
      );
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
    String? hash,
    Map<String, String> newHistoryState = const {},
  }) async {
    navigatorKey.currentState!.pop(
      VPopData(
        elementToPop: _vRoute.vRouteElementNode.getVRouteElementToPop(),
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        newHistoryState: newHistoryState,
      ),
    );
    return;
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
    String? hash,
    Map<String, String> newHistoryState = const {},
  }) async {
    // Try to pop a Nav1 page
    bool hasNav1Pushed = false;
    navigatorKey.currentState!.popUntil((route) {
      if (!hasNav1Pushed && !(route.settings is Page)) {
        hasNav1Pushed = true;
      }
      return true;
    });

    // If successful, warn the VWidgetGuards
    if (hasNav1Pushed) {
      // Check for nav1 pushed routes
      final vRouterData = VRedirectorData(
        historyState: historyState,
        pathParameters: _vRoute.pathParameters,
        queryParameters: this.queryParameters,
        url: url,
        previousUrl: previousUrl,
        names: names,
      );
      final vRedirector = VRedirector(
        fromUrl: url,
        toUrl: url,
        previousVRouterData: vRouterData,
        newVRouterData: vRouterData,
        vRouterDelegate: this,
      );

      // Get Nav1 VWidgetGuardMessagesRoot
      final nav1VWidgetGuardMessagesRoot = _vWidgetGuardMessagesRoot.where(
        (element) => element.associatedVRouteElement == _rootVRouter,
      );
      final nav1VWidgetGuardMessageRoot =
          nav1VWidgetGuardMessagesRoot.length > 0
              ? nav1VWidgetGuardMessagesRoot.last
              : null;
      nav1VWidgetGuardMessageRoot?.vWidgetGuard.onSystemPop(vRedirector);
      if (!vRedirector.shouldUpdate) {
        return;
      }

      // If last nav1 route did not stop the popping, pop
      _vWidgetGuardMessagesRoot.remove(nav1VWidgetGuardMessageRoot);
      navigatorKey.currentState!.pop();
      return;
    }

    _systemPop(
      VPopData(
        elementToPop: _vRoute.vRouteElementNode.getVRouteElementToSystemPop(),
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        newHistoryState: newHistoryState,
      ),
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
  @Deprecated('Use toNamed instead')
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
  @Deprecated('Use vRouter.to(..., isReplacement: true) instead')
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    Map<String, String> historyState = const {},
  }) =>
      to(
        newUrl,
        queryParameters: queryParameters,
        historyState: historyState,
        isReplacement: true,
      );

  /// Pushes a new url based on url segments
  ///
  /// For example: pushSegments(['home', 'bob']) ~ push('/home/bob')
  ///
  /// The advantage of using this over push is that each segment gets encoded.
  /// For example: pushSegments(['home', 'bob marley']) ~ push('/home/bob%20marley')
  ///
  /// Also see:
  ///  - [to] to see want happens when you push a new url
  @Deprecated('Use toSegments instead')
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
  @Deprecated('Use vRouter.toNamed(..., isReplacement: true) instead')
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

  /// Goes to an url which is not in the app
  ///
  /// On the web, you can set [openNewTab] to true to open this url
  /// in a new tab
  @Deprecated('Use toExternal instead')
  void pushExternal(String newUrl, {bool openNewTab = false}) =>
      toExternal(newUrl, openNewTab: openNewTab);

  /// The main method to navigate to a new path
  ///
  ///
  /// Note that the path should be a valid url. If you
  /// fear part of you url might need encoding, use [toSegments]
  /// instead
  ///
  ///
  /// [path] can be of one of two forms:
  ///   * stating with '/', in which case we just navigate
  ///     to the given path
  ///   * not starting with '/', in which case we append the
  ///     current path to the given one
  ///
  /// [hash] will be added after a hash sign (#) in the url
  /// (this will not appear if empty)
  ///
  /// [queryParameters] to add query parameters (you can also
  ///  add them manually)
  ///
  /// [historyState] is used an the web to restore browser
  /// history entry specific state (like scroll amount)
  ///
  /// [isReplacement] determines whether to overwrite the current
  /// history entry or create a new one. The is mainly useful
  /// when using [back], [forward] or [historyGo], or on the web to control
  /// the browser history entries
  ///
  ///
  /// Also see:
  ///   - [toSegments] if you need your path segments to be encoded
  ///   - [toNamed] if you want to navigate by name
  ///   - [toExternal] if you want to navigate to an external url
  void to(
    String path, {
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
    isReplacement = false,
  }) {
    // Don't display the hash if it is empty
    final _hash = (hash?.isEmpty ?? true) ? null : hash;

    if (!path.startsWith('/')) {
      if (url == null) {
        throw InvalidUrlVError(url: path);
      }
      final currentPath = Uri.parse(url!).path;
      path = currentPath + (currentPath.endsWith('/') ? '' : '/') + path;
    }

    // Extract query parameters if any was passed directly in [path]
    final pathUri = Uri.parse(path);

    final pathQueryParameters = pathUri.queryParameters;
    final pathHash = pathUri.fragment.isEmpty ? null : pathUri.fragment;
    path = pathUri.path; // Update the path if there where queryParameters

    assert(
      pathQueryParameters.isEmpty || queryParameters.isEmpty,
      'Some path parameters where passed using [path] AND other using [queryParameters]\n'
      'Use one or the other but not both',
    );

    final uri = Uri(
      path: path,
      queryParameters: queryParameters.isNotEmpty
          ? queryParameters
          : pathQueryParameters.isNotEmpty
              ? pathQueryParameters
              : null,
      fragment: _hash ?? pathHash,
    );

    _updateUrl(
      uri,
      newVRoute: _getNewVRoute(uri: uri, historyState: historyState),
      newHistoryState: historyState,
      onCancel: () {
        VLogPrinter.show(
          VStoppedNavigationTo(
            vNavigationMethod: VNavigationMethod.to,
            url: uri.toString(),
          ),
        );
      },
      onUpdate: () {
        final _updateLocation = isReplacement
            ? _vRouterScope.vHistory.replaceLocation
            : _vRouterScope.vHistory.pushLocation;

        _updateLocation(
          VRouteInformation(
            url: uri.toString(),
            state: historyState,
          ),
        );
        VLogPrinter.show(
          VSuccessfulNavigationTo(
            vNavigationMethod: VNavigationMethod.to,
            url: uri.toString(),
          ),
        );
      },
    );
  }

  /// Navigates to a new url based on path segments
  ///
  /// For example: pushSegments(['home', 'bob']) ~ push('/home/bob')
  ///
  /// The advantage of using this over push is that each segment gets encoded.
  /// For example: pushSegments(['home', 'bob marley']) ~ push('/home/bob%20marley')
  ///
  /// [hash] will be added after a hash sign (#) in the url
  /// (this will not appear if empty)
  ///
  /// [queryParameters] to add query parameters (you can also
  ///  add them manually)
  ///
  /// [historyState] is used an the web to restore browser
  /// history entry specific state (like scroll amount)
  ///
  /// [isReplacement] determines whether to overwrite the current
  /// history entry or create a new one. The is mainly useful
  /// when using [back], [forward] or [historyGo], or on the web to control
  /// the browser history entries
  ///
  ///
  /// Also see:
  ///  - [to] if you don't need segment encoding
  ///  - [toNamed] if you want to navigate by name
  ///  - [toExternal] if you want to navigate to an external url
  void toSegments(
    List<String> segments, {
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
    isReplacement = false,
  }) {
    // Forming the new url by encoding each segment and placing "/" between them
    final newUrl =
        segments.map((segment) => Uri.encodeComponent(segment)).join('/');

    // Calling push with this newly formed url
    return to(
      '/$newUrl',
      queryParameters: queryParameters,
      hash: hash,
      historyState: historyState,
      isReplacement: isReplacement,
    );
  }

  /// [pathParameters] needs to specify every path parameters
  /// contained in the path corresponding to [name]
  ///
  /// [hash] will be added after a hash sign (#) in the url
  /// (this will not appear if empty)
  ///
  /// [queryParameters] to add query parameters (you can also
  ///  add them manually)
  ///
  /// [historyState] is used an the web to restore browser
  /// history entry specific state (like scroll amount)
  ///
  /// [isReplacement] determines whether to overwrite the current
  /// history entry or create a new one. The is mainly useful
  /// when using [back], [forward] or [historyGo], or on the web to control
  /// the browser history entries
  ///
  ///
  /// Also see:
  ///  - [to] if you don't need segment encoding
  ///  - [toSegments] if you need your path segments to be encoded
  ///  - [toExternal] if you want to navigate to an external url
  void toNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
    bool isReplacement = false,
  }) {
    final uri = Uri(
      path: _getUrlFromName(
        name,
        pathParameters: pathParameters,
      ),
      queryParameters: queryParameters.isNotEmpty ? queryParameters : null,
      fragment: (hash?.isNotEmpty ?? false) ? hash : null,
    );

    _updateUrl(
      uri,
      newVRoute: _getNewVRoute(uri: uri, historyState: historyState),
      newHistoryState: historyState,
      onCancel: () {
        VLogPrinter.show(
          VStoppedNavigationTo(
            vNavigationMethod: VNavigationMethod.toNamed,
            url: uri.toString(),
          ),
        );
      },
      onUpdate: () {
        final _updateLocation = isReplacement
            ? _vRouterScope.vHistory.replaceLocation
            : _vRouterScope.vHistory.pushLocation;

        // If the navigation is successful, sync the vHistory
        // This also pushes to the browser if needed
        _updateLocation(
          VRouteInformation(
            url: uri.toString(),
            state: historyState,
          ),
        );
        VLogPrinter.show(
          VSuccessfulNavigationTo(
            vNavigationMethod: VNavigationMethod.toNamed,
            url: uri.toString(),
          ),
        );
      },
    );
  }

  /// Goes to an url which is not in the app
  ///
  ///
  /// On the web, you can set [openNewTab] to true to open this url
  /// in a new tab
  ///
  ///
  /// Also see:
  ///  - [to] if you don't need segment encoding
  ///  - [toSegments] if you need your path segments to be encoded
  ///  - [toNamed] if you want to navigate by name
  void toExternal(String newUrl, {bool openNewTab = false}) => _updateUrl(
        Uri.parse(newUrl),
        newVRoute: null, // Since it's external, we have no new VRoute
        onCancel: () {
          VLogPrinter.show(
            VStoppedNavigationTo(
              vNavigationMethod: VNavigationMethod.toExternal,
              url: newUrl,
            ),
          );
        },
        onUpdate: () {
          VLogPrinter.show(
            VSuccessfulNavigationTo(
              vNavigationMethod: VNavigationMethod.toExternal,
              url: newUrl,
            ),
          );

          BrowserHelpers.pushExternal(newUrl, openNewTab: openNewTab);
        },
      );

  /// Goes forward 1 in the url history
  ///
  ///
  /// Throws an exception if this is not possible
  /// Use [historyCanForward] to know if this is possible
  void historyForward() => historyGo(1);

  /// Goes back 1 in the url history
  ///
  ///
  /// Throws an exception if this is not possible
  /// Use [historyCanBack] to know if this is possible
  void historyBack() => historyGo(-1);

  /// Goes jumps of [delta] in the url history
  ///
  ///
  /// Throws an exception if this is not possible
  /// Use [historyCanGo] to know if this is possible
  void historyGo(int delta) {
    final vRouteInformation = _vRouterScope.vHistory.vRouteInformationAt(delta);

    if (!Platform.isWeb) {
      assert(vRouteInformation != null);

      final newUri = Uri.parse(vRouteInformation!.url);
      _updateUrl(
        newUri,
        newHistoryState: vRouteInformation.state,
        newVRoute:
            _getNewVRoute(uri: newUri, historyState: vRouteInformation.state),
        onCancel: () {
          VLogPrinter.show(
            VStoppedNavigationTo(
              vNavigationMethod: VNavigationMethod.vHistory,
              url: newUri.toString(),
            ),
          );
        },
        onUpdate: () {
          VLogPrinter.show(
            VSuccessfulNavigationTo(
              vNavigationMethod: VNavigationMethod.vHistory,
              url: newUri.toString(),
            ),
          );

          // If the navigation is successful, sync the vHistory
          _vRouterScope.vHistory.go(delta);
        },
      );
    } else {
      BrowserHelpers.browserGo(delta);
    }
  }

  /// Check whether going forward 1 in the history url is possible
  bool historyCanForward() => historyCanGo(1);

  /// Check whether going back 1 in the history url is possible
  bool historyCanBack() => historyCanGo(-1);

  /// Check whether jumping of [delta] in the history url is possible
  bool historyCanGo(int delta) => _vRouterScope.vHistory.canGo(delta);

  /// handles systemPop
  @override
  Future<bool> popRoute() async {
    await systemPop(pathParameters: pathParameters);
    return true;
  }

  void _initialize(BuildContext context) {
    assert(
        !_isInitialized,
        'VRouterDelegate has already been initialized, it should not be initialized multiple times.'
        'Please check VRouterDelegate._isInitialized');

    final vHistory = _vRouterScope.vHistory;

    // Check if this is the first route
    if (vHistory.historyIndex == 0) {
      // Check if this is the first route

      if (vHistory.currentLocation.url != '' &&
          vHistory.currentLocation.url != '/') {
        // Is this '' or '/' ? Both seem to appear from time to time
        // If we are deep-linking, just deep-link
        final url = vHistory.currentLocation.url;
        final uri = Uri.parse(url);
        to(
          uri.path,
          queryParameters: uri.queryParameters,
          hash: uri.fragment.isEmpty ? null : Uri.decodeComponent(uri.fragment),
          historyState: vHistory.currentLocation.state,
          isReplacement: true,
        );
      } else {
        // Else go to [initialUrl]
        final initialUri = Uri.parse(initialUrl);
        to(
          initialUri.path,
          queryParameters: initialUri.queryParameters,
          hash: initialUri.fragment.isEmpty
              ? null
              : Uri.decodeComponent(initialUri.fragment),
          isReplacement: true,
        );
      }
    } else {
      // This happens when VRouter is rebuilt, either because:
      //   - The entire app has been rebuilt
      //   - VRouter.navigatorKey has changed
      // In this case we use _vLocations to get the current location
      final url = vHistory.currentLocation.url;
      final uri = Uri.parse(url);
      to(
        uri.path,
        queryParameters: uri.queryParameters,
        hash: uri.fragment.isEmpty ? null : Uri.decodeComponent(uri.fragment),
        historyState: vHistory.currentLocation.state,
        isReplacement: true,
      );
    }

    _isInitialized = true;
  }

  @override
  SynchronousFuture<void> setInitialRoutePath(RouteInformation configuration) {
    return SynchronousFuture(null);
  }

  /// Navigation state to app state
  @override
  Future<void> setNewRoutePath(RouteInformation routeInformation) async {
    if (routeInformation.location != null && !_ignoreNextBrowserCalls) {
      final newUrl = routeInformation.location!;

      final routeState = routeInformation.state as Map<String, dynamic>?;

      final newJsonState = routeState?['app'];

      // Get the new state
      final Map<String, String> newState = newJsonState != null
          ? newJsonState.map<String, String>(
              (key, value) => MapEntry(
                key.toString(),
                value.toString(),
              ),
            )
          : <String, String>{};

      int? newHistoryIndex = routeState?['historyIndex'];

      // Check if this is the first route
      if (newHistoryIndex == null || newHistoryIndex == 0) {
        // If so, check is the url reported by the browser is the same as the initial url
        // We check "routeInformation.location == '/'" to enable deep linking
        if (newUrl == '/' && newUrl != initialUrl) {
          return;
        }
      }

      // Whether we are visiting a previously visited url
      // or a new one has been pushed
      final bool isPush = newHistoryIndex == null;

      final vNavigationMethod = isPush
          ? VNavigationMethod.browserPush
          : VNavigationMethod.browserHistory;

      final newUri = Uri.parse(newUrl);

      // Update the app with the new url
      await _updateUrl(
        newUri,
        newVRoute: _getNewVRoute(uri: newUri, historyState: newState),
        newHistoryState: newState,
        onCancel: () async {
          VLogPrinter.show(
            VStoppedNavigationTo(
              vNavigationMethod: vNavigationMethod,
              url: newUrl,
            ),
          );

          // If the navigation is canceled and we are on the web, we need to sync the browser
          if (Platform.isWeb) {
            // How much we need to jump in the url history to go back to the previous location
            final historyDelta = isPush
                ? -1
                : _vRouterScope.vHistory.historyIndex - newHistoryIndex;

            // If we can't go simply don't
            if (!historyCanGo(historyDelta)) {
              return;
            }

            // If delta is 0 just stay
            if (historyDelta == 0) {
              return;
            }

            // Else go and wait for the change to happen
            BrowserHelpers.browserGo(historyDelta);
            await BrowserHelpers.onBrowserPopState.first;
          }
        },
        onUpdate: () {
          VLogPrinter.show(
            VSuccessfulNavigationTo(
              vNavigationMethod: vNavigationMethod,
              url: newUrl,
            ),
          );

          // If the navigation is successful, sync the vHistory
          if (isPush) {
            _vRouterScope.vHistory.pushLocation(
              VRouteInformation(url: newUrl, state: newState),
            );
          } else {
            _vRouterScope.vHistory.go(
              newHistoryIndex - _vRouterScope.vHistory.historyIndex,
            );
          }
        },
      );
    }
  }

  /// App state to navigation state
  @override
  RouteInformation? get currentConfiguration {
    if (url == null) return null;

    // We report manually and don't use RouteInformation because flutter
    // does not want to report twice the same RouteInformation
    if (Platform.isWeb) {
      // Don't report to [RouteInformationParser], is this bad ?
      return null;
    }

    return RouteInformation(
      location: url!,
      state: historyState,
    );
  }

  /// Get the last the [VWidgetGuardMessageRoot] which is associated
  /// with nav1 pushes
  ///
  ///
  /// If there are none, return null
  VWidgetGuardMessageRoot? _getLastNav1VWidgetGuardMessageRoot() {
    final nav1VWidgetGuardMessagesRoot = _vWidgetGuardMessagesRoot.where(
      (element) => element.associatedVRouteElement == _rootVRouter,
    );
    return nav1VWidgetGuardMessagesRoot.length > 0
        ? nav1VWidgetGuardMessagesRoot.last
        : null;
  }

  /// Checks if the nav1 routes authorize a pop
  bool _canPopNav1Routes() {
    // Check for nav1 pushed routes
    final vRouterData = VRedirectorData(
      historyState: historyState,
      pathParameters: _vRoute.pathParameters,
      queryParameters: this.queryParameters,
      url: url,
      previousUrl: previousUrl,
      names: names,
    );
    final vRedirector = VRedirector(
      fromUrl: url,
      toUrl: url,
      previousVRouterData: vRouterData,
      newVRouterData: vRouterData,
      vRouterDelegate: this,
    );

    // Get Nav1 VWidgetGuardMessagesRoot
    final nav1VWidgetGuardMessageRoot = _getLastNav1VWidgetGuardMessageRoot();
    nav1VWidgetGuardMessageRoot?.vWidgetGuard.onPop(vRedirector);
    if (!vRedirector.shouldUpdate) {
      return false;
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<VWidgetGuardMessage>(
      onNotification: (VWidgetGuardMessage vWidgetGuardMessage) {
        final vWidgetGuardMessageRoot = VWidgetGuardMessageRoot(
          vWidgetGuardState: vWidgetGuardMessage.vWidgetGuardState,
          localContext: vWidgetGuardMessage.localContext,
          associatedVRouteElement: _rootVRouter,
        );

        if (!_vWidgetGuardMessagesRoot.any(
          (message) =>
              message.vWidgetGuardState ==
                  vWidgetGuardMessageRoot.vWidgetGuardState &&
              message.associatedVRouteElement ==
                  vWidgetGuardMessageRoot.associatedVRouteElement,
        )) {
          _vWidgetGuardMessagesRoot.add(vWidgetGuardMessageRoot);
          WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
            vWidgetGuardMessageRoot.vWidgetGuardState.widget.afterEnter(
                vWidgetGuardMessage.localContext, previousUrl, url!);
          });
        }
        return true;
      },
      child: NotificationListener<VWidgetGuardMessageRoot>(
        onNotification: (VWidgetGuardMessageRoot vWidgetGuardMessageRoot) {
          if (_vWidgetGuardMessagesRoot.indexWhere(
                (message) =>
                    message.vWidgetGuardState ==
                        vWidgetGuardMessageRoot.vWidgetGuardState &&
                    message.associatedVRouteElement ==
                        vWidgetGuardMessageRoot.associatedVRouteElement,
              ) ==
              -1) {
            _vWidgetGuardMessagesRoot.add(vWidgetGuardMessageRoot);
            WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((_) {
              vWidgetGuardMessageRoot.vWidgetGuardState.widget.afterEnter(
                  vWidgetGuardMessageRoot.localContext, previousUrl, url!);
            });
          }

          return true;
        },
        child: RootVRouterData(
          state: this,
          previousUrl: previousUrl,
          url: url ?? '',
          pathParameters: pathParameters,
          historyState: historyState,
          queryParameters: queryParameters,
          namesBuilder: () => names,
          child: Builder(
            builder: (context) {
              _rootVRouterContext = context;
              _vRouterScope = VRouterScope.of(context);

              if (!_isInitialized) _initialize(context);

              final child = _vRoute.pages.isEmpty
                  ? Container()
                  : Navigator(
                      pages: _vRoute.pages.isNotEmpty
                          ? _vRoute.pages
                          : [
                              EmptyPage(),
                            ],
                      key: navigatorKey,
                      observers: [...navigatorObservers],
                      onPopPage: (_, data) {
                        // Try to pop a Nav1 page
                        if (navigatorKey.currentState!.isLastRouteNav1) {
                          if (_canPopNav1Routes()) {
                            // If last nav1 route did not stop the popping, pop
                            final nav1VWidgetGuardMessageRoot =
                                _getLastNav1VWidgetGuardMessageRoot();
                            _vWidgetGuardMessagesRoot
                                .remove(nav1VWidgetGuardMessageRoot);
                            return true;
                          } else {
                            return false;
                          }
                        }

                        late final vPopData;
                        if (data is VPopData) {
                          vPopData = data;
                        } else {
                          vPopData = VPopData(
                            elementToPop: _vRoute.vRouteElementNode
                                .getVRouteElementToPop(),
                            pathParameters: pathParameters,
                            queryParameters: {},
                            hash: '',
                            // Default pop to no hash
                            newHistoryState: {},
                          );
                        }

                        _pop(vPopData);
                        return false;
                      },
                    );

              return builder?.call(context, child) ?? child;
            },
          ),
        ),
      ),
    );
  }
}

class DefaultPopResult {
  /// vRedirector, used to stop the pop or redirect to another url
  VRedirector vRedirector;

  /// Every [VRouteElement] which should be popped with this default pop
  List<VRouteElement> poppedVRouteElements;

  /// The error that might have been encountered when popping
  ErrorPopResult? error;

  DefaultPopResult({
    required this.vRedirector,
    required this.poppedVRouteElements,
    required this.error,
  });
}

/// An [InheritedWidget] which should not be accessed by end developers
///
/// [RootVRouterData] holds methods and parameters from [VRouterState]
class RootVRouterData extends InheritedWidget with InitializedVRouterSailor {
  final VRouterDelegate state;

  RootVRouterData({
    Key? key,
    required Widget child,
    required VRouterDelegate state,
    required this.url,
    required this.previousUrl,
    required this.historyState,
    required this.pathParameters,
    required this.queryParameters,
    required List<String> Function() namesBuilder,
  })  : state = state,
        _namesBuilder = namesBuilder,
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
        old.queryParameters != queryParameters ||
        old.hash != hash);
  }

  @override
  final String url;

  @override
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

  /// A list of every names corresponding to the [VRouteElement]s in
  /// the current stack
  late final List<String> names = _namesBuilder();

  /// A builder to get the names because we want to lazy load them
  final List<String> Function() _namesBuilder;

  /// The duration of the transition which happens when this page
  /// is put in the widget tree
  ///
  /// This should be the default one, i.e. the one of [VRouter]
  Duration? get defaultPageTransitionDuration => state.transitionDuration;

  /// The duration of the transition which happens when this page
  /// is removed from the widget tree
  ///
  /// This should be the default one, i.e. the one of [VRouter]
  Duration? get defaultPageReverseTransitionDuration =>
      state.reverseTransitionDuration;

  /// A function to build the transition to or from this route
  ///
  /// This should be the default one, i.e. the one of [VRouter]git
  Widget Function(
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child)? get defaultPageBuildTransition => state.buildTransition;

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
  void to(
    String path, {
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> historyState = const {},
    isReplacement = false,
  }) =>
      state.to(
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
      state.toSegments(
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
      state.toNamed(
        name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        historyState: historyState,
        isReplacement: isReplacement,
      );

  @override
  void toExternal(String newUrl, {bool openNewTab = false}) => state.toExternal(
        newUrl,
        openNewTab: openNewTab,
      );

  @override
  void historyForward() => state.historyForward();

  @override
  void historyBack() => state.historyBack();

  @override
  void historyGo(int delta) => state.historyGo(delta);

  @override
  bool historyCanForward() => state.historyCanForward();

  @override
  bool historyCanBack() => state.historyCanBack();

  @override
  bool historyCanGo(int delta) => state.historyCanGo(delta);

  @override
  void pop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> newHistoryState = const {},
  }) {
    popFromElement(
      state._vRoute.vRouteElementNode.getVRouteElementToPop(),
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      hash: hash,
      newHistoryState: newHistoryState,
    );
  }

  @override
  Future<void> systemPop({
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> newHistoryState = const {},
  }) =>
      systemPopFromElement(
        state._vRoute.vRouteElementNode.getVRouteElementToSystemPop(),
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        hash: hash,
        newHistoryState: newHistoryState,
      );

  /// See [VRouterState._pop]
  void popFromElement(
    VRouteElement itemToPop, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> newHistoryState = const {},
  }) {
    state.navigatorKey.currentState!.pop(
      VPopData(
        elementToPop: itemToPop,
        pathParameters: {
          ...pathParameters,
          ...this
              .pathParameters, // Include the previous path parameters when popping
        },
        queryParameters: queryParameters,
        hash: hash,
        newHistoryState: newHistoryState,
      ),
    );
  }

  /// See [VRouterState._systemPop]
  Future<void> systemPopFromElement(
    VRouteElement elementToPop, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? hash,
    Map<String, String> newHistoryState = const {},
  }) =>
      state._systemPop(
        VPopData(
          elementToPop: elementToPop,
          pathParameters: {
            ...pathParameters,
            ...this
                .pathParameters, // Include the previous path parameters when popping
          },
          queryParameters: queryParameters,
          hash: hash,
          newHistoryState: newHistoryState,
        ),
      );

  @override
  @Deprecated(
      'Use to(context.vRouter.url!, isReplacement: true, historyState: newHistoryState) instead')
  void replaceHistoryState(Map<String, String> historyState) => to(
        url,
        historyState: historyState,
        isReplacement: true,
      );

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
