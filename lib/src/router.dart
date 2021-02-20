part of 'main.dart';

/// See [VRouter.mode]
enum VRouterModes { hash, history }

/// This widget handles most of the routing work
/// It gives you access to the [routes] attribute where you can start
/// building your routes using [VRouteElement]s
///
/// Note that this widget also acts as a [MaterialApp] so you can pass
/// it every argument that you would expect in [MaterialApp]
class VRouter extends StatefulWidget {
  /// This list holds every possible routes of your app
  final List<VRouteElement> routes;

  /// If implemented, this becomes the default transition for every route transition
  /// except those who implement there own buildTransition
  /// Also see:
  ///   * [VRouteElement.buildTransition] for custom local transitions
  ///
  /// Note that if this is not implemented, every route which does not implement
  /// its own buildTransition will be given a default transition: this of a
  /// [MaterialPage]
  final Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) buildTransition;

  /// The duration of [VRouter.buildTransition]
  final Duration transitionDuration;

  /// The reverse duration of [VRouter.buildTransition]
  final Duration reverseTransitionDuration;

  /// Two router mode are possible:
  ///    - "hash": This is the default, the url will be serverAddress/#/localUrl
  ///    - "history": This will display the url in the way we are used to, without
  ///       the #. However note that you will need to configure your server to make this work.
  ///       Follow the instructions here: [https://router.vuejs.org/guide/essentials/history-mode.html#example-server-configurations]
  final VRouterModes mode;

  /// Called when a url changes, before the url is updated
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouterData methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// [saveHistoryState] can be used to save a history state before leaving
  /// This history state will be restored if the user uses the back button
  /// You will find the saved history state in the [VRouteElementData] using
  /// [VRouterData.of(context).historyState]
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouteElement.beforeLeave] for route level beforeLeave
  ///   * [VNavigationGuard.beforeLeave] for widget level beforeLeave
  ///   * [VRedirector] to known how to redirect and have access to route information
  final Future<void> Function(
    VRedirector vRedirector,
    void Function(String historyState) saveHistoryState,
  ) beforeLeave;

  /// This is called before the url is updated but after all beforeLeave are called
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouterData methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouteElement.beforeEnter] for route level beforeEnter
  ///   * [VRedirector] to known how to redirect and have access to route information
  final Future<void> Function(VRedirector vRedirector) beforeEnter;

  /// This is called after the url and the historyState is updated
  /// You can't prevent the navigation anymore
  /// You can get the new route parameters, and queryParameters
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouteElement.afterEnter] for route level afterEnter
  ///   * [VNavigationGuard.afterEnter] for widget level afterEnter
  final void Function(BuildContext context, String from, String to) afterEnter;

  /// Called after the [VRouteElement.onPopPage] when a pop event occurs
  /// A pop event can be called programmatically (with [VRouterData.of(context).pop()])
  /// or by other widgets such as the appBar back button
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouterData methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// The route you go to is calculated based on [VRouterState._defaultPop]
  ///
  /// Note that you should consider the pop cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Pop%20Events/onPop]
  ///
  /// Also see:
  ///   * [VRouteElement.onPop] for route level onPop
  ///   * [VNavigationGuard.onPop] for widget level onPop
  ///   * [VRouterState._defaultPop] for the default onPop
  final Future<void> Function(VRedirector vRedirector) onPop;

  /// Called after the [VRouteElement.onPopPage] when a system pop event occurs.
  /// This happens on android when the system back button is pressed.
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouterData methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// The route you go to is calculated based on [VRouterState._defaultPop]
  ///
  /// Note that you should consider the systemPop cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Pop%20Events/onSystemPop]
  ///
  /// Also see:
  ///   * [VRouteElement.onSystemPop] for route level onSystemPop
  ///   * [VNavigationGuard.onSystemPop] for widget level onSystemPop
  final Future<void> Function(VRedirector vRedirector) onSystemPop;

  VRouter({
    Key key,
    @required this.routes,
    this.beforeEnter,
    this.beforeLeave,
    this.onPop,
    this.onSystemPop,
    this.afterEnter,
    this.buildTransition,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.mode = VRouterModes.hash,
    // Bellow are the MaterialApp parameters
    this.backButtonDispatcher,
    this.builder,
    this.title = '',
    this.onGenerateTitle,
    this.color,
    this.theme,
    this.darkTheme,
    this.highContrastTheme,
    this.highContrastDarkTheme,
    this.themeMode = ThemeMode.system,
    this.locale,
    this.localizationsDelegates,
    this.localeListResolutionCallback,
    this.localeResolutionCallback,
    this.supportedLocales = const <Locale>[Locale('en', 'US')],
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.checkerboardRasterCacheImages = false,
    this.checkerboardOffscreenLayers = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.shortcuts,
    this.actions,
  }) : super(key: key);

  @override
  VRouterState createState() => VRouterState();

  /// {@macro flutter.widgets.widgetsApp.backButtonDispatcher}
  final BackButtonDispatcher backButtonDispatcher;

  /// {@macro flutter.widgets.widgetsApp.builder}
  ///
  /// Material specific features such as [showDialog] and [showMenu], and widgets
  /// such as [Tooltip], [PopupMenuButton], also require a [Navigator] to properly
  /// function.
  final TransitionBuilder builder;

  /// {@macro flutter.widgets.widgetsApp.title}
  ///
  /// This value is passed unmodified to [WidgetsApp.title].
  final String title;

  /// {@macro flutter.widgets.widgetsApp.onGenerateTitle}
  ///
  /// This value is passed unmodified to [WidgetsApp.onGenerateTitle].
  final GenerateAppTitle onGenerateTitle;

  /// Default visual properties, like colors fonts and shapes, for this app's
  /// material widgets.
  ///
  /// A second [darkTheme] [ThemeData] value, which is used to provide a dark
  /// version of the user interface can also be specified. [themeMode] will
  /// control which theme will be used if a [darkTheme] is provided.
  ///
  /// The default value of this property is the value of [ThemeData.light()].
  ///
  /// See also:
  ///
  ///  * [themeMode], which controls which theme to use.
  ///  * [MediaQueryData.platformBrightness], which indicates the platform's
  ///    desired brightness and is used to automatically toggle between [theme]
  ///    and [darkTheme] in [MaterialApp].
  ///  * [ThemeData.brightness], which indicates the [Brightness] of a theme's
  ///    colors.
  final ThemeData theme;

  /// The [ThemeData] to use when a 'dark mode' is requested by the system.
  ///
  /// Some host platforms allow the users to select a system-wide 'dark mode',
  /// or the application may want to offer the user the ability to choose a
  /// dark theme just for this application. This is theme that will be used for
  /// such cases. [themeMode] will control which theme will be used.
  ///
  /// This theme should have a [ThemeData.brightness] set to [Brightness.dark].
  ///
  /// Uses [theme] instead when null. Defaults to the value of
  /// [ThemeData.light()] when both [darkTheme] and [theme] are null.
  ///
  /// See also:
  ///
  ///  * [themeMode], which controls which theme to use.
  ///  * [MediaQueryData.platformBrightness], which indicates the platform's
  ///    desired brightness and is used to automatically toggle between [theme]
  ///    and [darkTheme] in [MaterialApp].
  ///  * [ThemeData.brightness], which is typically set to the value of
  ///    [MediaQueryData.platformBrightness].
  final ThemeData darkTheme;

  /// The [ThemeData] to use when 'high contrast' is requested by the system.
  ///
  /// Some host platforms (for example, iOS) allow the users to increase
  /// contrast through an accessibility setting.
  ///
  /// Uses [theme] instead when null.
  ///
  /// See also:
  ///
  ///  * [MediaQueryData.highContrast], which indicates the platform's
  ///    desire to increase contrast.
  final ThemeData highContrastTheme;

  /// The [ThemeData] to use when a 'dark mode' and 'high contrast' is requested
  /// by the system.
  ///
  /// Some host platforms (for example, iOS) allow the users to increase
  /// contrast through an accessibility setting.
  ///
  /// This theme should have a [ThemeData.brightness] set to [Brightness.dark].
  ///
  /// Uses [darkTheme] instead when null.
  ///
  /// See also:
  ///
  ///  * [MediaQueryData.highContrast], which indicates the platform's
  ///    desire to increase contrast.
  final ThemeData highContrastDarkTheme;

  /// Determines which theme will be used by the application if both [theme]
  /// and [darkTheme] are provided.
  ///
  /// If set to [ThemeMode.system], the choice of which theme to use will
  /// be based on the user's system preferences. If the [MediaQuery.platformBrightnessOf]
  /// is [Brightness.light], [theme] will be used. If it is [Brightness.dark],
  /// [darkTheme] will be used (unless it is null, in which case [theme]
  /// will be used.
  ///
  /// If set to [ThemeMode.light] the [theme] will always be used,
  /// regardless of the user's system preference.
  ///
  /// If set to [ThemeMode.dark] the [darkTheme] will be used
  /// regardless of the user's system preference. If [darkTheme] is null
  /// then it will fallback to using [theme].
  ///
  /// The default value is [ThemeMode.system].
  ///
  /// See also:
  ///
  ///  * [theme], which is used when a light mode is selected.
  ///  * [darkTheme], which is used when a dark mode is selected.
  ///  * [ThemeData.brightness], which indicates to various parts of the
  ///    system what kind of theme is being used.
  final ThemeMode themeMode;

  /// {@macro flutter.widgets.widgetsApp.color}
  final Color color;

  /// {@macro flutter.widgets.widgetsApp.locale}
  final Locale locale;

  /// {@macro flutter.widgets.widgetsApp.localizationsDelegates}
  ///
  /// Internationalized apps that require translations for one of the locales
  /// listed in [GlobalMaterialLocalizations] should specify this parameter
  /// and list the [supportedLocales] that the application can handle.
  ///
  /// ```dart
  /// import 'package:flutter_localizations/flutter_localizations.dart';
  /// MaterialApp(
  ///   localizationsDelegates: [
  ///     // ... app-specific localization delegate[s] here
  ///     GlobalMaterialLocalizations.delegate,
  ///     GlobalWidgetsLocalizations.delegate,
  ///   ],
  ///   supportedLocales: [
  ///     const Locale('en', 'US'), // English
  ///     const Locale('he', 'IL'), // Hebrew
  ///     // ... other locales the app supports
  ///   ],
  ///   // ...
  /// )
  /// ```
  ///
  /// ## Adding localizations for a new locale
  ///
  /// The information that follows applies to the unusual case of an app
  /// adding translations for a language not already supported by
  /// [GlobalMaterialLocalizations].
  ///
  /// Delegates that produce [WidgetsLocalizations] and [MaterialLocalizations]
  /// are included automatically. Apps can provide their own versions of these
  /// localizations by creating implementations of
  /// [LocalizationsDelegate<WidgetsLocalizations>] or
  /// [LocalizationsDelegate<MaterialLocalizations>] whose load methods return
  /// custom versions of [WidgetsLocalizations] or [MaterialLocalizations].
  ///
  /// For example: to add support to [MaterialLocalizations] for a
  /// locale it doesn't already support, say `const Locale('foo', 'BR')`,
  /// one could just extend [DefaultMaterialLocalizations]:
  ///
  /// ```dart
  /// class FooLocalizations extends DefaultMaterialLocalizations {
  ///   FooLocalizations(Locale locale) : super(locale);
  ///   @override
  ///   String get okButtonLabel {
  ///     if (locale == const Locale('foo', 'BR'))
  ///       return 'foo';
  ///     return super.okButtonLabel;
  ///   }
  /// }
  ///
  /// ```
  ///
  /// A `FooLocalizationsDelegate` is essentially just a method that constructs
  /// a `FooLocalizations` object. We return a [SynchronousFuture] here because
  /// no asynchronous work takes place upon "loading" the localizations object.
  ///
  /// ```dart
  /// class FooLocalizationsDelegate extends LocalizationsDelegate<MaterialLocalizations> {
  ///   const FooLocalizationsDelegate();
  ///   @override
  ///   Future<FooLocalizations> load(Locale locale) {
  ///     return SynchronousFuture(FooLocalizations(locale));
  ///   }
  ///   @override
  ///   bool shouldReload(FooLocalizationsDelegate old) => false;
  /// }
  /// ```
  ///
  /// Constructing a [MaterialApp] with a `FooLocalizationsDelegate` overrides
  /// the automatically included delegate for [MaterialLocalizations] because
  /// only the first delegate of each [LocalizationsDelegate.type] is used and
  /// the automatically included delegates are added to the end of the app's
  /// [localizationsDelegates] list.
  ///
  /// ```dart
  /// MaterialApp(
  ///   localizationsDelegates: [
  ///     const FooLocalizationsDelegate(),
  ///   ],
  ///   // ...
  /// )
  /// ```
  /// See also:
  ///
  ///  * [supportedLocales], which must be specified along with
  ///    [localizationsDelegates].
  ///  * [GlobalMaterialLocalizations], a [localizationsDelegates] value
  ///    which provides material localizations for many languages.
  ///  * The Flutter Internationalization Tutorial,
  ///    <https://flutter.dev/tutorials/internationalization/>.
  final Iterable<LocalizationsDelegate<dynamic>> localizationsDelegates;

  /// {@macro flutter.widgets.widgetsApp.localeListResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleListResolutionCallback localeListResolutionCallback;

  /// {@macro flutter.widgets.LocaleResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleResolutionCallback localeResolutionCallback;

  /// {@macro flutter.widgets.widgetsApp.supportedLocales}
  ///
  /// It is passed along unmodified to the [WidgetsApp] built by this widget.
  ///
  /// See also:
  ///
  ///  * [localizationsDelegates], which must be specified for localized
  ///    applications.
  ///  * [GlobalMaterialLocalizations], a [localizationsDelegates] value
  ///    which provides material localizations for many languages.
  ///  * The Flutter Internationalization Tutorial,
  ///    <https://flutter.dev/tutorials/internationalization/>.
  final Iterable<Locale> supportedLocales;

  /// Turns on a performance overlay.
  ///
  /// See also:
  ///
  ///  * <https://flutter.dev/debugging/#performanceoverlay>
  final bool showPerformanceOverlay;

  /// Turns on checkerboarding of raster cache images.
  final bool checkerboardRasterCacheImages;

  /// Turns on checkerboarding of layers rendered to offscreen bitmaps.
  final bool checkerboardOffscreenLayers;

  /// Turns on an overlay that shows the accessibility information
  /// reported by the framework.
  final bool showSemanticsDebugger;

  /// {@macro flutter.widgets.widgetsApp.debugShowCheckedModeBanner}
  final bool debugShowCheckedModeBanner;

  /// {@macro flutter.widgets.widgetsApp.shortcuts}
  /// {@tool snippet}
  /// This example shows how to add a single shortcut for
  /// [LogicalKeyboardKey.select] to the default shortcuts without needing to
  /// add your own [Shortcuts] widget.
  ///
  /// Alternatively, you could insert a [Shortcuts] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     shortcuts: <LogicalKeySet, Intent>{
  ///       ... WidgetsApp.defaultShortcuts,
  ///       LogicalKeySet(LogicalKeyboardKey.select): const ActivateIntent(),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.shortcuts.seeAlso}
  final Map<LogicalKeySet, Intent> shortcuts;

  /// {@macro flutter.widgets.widgetsApp.actions}
  /// {@tool snippet}
  /// This example shows how to add a single action handling an
  /// [ActivateAction] to the default actions without needing to
  /// add your own [Actions] widget.
  ///
  /// Alternatively, you could insert a [Actions] widget with just the mapping
  /// you want to add between the [WidgetsApp] and its child and get the same
  /// effect.
  ///
  /// ```dart
  /// Widget build(BuildContext context) {
  ///   return WidgetsApp(
  ///     actions: <Type, Action<Intent>>{
  ///       ... WidgetsApp.defaultActions,
  ///       ActivateAction: CallbackAction(
  ///         onInvoke: (Intent intent) {
  ///           // Do something here...
  ///           return null;
  ///         },
  ///       ),
  ///     },
  ///     color: const Color(0xFFFF0000),
  ///     builder: (BuildContext context, Widget child) {
  ///       return const Placeholder();
  ///     },
  ///   );
  /// }
  /// ```
  /// {@end-tool}
  /// {@macro flutter.widgets.widgetsApp.actions.seeAlso}
  final Map<Type, Action<Intent>> actions;

  /// Turns on a [GridPaper] overlay that paints a baseline grid
  /// Material apps.
  ///
  /// Only available in checked mode.
  ///
  /// See also:
  ///
  ///  * <https://material.io/design/layout/spacing-methods.html>
  final bool debugShowMaterialGrid;
}

class VRouterState extends State<VRouter> {
  /// See [VRouterData.url]
  String _url;

  /// See [VRouterData.previousUrl]
  String _previousUrl;

  /// Those are all the pages of the current route
  /// It is computed every time the url is updated
  /// This is mainly used to see which pages are deactivated
  /// vs which ones are reused when the url changes
  List<VPage> flattenPages = [];

  /// This is a list which maps every possible path to the corresponding route
  /// by looking at every [VRouteElement] in [VRouter.routes]
  /// This is only computed once
  List<_VRoutePath> pathToRoutes;

  /// This is a context which contains the VRouter.
  /// It is used is VRouter.beforeLeave for example.
  BuildContext _vRouterInformationContext;

  /// Represent the historyState of the router for the current
  /// history entry.
  /// It is used by the end user to store a global historyState
  /// rather than storing them in [VRouteElementData]
  ///
  /// It can be changed by using [VRouterData.of(context).replaceHistoryState(newState)]
  ///
  /// Also see:
  ///   * [VRouteData.historyState] if you want to use a route level
  ///      version of the historyState
  ///   * [VRouteElementData.historyState] if you want to use a local
  ///      version of the historyState
  String _historyState;

  /// Designates the number of page we navigated since
  /// entering the app.
  /// If is only used in the web to know where we are when
  /// the user interacts with the browser instead of the app
  /// (e.g back button)
  int serialCount;

  /// When set to true, urlToAppState will be ignored
  /// You must manually reset it to true otherwise it will
  /// be ignored forever.
  bool ignoreNextBrowserCalls = false;

  /// Those are used in the root navigator
  /// They are here to prevent breaking animations
  final GlobalKey<NavigatorState> _navigatorKey;
  final HeroController _heroController;

  /// The [VRoute] corresponding to the current url
  VRoute vRoute;

  VRouterState()
      : _navigatorKey = GlobalKey<NavigatorState>(),
        _heroController = HeroController();

  @override
  void initState() {
    // When the app starts, get the serialCount. Default to 0.
    serialCount = (kIsWeb) ? (BrowserHelpers.getHistorySerialCount() ?? 0) : 0;

    // Setup the url strategy
    if (widget.mode == VRouterModes.history) {
      setPathUrlStrategy();
    } else {
      setHashUrlStrategy();
    }

    // Compute every possible path
    pathToRoutes = _getRoutesFlatten(childRoutes: widget.routes);

    // If we are on the web, we listen to any unload event.
    // This allows us to call beforeLeave when the browser or the tab
    // is being closed for example
    if (kIsWeb) {
      BrowserHelpers.onBrowserBeforeUnload.listen((e) => onBeforeUnload());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleUrlHandler(
      urlToAppState:
          (BuildContext context, RouteInformation routeInformation) async {
        if (routeInformation.location != null && !ignoreNextBrowserCalls) {
          // Get the new state
          final newState = (kIsWeb)
              ? Map<String, String>.from(jsonDecode(
                  routeInformation.state as String ??
                      (BrowserHelpers.getHistoryState() ?? '{}')))
              : <String, String>{};

          // Get the new serial count
          var newSerialCount;
          try {
            newSerialCount = int.parse(newState['serialCount'] ?? '');
            // ignore: empty_catches
          } on FormatException {}

          // Update the app with the new url
          await _updateUrl(
            routeInformation.location,
            newState: newState,
            fromBrowser: true,
            newSerialCount: newSerialCount ?? serialCount + 1,
          );
        }
        return null;
      },
      appStateToUrl: () {
        return RouteInformation(
          location: _url ?? '/',
          state: jsonEncode({
            'serialCount': '$serialCount',
            '-2': _historyState,
            '-1': vRoute?.key?.currentState?.historyState,
            for (var pages in flattenPages)
              '${pages.child.depth}':
                  pages.child.stateKey?.currentState?.historyState ??
                      pages.child.initialHistorySate,
          }),
        );
      },
      child: VRouterData(
        url: _url,
        previousUrl: _previousUrl,
        historyState: _historyState,
        updateUrl: (
          String url, {
          Map<String, String> queryParameters = const {},
          Map<String, String> newState = const {},
          bool isUrlExternal = false,
          bool isReplacement = false,
          bool openNewTab = false,
        }) =>
            _updateUrl(
          url,
          queryParameters: queryParameters,
          newState: newState,
          isUrlExternal: isUrlExternal,
          isReplacement: isReplacement,
          openNewTab: openNewTab,
        ),
        updateUrlFromName: _updateUrlFromName,
        pop: _pop,
        systemPop: _systemPop,
        replaceHistoryState: _replaceHistoryState,
        child: Builder(
          builder: (context) {
            _vRouterInformationContext = context;

            // When the app starts, before we process the '/' route, we display
            // a CircularProgressIndicator.
            // Ideally this should never be needed, or replaced with a splash screen
            // Should we add the option ?
            return vRoute ?? Center(child: CircularProgressIndicator());
          },
        ),
      ),
      title: widget.title,
      onGenerateTitle: widget.onGenerateTitle,
      color: widget.color,
      theme: widget.theme,
      darkTheme: widget.darkTheme,
      highContrastTheme: widget.highContrastTheme,
      highContrastDarkTheme: widget.highContrastDarkTheme,
      themeMode: widget.themeMode,
      locale: widget.locale,
      localizationsDelegates: widget.localizationsDelegates,
      localeListResolutionCallback: widget.localeListResolutionCallback,
      localeResolutionCallback: widget.localeResolutionCallback,
      supportedLocales: widget.supportedLocales,
      debugShowMaterialGrid: widget.debugShowMaterialGrid,
      showPerformanceOverlay: widget.showPerformanceOverlay,
      checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages,
      checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers,
      showSemanticsDebugger: widget.showSemanticsDebugger,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner,
      shortcuts: widget.shortcuts,
      actions: widget.actions,
    );
  }

  /// A recursive function which is used to build [pathToRoutes]
  List<_VRoutePath> _getRoutesFlatten({
    @required List<VRouteElement> childRoutes,
    _VRoutePath parentVRoutePath,
  }) {
    final routesFlatten = <_VRoutePath>[];
    final parentPath = parentVRoutePath?.path ?? '';
    var parentVRouteElements = List<VRouteElement>.from(
        parentVRoutePath?.vRouteElements ?? <VRouteElement>[]);

    // For each childRoutes
    for (var childRoute in childRoutes) {
      // Add the VRouteElement to the parent ones to from the VRouteElements list
      final vRouteElements =
          List<VRouteElement>.from([...parentVRouteElements, childRoute]);

      // If the path is null, just get the route from the subroutes
      if (childRoute.path == null) {
        routesFlatten.addAll(
          _getRoutesFlatten(
            childRoutes: childRoute.subroutes,
            parentVRoutePath: _VRoutePath(
              pathRegExp: parentVRoutePath?.pathRegExp,
              path: parentVRoutePath?.path,
              name: null,
              // If no path then no name
              // vRoutes: routes,
              parameters: parentVRoutePath?.parameters ?? <String>[],
              vRouteElements: vRouteElements,
            ),
          ),
        );
      } else {
        // If the path is not null

        // Get the _VRoutePath from the path

        // Get the global path
        final globalPath = (childRoute.path.startsWith('/'))
            ? childRoute.path
            : parentPath + '/${childRoute.path}';

        // Get the pathRegExp and the new parameters
        var newGlobalParameters = <String>[];
        final globalPathRegExp =
            pathToRegExp(globalPath, parameters: newGlobalParameters);

        // Instantiate the new vRoutePath
        final vRoutePath = _VRoutePath(
          pathRegExp: globalPathRegExp,
          path: globalPath,
          name: childRoute.name,
          parameters: newGlobalParameters,
          vRouteElements: vRouteElements,
        );

        routesFlatten.add(vRoutePath);

        // If there is any alias
        var aliasesVRoutePath = <_VRoutePath>[];
        if (childRoute.aliases != null) {
          // Get the _VRoutePath from every alias

          for (var alias in childRoute.aliases) {
            // Get the global path
            final globalPath =
                (alias.startsWith('/')) ? alias : parentPath + '/$alias';

            // Get the pathRegExp and the new parameters
            var newGlobalParameters = <String>[];
            final globalPathRegExp =
                pathToRegExp(globalPath, parameters: newGlobalParameters);

            // Instantiate the new vRoutePath
            final vRoutePath = _VRoutePath(
              pathRegExp: globalPathRegExp,
              path: globalPath,
              name: childRoute.name,
              parameters: newGlobalParameters,
              vRouteElements: vRouteElements,
            );

            routesFlatten.add(vRoutePath);
            aliasesVRoutePath.add(vRoutePath);
          }
        }

        // If their is any subroute
        if (childRoute.subroutes != null && childRoute.subroutes.isNotEmpty) {
          // Get the routes from the subroutes

          // For the path
          routesFlatten.addAll(
            _getRoutesFlatten(
              childRoutes: childRoute.subroutes,
              parentVRoutePath: vRoutePath,
            ),
          );

          // If there is any alias
          if (childRoute.aliases != null) {
            // For the aliases
            for (var i = 0; i < childRoute.aliases.length; i++) {
              routesFlatten.addAll(
                _getRoutesFlatten(
                  childRoutes: childRoute.subroutes,
                  parentVRoutePath: aliasesVRoutePath[i],
                ),
              );
            }
          }
        }
      }
    }

    return routesFlatten;
  }

  /// Updates every state variables of [VRouter]
  ///
  /// Note that this does not call setState
  void updateStateVariables(
    String newUrl,
    String newPath,
    _VRoutePath vRoutePath, {
    @required List<VPage> pages,
    @required List<VPage> flattenPages,
    Map<String, String> queryParameters = const {},
    String routeHistoryState,
    String historyState,
    Map<String, String> pathParameters,
  }) {
    // Update the vRoute
    vRoute = VRoute(
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      pages: pages,
      routerNavigatorKey: _navigatorKey,
      routerHeroController: _heroController,
      initialHistorySate: routeHistoryState,
    );

    // Update the url and the previousUrl
    _previousUrl = _url;
    _url = newUrl;

    // Update the router historyState
    _historyState = historyState;

    // Update flattenPages
    this.flattenPages = flattenPages;
  }

  /// See [VRouterData.pushNamed]
  void _updateUrlFromName(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newState = const {},
    bool isReplacement = false,
  }) {
    // Find the VRoutePath corresponding to the name
    // Since each alias represent a VRoutePath, there might be several element in the list
    var potentialRoutes = pathToRoutes
        .where(
            (_VRoutePath vRoutePathRegexp) => (vRoutePathRegexp.name == name))
        .toList();

    if (potentialRoutes.isEmpty) {
      throw Exception('Could not find VRouteElement with name $name');
    }

    // Get the path from the list of potentialRoute
    // To discriminate we find the one which pathParameters match the given pathParameters
    var newPath = potentialRoutes.firstWhere(
      (_VRoutePath vRoutePathRegexp) => (listEquals(
          vRoutePathRegexp.parameters, pathParameters.keys.toList())),
      orElse: () {
        final potentialRoutesOrdered = List<_VRoutePath>.from(potentialRoutes)
          ..sort((routeA, routeB) =>
              routeA.parameters.length - routeB.parameters.length);
        throw Exception(
          'Could not find a path with the exact path parameters ${pathParameters.keys}.\n'
          'To navigate to a route named "$name", you must give one of the following list of path parameters:\n${[
            for (var potentialRoute in potentialRoutesOrdered)
              '    - ${potentialRoute.parameters}'
          ].join("\n")} ',
        );
      },
    ).path;

    // Encode the path parameters
    final encodedPathParameters = pathParameters.map<String, String>(
      (key, value) => MapEntry(key, Uri.encodeComponent(value)),
    );

    // Inject the encoded path parameters into the new path
    newPath = pathToFunction(newPath)(encodedPathParameters);

    // Update the url with the found and completed path
    _updateUrl(newPath,
        queryParameters: queryParameters, isReplacement: isReplacement);
  }

  /// Recursive function which builds a nested representation of the given route
  /// The route is given as a list of [VRouteElement]s
  ///
  /// This function is also in charge of populating the given [flattenPages]
  /// which pages should be the same as in the nested structure
  List<VPage> _buildPagesFromVRouteClassList({
    @required List<VPage> incompleteStack,
    @required List<VRouteElement> vRouteElements,
    @required String remainingUrl,
    int index = 0,
    @required List<VPage> flattenPages,
    Map<String, String> historyState = const {},
  }) {
    // If there is no more element in the vRouteElementList, we are done
    if (vRouteElements.isEmpty || index == vRouteElements.length) {
      return incompleteStack;
    }

    // Get the vRouteElement we are currently processing
    final vRouteElement = vRouteElements[index];

    // Get the local parameters
    // We start searching for the parameters once the url of the next VRouteClass don't start with /
    var localParameters = <String, String>{};
    var shouldSearchLocalParameters = true;
    for (var i = index + 1; i < vRouteElements.length; i++) {
      if (vRouteElements[i].path?.startsWith('/') ?? false) {
        shouldSearchLocalParameters = false;
        break;
      }
    }
    if (shouldSearchLocalParameters && vRouteElement.pathRegExp != null) {
      var localPath = vRouteElement.path;

      // First remove any / that would be in first position
      if (remainingUrl.startsWith('/'))
        remainingUrl = remainingUrl.replaceFirst('/', '');
      if (localPath.startsWith('/'))
        localPath = localPath.replaceFirst('/', '');

      // We try to match the pathRegExp with the remainingUrl
      // This is null if a deeper-nester VRouteElement has a path
      // which starts with '/' (which means that this pathRegExp is not part
      // of the url)
      final match = vRouteElement.pathRegExp
          .matchAsPrefix(Uri.decodeComponent(remainingUrl));

      // If the previous match didn't fail, we get the remainingUrl be stripping of the
      // part of the url which matched
      if (match != null) {
        localParameters = extract(vRouteElement.parameters, match);
        remainingUrl = remainingUrl.substring(match.end);
      }
    }

    if (vRouteElement.isChild) {
      // If the next vRoute is a child we:
      //  - first remove the last added page
      //  - add back the page but put a VRouteInformation before it no that it can access the child
      //  - create the vChild inside the VRouteInformation, by creating a Navigator beneath the child
      //        this navigator is the one we want to create the pages for moving forward so we make
      //        the recursive call inside it
      final lastPage = incompleteStack.removeLast();
      final lastVRouteElementWidget = lastPage.child;
      final flattenPagesPreviousLength = flattenPages.length;
      final newVPage = VPage(
        key: vRouteElement.key ?? ValueKey(vRouteElement.path),
        name: vRouteElement.name ?? vRouteElement.path,
        buildTransition:
            vRouteElement.buildTransition ?? widget.buildTransition,
        transitionDuration:
            vRouteElement.transitionDuration ?? widget.transitionDuration,
        reverseTransitionDuration: vRouteElement.reverseTransitionDuration ??
            widget.reverseTransitionDuration,
        child: RouteElementWidget(
          stateKey: vRouteElement.stateKey,
          child: vRouteElement.widget ??
              Builder(
                  builder: (context) => vRouteElement.widgetBuilder(context)),
          depth: index,
          pathParameters: localParameters,
          name: vRouteElement.name,
          initialHistorySate: historyState['$index'],
        ),
      );
      incompleteStack.add(
        VPage(
          key: lastPage.key,
          name: lastPage.name,
          buildTransition: lastPage.buildTransition,
          transitionDuration: lastPage.transitionDuration,
          reverseTransitionDuration: lastPage.reverseTransitionDuration,
          child: RouteElementWidget(
            stateKey: lastVRouteElementWidget.stateKey,
            child: lastVRouteElementWidget.child,
            depth: lastVRouteElementWidget.depth,
            name: lastVRouteElementWidget.name,
            pathParameters: lastVRouteElementWidget.pathParameters,
            initialHistorySate: lastVRouteElementWidget.initialHistorySate,
            vChildName: vRouteElement.name,
            vChild: VRouterHelper(
              observers: [vRouteElements[index - 1].heroController],
              key: vRouteElements[index - 1].navigatorKey,
              pages: _buildPagesFromVRouteClassList(
                incompleteStack: [newVPage],
                vRouteElements: vRouteElements,
                remainingUrl: remainingUrl,
                index: index + 1,
                flattenPages: flattenPages,
                historyState: historyState,
              ),
              onPopPage: (_, __) {
                _pop();
                return false;
              },
              onSystemPopPage: () async {
                await _systemPop();
                return true;
              },
            ),
          ),
        ),
      );

      // Popuflatten pages
      // We use insert to flattenPagesPreviousLength to be sure that the order if which the
      // pages are inserted in flattenPages corresponds to the order in which VRouteElements
      // are nested
      flattenPages.insert(flattenPagesPreviousLength, newVPage);
      return incompleteStack;
    } else {
      // If the next vRoute is not a child, just add it to the stack and make a recursive call
      final newVPage = VPage(
        key: vRouteElement.key ?? ValueKey(vRouteElement.path),
        name: vRouteElement.name ?? vRouteElement.path,
        buildTransition:
            vRouteElement.buildTransition ?? widget.buildTransition,
        transitionDuration:
            vRouteElement.transitionDuration ?? widget.transitionDuration,
        reverseTransitionDuration: vRouteElement.reverseTransitionDuration ??
            widget.reverseTransitionDuration,
        child: RouteElementWidget(
          stateKey: vRouteElement.stateKey,
          child: vRouteElement.widget ??
              Builder(
                  builder: (context) => vRouteElement.widgetBuilder(context)),
          depth: index,
          pathParameters: localParameters,
          name: vRouteElement.name,
          initialHistorySate: historyState['$index'],
        ),
      );
      incompleteStack.add(newVPage);
      flattenPages.add(newVPage);
      final finalStack = _buildPagesFromVRouteClassList(
        incompleteStack: incompleteStack,
        vRouteElements: vRouteElements,
        remainingUrl: remainingUrl,
        index: index + 1,
        flattenPages: flattenPages,
        historyState: historyState,
      );
      return finalStack;
    }
  }

  /// This should be the only way to change a url.
  /// Navigation cycle:
  ///   1. beforeLeave in all deactivated [VNavigationGuard]
  ///   2. beforeLeave in the nest-most [VRouteElement] of the current route
  ///   3. beforeLeave in the [VRouter]
  ///   4. beforeEnter in the [VRouter]
  ///   5. beforeEnter in the nest-most [VRouteElement] of the new route
  ///   The objects got in beforeLeave are stored   ///
  ///   The state of the VRouter changes            ///
  ///   6. afterEnter in the [VRouter]
  ///   7. afterEnter in the nest-most [VRouteElement] of the new route
  ///   8. afterUpdate in all reused [VNavigationGuard]
  ///   9. afterEnter in all initialized [VNavigationGuard]
  Future<void> _updateUrl(
    String newUrl, {
    Map<String, String> newState,
    bool fromBrowser = false,
    int newSerialCount,
    Map<String, String> queryParameters = const {},
    bool isUrlExternal = false,
    bool isReplacement = false,
    bool openNewTab = false,
  }) async {
    assert(!kIsWeb || (!fromBrowser || newSerialCount != null));

    // This should never happen, if it does this is in error in this package
    // We take care of passing the right parameters depending on the platform
    assert(kIsWeb || isReplacement == false,
        'This does not make sense to replace the route if you are not on the web. Please set isReplacement to false.');

    newState ??= <String, String>{};

    final newUri = Uri.parse(newUrl);
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
      newUrl = Uri(path: newPath, queryParameters: queryParameters).toString();
    }

    // Get only the path from the url
    final path = (_url != null) ? Uri.parse(_url).path : null;

    List<VPage> deactivatedPages;
    _VRoutePath newVRoutePathOfPath;
    List<VPage> reusedPages;
    List<VPage> newFlattenPages;
    List<VPage> newRouterPages;
    if (isUrlExternal) {
      deactivatedPages = List.from(flattenPages);
      reusedPages = <VPage>[];
      newVRoutePathOfPath = null;
      newFlattenPages = <VPage>[];
      newRouterPages = <VPage>[];
    } else {
      // Get the new route
      newVRoutePathOfPath = pathToRoutes.firstWhere(
          (_VRoutePath vRoutePathRegexp) =>
              vRoutePathRegexp.pathRegExp?.hasMatch(newPath) ?? false,
          orElse: () => throw InvalidUrlException(url: newUrl));

      // This copy is necessary in order not to modify vRoutePath.vRoutePathLocals
      final localInformationOfPath =
          List<VRouteElement>.from(newVRoutePathOfPath.vRouteElements);

      // Get the newRouterPages
      newFlattenPages = <VPage>[];
      newRouterPages = _buildPagesFromVRouteClassList(
        incompleteStack: [],
        vRouteElements: localInformationOfPath,
        remainingUrl: newPath,
        flattenPages: newFlattenPages,
        historyState: newState,
      );

      // Get deactivated and reused pages of the new route
      deactivatedPages = <VPage>[];
      reusedPages = <VPage>[];
      if (flattenPages.isNotEmpty) {
        for (var vPage in flattenPages.reversed) {
          try {
            newFlattenPages.firstWhere((newPage) => (newPage.key == vPage.key));
            reusedPages.add(vPage);
          } on StateError {
            deactivatedPages.add(vPage);
          }
        }
      }
    }

    // Extract the path parameters from the url
    final match = newVRoutePathOfPath?.pathRegExp?.matchAsPrefix(newPath);
    var newPathParameters = (match != null)
        ? extract(newVRoutePathOfPath.parameters, match)
        : <String, String>{};
    // Decode path parameters
    newPathParameters = newPathParameters
        .map((key, value) => MapEntry(key, Uri.decodeComponent(value)));

    var shouldSaveHistoryState = false;
    var historyStatesToSave = {
      'serialCount': '$serialCount',
      '-2': _historyState,
      '-1': vRoute?.key?.currentState?.historyState,
      for (var pages in flattenPages)
        '${pages.child.depth}':
            pages.child.stateKey?.currentState?.historyState ??
                pages.child.initialHistorySate,
    };
    String objectToSave;
    void saveHistoryState(String historyState) {
      if (objectToSave != null) {
        throw Exception(
            'You should only call saveHistoryState once.\nThis might be because you have multiple VNavigationGuard corresponding to the same VRouteElement, in that case only one of them should use saveHistoryState since the scope is the VRouteElement one.');
      }
      objectToSave = historyState;
    }

    // Instantiate VRedirector
    final vRedirector = VRedirector(
      context: _vRouterInformationContext,
      from: _url,
      to: newUrl,
      previousVRouteData: VRouteData(
        child: Container(),
        historyState: vRoute?.key?.currentState?.historyState,
        replaceHistoryState: (String _) =>
            throw 'replaceHistoryState cannot be called using this object.\n'
                'If you want to save the state of the current route: Use saveHistoryState in beforeLeave.\n'
                'If you want to change the history state of the new route: call VRouterData.replaceHistoryState in afterEnter or afterUpdate.',
        pathParameters: vRoute?.pathParameters ?? {},
        queryParameters: vRoute?.queryParameters ?? {},
      ),
      newVRouteData: VRouteData(
        child: Container(),
        historyState: newState['-2'],
        replaceHistoryState: (String _) =>
            throw 'replaceHistoryState cannot be called using this object.\n'
                'If you want to save the state of the current route: Use saveHistoryState in beforeLeave.\n'
                'If you want to change the history state of the new route: call VRouterData.replaceHistoryState in afterEnter or afterUpdate.',
        pathParameters: newPathParameters,
        queryParameters: queryParameters,
      ),
    );

    if (_url != null) {
      ///   1. beforeLeave in all deactivated VNavigationGuard
      for (var deactivatedPage in deactivatedPages) {
        final vNavigationGuardMessages = deactivatedPage
                .child.stateKey?.currentState?.vNavigationGuardMessages ??
            [];
        for (var vNavigationGuardMessage in vNavigationGuardMessages) {
          if (vNavigationGuardMessage.vNavigationGuard.beforeLeave != null) {
            await vNavigationGuardMessage.vNavigationGuard
                .beforeLeave(vRedirector, saveHistoryState);
            if (!vRedirector._shouldUpdate) {
              break;
            }
          }
        }
        if (!vRedirector._shouldUpdate) {
          break;
        } else if (objectToSave != null &&
            historyStatesToSave['${deactivatedPage.child.depth}'] !=
                objectToSave) {
          historyStatesToSave['${deactivatedPage.child.depth}'] = objectToSave;
          objectToSave = null;
          shouldSaveHistoryState = true;
        }
      }
      if (!vRedirector._shouldUpdate) {
        // If the url change comes from the browser, chances are the url is already changed
        // So we have to navigate back to the old url (stored in _url)
        // Note: in future version it would be better to delete the last url of the browser
        //        but it is not yet possible
        if (kIsWeb &&
            fromBrowser &&
            (BrowserHelpers.getHistorySerialCount() ?? 0) != serialCount) {
          ignoreNextBrowserCalls = true;
          BrowserHelpers.browserGo(serialCount - newSerialCount);
          await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
              BrowserHelpers.getHistorySerialCount() == serialCount);
          ignoreNextBrowserCalls = false;
        }
        if (vRedirector._redirectFunction != null)
          vRedirector._redirectFunction();
        return;
      }

      ///   2. beforeLeave in the nest-most [VRouteElement] of the current route
      ///   saving the [VRoute] history state if needed
      // Get the current route
      final vRoutePathOfPath = pathToRoutes.firstWhere(
          (_VRoutePath vRoutePathRegexp) =>
              vRoutePathRegexp.pathRegExp?.hasMatch(path) ?? false,
          orElse: () => throw InvalidUrlException(url: path));

      // Call the nest-most VRouteClass of the current route
      final vRouteElement = vRoutePathOfPath.vRouteElements.last;
      if (vRouteElement.beforeLeave != null) {
        await vRouteElement.beforeLeave(vRedirector, saveHistoryState);
        if (objectToSave != null && historyStatesToSave['-1'] != objectToSave) {
          historyStatesToSave['-1'] = objectToSave;
          objectToSave = null;
          shouldSaveHistoryState = true;
        }
        if (!vRedirector._shouldUpdate) {
          // If the url change comes from the browser, chances are the url is already changed
          // So we have to navigate back to the old url (stored in _url)
          // Note: in future version it would be better to delete the last url of the browser
          //        but it is not yet possible
          if (kIsWeb &&
              fromBrowser &&
              (BrowserHelpers.getHistorySerialCount() ?? 0) != serialCount) {
            ignoreNextBrowserCalls = true;
            BrowserHelpers.browserGo(serialCount - newSerialCount);
            await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
                BrowserHelpers.getHistorySerialCount() == serialCount);
            ignoreNextBrowserCalls = false;
          }
          if (vRedirector._redirectFunction != null)
            vRedirector._redirectFunction();
          return;
        }
      }

      ///   3. beforeLeave in the VRouter
      if (widget.beforeLeave != null) {
        await widget.beforeLeave(vRedirector, saveHistoryState);
        if (objectToSave != null && historyStatesToSave['-2'] != objectToSave) {
          historyStatesToSave['-2'] = objectToSave;
          objectToSave = null;
          shouldSaveHistoryState = true;
        }
        if (!vRedirector._shouldUpdate) {
          // If the url change comes from the browser, chances are the url is already changed
          // So we have to navigate back to the old url (stored in _url)
          // Note: in future version it would be better to delete the last url of the browser
          //        but it is not yet possible
          if (kIsWeb &&
              fromBrowser &&
              (BrowserHelpers.getHistorySerialCount() ?? 0) != serialCount) {
            ignoreNextBrowserCalls = true;
            BrowserHelpers.browserGo(serialCount - newSerialCount);
            await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
                BrowserHelpers.getHistorySerialCount() == serialCount);
            ignoreNextBrowserCalls = false;
          }
          if (vRedirector._redirectFunction != null)
            vRedirector._redirectFunction();
          return;
        }
      }
    }

    if (!isUrlExternal) {
      ///   4. beforeEnter in the VRouter
      if (widget.beforeEnter != null) {
        await widget.beforeEnter(vRedirector);
        if (!vRedirector._shouldUpdate) {
          // If the url change comes from the browser, chances are the url is already changed
          // So we have to navigate back to the old url (stored in _url)
          // Note: in future version it would be better to delete the last url of the browser
          //        but it is not yet possible
          if (kIsWeb &&
              fromBrowser &&
              (BrowserHelpers.getHistorySerialCount() ?? 0) != serialCount) {
            ignoreNextBrowserCalls = true;
            BrowserHelpers.browserGo(serialCount - newSerialCount);
            await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
                BrowserHelpers.getHistorySerialCount() == serialCount);
            ignoreNextBrowserCalls = false;
          }
          if (vRedirector._redirectFunction != null)
            vRedirector._redirectFunction();
          return;
        }
      }

      ///   5. beforeEnter in the nest-most [VRouteElement] of the new route

      // Call the nest-most VRouteClass of the new route
      // Check the local beforeEnter
      if (newVRoutePathOfPath.vRouteElements.last.beforeEnter != null) {
        await newVRoutePathOfPath.vRouteElements.last.beforeEnter(vRedirector);

        if (!vRedirector._shouldUpdate) {
          // If the url change comes from the browser, chances are the url is already changed
          // So we have to navigate back to the old url (stored in _url)
          // Note: in future version it would be better to delete the last url of the browser
          //        but it is not yet possible
          if (kIsWeb &&
              fromBrowser &&
              (BrowserHelpers.getHistorySerialCount() ?? 0) != serialCount) {
            ignoreNextBrowserCalls = true;
            BrowserHelpers.browserGo(serialCount - newSerialCount);
            await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
                BrowserHelpers.getHistorySerialCount() == serialCount);
            ignoreNextBrowserCalls = false;
          }
          if (vRedirector._redirectFunction != null)
            vRedirector._redirectFunction();
          return;
        }
      }
    }

    final oldSerialCount = serialCount;
    if (shouldSaveHistoryState &&
        path != null &&
        historyStatesToSave.isNotEmpty) {
      assert(
        kIsWeb,
        'Tried to store the state $historyStatesToSave while not on the web. State saving/restoration only work on the web.\n'
        'You can safely ignore this message if you just want this functionality on the web.',
      );

      ///   The historyStates got in beforeLeave are stored   ///
      // If we come from the browser, chances are we already left the page
      // So we need to:
      //    1. Go back to where we were
      //    2. Save the historyState
      //    3. And go back again to the place
      if (kIsWeb && fromBrowser && oldSerialCount != newSerialCount) {
        ignoreNextBrowserCalls = true;
        BrowserHelpers.browserGo(oldSerialCount - newSerialCount);
        await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
            BrowserHelpers.getHistorySerialCount() == oldSerialCount);
      }
      BrowserHelpers.replaceHistoryState(jsonEncode(historyStatesToSave));
      if (kIsWeb && fromBrowser && oldSerialCount != newSerialCount) {
        BrowserHelpers.browserGo(newSerialCount - oldSerialCount);
        await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
            BrowserHelpers.getHistorySerialCount() == newSerialCount);
        ignoreNextBrowserCalls = false;
      }
    }

    /// Leave if the url is external
    if (isUrlExternal) {
      ignoreNextBrowserCalls = true;
      await BrowserHelpers.pushExternal(newUrl, openNewTab: openNewTab);
      return;
    }

    ///   The state of the VRouter changes            ///
    // Add the new serial count to the state
    newState.addAll({'serialCount': '$serialCount'});
    final oldUrl = _url;
    final newRouterState = newState['-2'];
    if (_url != newUrl || newRouterState != _historyState) {
      updateStateVariables(
        newUrl,
        newPath,
        newVRoutePathOfPath,
        historyState: newRouterState,
        pages: newRouterPages,
        flattenPages: newFlattenPages,
        queryParameters: queryParameters,
        routeHistoryState: newState['-1'],
        pathParameters: newPathParameters,
      );
      if (isReplacement) {
        ignoreNextBrowserCalls = true;
        if (BrowserHelpers.getPathAndQuery(routerMode: widget.mode) != newUrl) {
          BrowserHelpers.pushReplacement(newUrl, routerMode: widget.mode);
          if (BrowserHelpers.getPathAndQuery(routerMode: widget.mode) !=
              newUrl) {
            await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
                BrowserHelpers.getPathAndQuery(routerMode: widget.mode) ==
                newUrl);
          }
        }
        BrowserHelpers.replaceHistoryState(jsonEncode(newState));
        ignoreNextBrowserCalls = false;
      } else {
        serialCount = newSerialCount ?? serialCount + 1;
      }
      setState(() {});
    }

    // We need to do this after rebuild as completed so that the user can have access
    // to the new state variables
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      ///   6. afterEnter in the VRouter
      if (widget.afterEnter != null) {
        widget.afterEnter(_vRouterInformationContext, oldUrl, newUrl);
      }

      ///   7. afterEnter in the nest-most VRouteClass of the new route
      if (newVRoutePathOfPath.vRouteElements.last.afterEnter != null) {
        newVRoutePathOfPath.vRouteElements.last
            .afterEnter(_vRouterInformationContext, oldUrl, newUrl);
      }

      ///   8. afterUpdate in all reused vRouteElement
      for (var vPage in reusedPages) {
        final vNavigationMessages =
            vPage.child.stateKey?.currentState?.vNavigationGuardMessages ?? [];
        for (var vNavigationMessage in vNavigationMessages) {
          if (vNavigationMessage.vNavigationGuard.afterUpdate != null) {
            vNavigationMessage.vNavigationGuard.afterUpdate(
              vNavigationMessage.localContext,
              oldUrl,
              newUrl,
            );
          }
        }
      }

      ///   9. afterEnter in all initialized vRouteElement
      // This is done automatically by VNotificationGuard
    });
  }

  /// See [VRouterData.pop]
  Future<void> _pop({
    VRedirector vRedirector,
    Map<String, String> queryParameters = const {},
    String newState,
  }) async {
    assert(_url != null);

    // Instantiate VRedirector if null
    // It might be not null if called from systemPop
    vRedirector ??= _defaultPop(queryParameters: queryParameters);

    /// Call onPop in all active VNavigationGuards
    for (var page in flattenPages.reversed) {
      final vNavigationMessages =
          page.child.stateKey?.currentState?.vNavigationGuardMessages ?? [];
      for (var vNavigationMessage in vNavigationMessages.reversed) {
        if (vNavigationMessage.vNavigationGuard.onPop != null) {
          await vNavigationMessage.vNavigationGuard.onPop(vRedirector);
          if (!vRedirector.shouldUpdate) {
            return;
          }
        }
      }
    }

    /// Call onPop of the nested-most VRouteElement
    // Get the current path
    final path = Uri.parse(_url).path;

    // Get the current route
    final vRoutePathLocals = pathToRoutes
        .firstWhere(
            (_VRoutePath vRoutePathRegexp) =>
                vRoutePathRegexp.pathRegExp?.hasMatch(path) ?? false,
            orElse: () => throw InvalidUrlException(url: path))
        .vRouteElements;

    // Find the VRouteClass which is the deepest possible
    // having onPopPage implemented
    final vRouteElement = vRoutePathLocals.last;
    if (vRouteElement.onPop != null) {
      await vRouteElement.onPop(vRedirector);
      if (!vRedirector.shouldUpdate) {
        return;
      }
    }

    /// Call onPop of VRouter
    if (widget.onPop != null) {
      await widget.onPop(vRedirector);
      if (!vRedirector.shouldUpdate) {
        return;
      }
    }

    /// Update the url to the one found in [_defaultPop]
    if (vRedirector != null) {
      _updateUrl(vRedirector.to,
          queryParameters: queryParameters, newState: {'-2': newState});
    } else if (!kIsWeb) {
      // If we didn't find a url to go to, we are at the start of the stack
      // so we close the app on mobile
      MoveToBackground.moveTaskToBack();
    }
  }

  /// See [VRouterData.systemPop]
  Future<void> _systemPop({
    Map<String, String> queryParameters = const {},
    String newState,
  }) async {
    assert(_url != null);

    // Instantiate VRedirector if null
    // It might be not null if called from systemPop
    final vRedirector = _defaultPop(queryParameters: queryParameters);

    /// Call onSystemPop in all active VNavigationGuards
    for (var page in flattenPages.reversed) {
      final vNavigationMessages =
          page.child.stateKey?.currentState?.vNavigationGuardMessages ?? [];
      for (var vNavigationMessage in vNavigationMessages.reversed) {
        if (vNavigationMessage.vNavigationGuard.onSystemPop != null) {
          await vNavigationMessage.vNavigationGuard.onSystemPop(vRedirector);
          if (!vRedirector.shouldUpdate) {
            return;
          }
        }
      }
    }

    /// Call onSystemPop of the nested-most VRouteElement
    // Get the current path
    final path = Uri.parse(_url).path;

    // Get the current route
    final vRoutePathLocals = pathToRoutes
        .firstWhere(
            (_VRoutePath vRoutePathRegexp) =>
                vRoutePathRegexp.pathRegExp?.hasMatch(path) ?? false,
            orElse: () => throw InvalidUrlException(url: path))
        .vRouteElements;

    // Find the VRouteClass which is the deepest possible
    // having onSystemPopPage implemented
    final vRouteElement = vRoutePathLocals.last;
    if (vRouteElement.onSystemPop != null) {
      // If we did find a VRouteClass, call onSystemPopPage
      await vRouteElement.onSystemPop(vRedirector);
      if (!vRedirector.shouldUpdate) {
        return;
      }
    }

    /// Call VRouter onSystemPop
    if (widget.onSystemPop != null) {
      // Call VRouter.onSystemPopPage if implemented
      await widget.onSystemPop(vRedirector);
      if (!vRedirector.shouldUpdate) {
        return;
      }
    }

    /// Call onPop, which start a onPop cycle
    await _pop();
  }

  /// This finds new url when a pop event occurs by popping all [VRouteElement] of the current
  /// route until a [VStacked] is popped.
  /// It returns a [VRedirector] with the newVRouteData corresponding to the found path.
  /// If no such [VRouteElement] is found, newVRouteData is null
  ///
  /// We also try to preserve path parameters if possible
  /// For example
  ///   Given the path /user/:id/settings (where the 'settings' path belongs to a VStacked)
  ///   If we are on /user/bob/settings
  ///   Then a defaultPop will lead to /user/bob
  ///
  /// See:
  ///   * [VNavigationGuard.onPop] to override this behaviour locally
  ///   * [VRouteElement.onPop] to override this behaviour on a on a route level
  ///   * [VRouter.onPop] to override this behaviour on a global level
  ///   * [VNavigationGuard.onSystemPop] to override this behaviour locally
  ///                               when the call comes from the system
  ///   * [VRouteElement.onSystemPop] to override this behaviour on a route level
  ///                               when the call comes from the system
  ///   * [VRouter.onSystemPop] to override this behaviour on a global level
  ///                               when the call comes from the system
  VRedirector _defaultPop({
    Map<String, String> queryParameters = const {},
    String newState,
  }) {
    assert(_url != null);
    final path = Uri.parse(_url).path;

    // Get the current route (we copy it to avoid modifying it)
    final vRouteElements = List<VRouteElement>.from(
      pathToRoutes
          .firstWhere(
              (_VRoutePath vRoutePathRegexp) =>
                  vRoutePathRegexp.pathRegExp?.hasMatch(path) ?? false,
              orElse: () => throw InvalidUrlException(url: path))
          .vRouteElements,
    );

    // Find the vRouteElements where vRoute.isChild of the last element is false
    while (vRouteElements.isNotEmpty && vRouteElements.last.isChild) {
      vRouteElements.removeLast();
    }

    // Remove the VStacked
    vRouteElements.removeLast();

    // This VRouteData will be not null if we find a route to go to
    VRouteData newVRouteData;

    // This url will be not null if we find a route to go to
    String newUrl;

    if (vRouteElements.isNotEmpty) {
      // Get the VRoutePath from the vRouteElements
      final newVRoutePath = pathToRoutes.firstWhere(
        (vRoutePath) => listEquals(vRoutePath.vRouteElements, vRouteElements),
      );

      // Get the new pathRegexp as a prefix regExp
      final newPathRegExpPrefix =
          pathToRegExp(newVRoutePath.path, prefix: true);

      // Extract the newRawPath from the path using the newRawPath
      final match = newPathRegExpPrefix.matchAsPrefix(path);
      String newPath;
      if (match != null) {
        newPath = path.substring(match.start, match.end);
      } else {
        // In the case where we can't deduce the path from the start
        // of the current one, we reconstruct it with the VRouter.routes path
        // This means that any parameter won't be able to be restored,
        // this is expected since we have no way to deduce those parameters
        // from the current path
        newPath = newVRoutePath.path;
      }

      // Integrate the given query parameters
      newUrl = Uri(
        path: newPath,
        queryParameters: (queryParameters.isNotEmpty) ? queryParameters : null,
      ).toString();

      // Extract the path parameters from the url
      final newMatch = newVRoutePath.pathRegExp.matchAsPrefix(newPath);
      var newPathParameters = (newMatch != null)
          ? extract(newVRoutePath.parameters, newMatch)
          : <String, String>{};
      // Decode path parameters
      newPathParameters = newPathParameters
          .map((key, value) => MapEntry(key, Uri.decodeComponent(value)));

      newVRouteData = VRouteData(
        child: Container(),
        historyState: newState,
        replaceHistoryState: (String _) =>
            throw 'replaceHistoryState cannot be called using this object.\n'
                'If you want to save the state of the current route: Use saveHistoryState in beforeLeave.\n'
                'If you want to change the history state of the new route: call VRouterData.replaceHistoryState in afterEnter or afterUpdate.',
        pathParameters: newPathParameters,
        queryParameters: queryParameters,
      );
    }

    return VRedirector(
      context: _vRouterInformationContext,
      from: _url,
      to: newUrl,
      previousVRouteData: VRouteData(
        child: Container(),
        historyState: vRoute?.key?.currentState?.historyState,
        replaceHistoryState: (String _) =>
            throw 'replaceHistoryState cannot be called using this object.\n'
                'If you want to save the state of the current route: Use saveHistoryState in beforeLeave.\n'
                'If you want to change the history state of the new route: call VRouterData.replaceHistoryState in afterEnter or afterUpdate.',
        pathParameters: vRoute?.pathParameters ?? {},
        queryParameters: vRoute?.queryParameters ?? {},
      ),
      newVRouteData: newVRouteData,
    );
  }

  /// See [VRouterData.replaceHistoryState]
  void _replaceHistoryState(String newRouterState) {
    if (kIsWeb) {
      final historyState = BrowserHelpers.getHistoryState() ?? '{}';
      final historyStateMap =
          Map<String, String>.from(jsonDecode(historyState));
      historyStateMap['-2'] = newRouterState;
      final newHistoryState = jsonEncode(historyStateMap);
      BrowserHelpers.replaceHistoryState(newHistoryState);
    }
    setState(() {
      _historyState = newRouterState;
    });
  }

  /// WEB ONLY
  /// Save the state if needed before the app gets unloaded
  /// Mind that this happens when the user enter a url manually in the
  /// browser so we can't prevent him from leaving the page
  void onBeforeUnload() async {
    if (_url == null) return;
    final newSerialCount = serialCount + 1;
    final path = Uri.parse(_url).path;

    var shouldSaveHistoryState = true;

    var historyStatesToSave = <String, String>{};
    String objectToSave;
    void saveHistoryState(String historyState) {
      if (objectToSave != null) {
        throw Exception('You should only call saveHistoryState once');
      }
      objectToSave = historyState;
    }

    ///   1. beforeLeave in all deactivated vRouteElement
    for (var deactivatedPage in flattenPages) {
      final vNavigationMessages = deactivatedPage
              .child.stateKey?.currentState?.vNavigationGuardMessages ??
          [];
      for (var vNavigationMessage in vNavigationMessages) {
        if (vNavigationMessage.vNavigationGuard.beforeLeave != null) {
          await vNavigationMessage.vNavigationGuard
              .beforeLeave(null, saveHistoryState);
          if (objectToSave != null) {
            historyStatesToSave['${deactivatedPage.child.depth}'] =
                objectToSave;
            objectToSave = null;
            shouldSaveHistoryState = true;
          }
        }
      }
    }

    ///   2. beforeLeave in the nest-most [VRouteElement] of the current route
    // Get the actual route
    final vRoutePathOfPath = pathToRoutes.firstWhere(
        (_VRoutePath vRoutePathRegexp) =>
            vRoutePathRegexp.pathRegExp?.hasMatch(path) ?? false,
        orElse: () => throw InvalidUrlException(url: path));

    // Call the nest-most VRouteClass of the current route
    final vRouteElement = vRoutePathOfPath.vRouteElements.last;
    if (vRouteElement.beforeLeave != null) {
      vRouteElement.beforeLeave(null, saveHistoryState);

      if (objectToSave != null && historyStatesToSave['-1'] != objectToSave) {
        historyStatesToSave['-1'] = objectToSave;
        objectToSave = null;
        shouldSaveHistoryState = true;
      }
    }

    ///   3. beforeLeave in the VRouter
    if (widget.beforeLeave != null) {
      await widget.beforeLeave(null, saveHistoryState);
      if (objectToSave != null) {
        historyStatesToSave['-2'] = objectToSave;
        objectToSave = null;
        shouldSaveHistoryState = true;
      }
    }

    if (historyStatesToSave.isNotEmpty && shouldSaveHistoryState) {
      ///   The historyStates got in beforeLeave are stored   ///
      serialCount = newSerialCount;
      BrowserHelpers.replaceHistoryState(jsonEncode(historyStatesToSave));
    }
  }
}

class VRouterData extends InheritedWidget {
  final void Function(
    String newUrl, {
    Map<String, String> queryParameters,
    Map<String, String> newState,
    bool isUrlExternal,
    bool isReplacement,
    bool openNewTab,
  }) _updateUrl;
  final void Function(
    String name, {
    Map<String, String> pathParameters,
    Map<String, String> queryParameters,
    Map<String, String> newState,
    bool isReplacement,
  }) _updateUrlFromName;
  final Future<void> Function({
    Map<String, String> queryParameters,
    String newState,
  }) _pop;
  final Future<void> Function({
    Map<String, String> queryParameters,
    String newState,
  }) _systemPop;
  final void Function(String historyState) _replaceHistoryState;

  VRouterData({
    Key key,
    @required
        Widget child,
    this.url,
    this.previousUrl,
    this.historyState,
    @required
        void Function(
      String newUrl, {
      Map<String, String> queryParameters,
      Map<String, String> newState,
      bool isUrlExternal,
      bool isReplacement,
      bool openNewTab,
    })
            updateUrl,
    @required
        void Function(
      String name, {
      Map<String, String> pathParameters,
      Map<String, String> queryParameters,
      Map<String, String> newState,
      bool isReplacement,
    })
            updateUrlFromName,
    @required
        Future<void> Function({
      Map<String, String> queryParameters,
      String newState,
    })
            pop,
    @required
        Future<void> Function({
      Map<String, String> queryParameters,
      String newState,
    })
            systemPop,
    @required
        void Function(String historyState) replaceHistoryState,
  })  : _updateUrl = updateUrl,
        _updateUrlFromName = updateUrlFromName,
        _pop = pop,
        _systemPop = systemPop,
        _replaceHistoryState = replaceHistoryState,
        super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(VRouterData old) {
    return (old.url != url ||
        old.previousUrl != previousUrl ||
        old.historyState != historyState);
  }

  /// Url currently synced with the state
  /// This url can differ from the once of the browser if
  /// the state has been yet been updated
  final String url;

  /// Previous url that was synced with the state
  final String previousUrl;

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
  final String historyState;

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
  /// push) accessible with VRouterData.of(context).historyState
  void push(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    if (!newUrl.startsWith('/')) {
      if (url == null) {
        throw Exception(
            "The current url is null but you are trying to access a path which does not start with'/'.");
      }
      final currentPath = Uri.parse(url).path;
      newUrl = currentPath + '/$newUrl';
    }

    _updateUrl(newUrl,
        queryParameters: queryParameters, newState: {'-2': routerState});
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
  /// push) accessible with VRouterData.of(context).historyState
  ///
  /// After finding the url and taking charge of the path parameters
  /// it updates the url
  ///
  /// To specify a name, see [VRouteElement.name]
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    _updateUrlFromName(name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newState: {'-2': routerState});
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
  /// push) accessible with VRouterData.of(context).historyState
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    // If not on the web, this is the same as push
    if (!kIsWeb) {
      return push(newUrl,
          queryParameters: queryParameters, routerState: routerState);
    }

    if (!newUrl.startsWith('/')) {
      if (url == null) {
        throw Exception(
            "The current url is null but you are trying to access a path which does not start with'/'.");
      }
      final currentPath = Uri.parse(url).path;
      newUrl = currentPath + '/$newUrl';
    }

    // Update the url, setting isReplacement to true
    _updateUrl(
      newUrl,
      queryParameters: queryParameters,
      newState: {'-2': routerState},
      isReplacement: true,
    );
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
  /// push) accessible with VRouterData.of(context).historyState
  ///
  /// After finding the url and taking charge of the path parameters
  /// it updates the url
  ///
  /// To specify a name, see [VRouteElement.name]
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String routerState,
  }) {
    _updateUrlFromName(name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newState: {'-2': routerState},
        isReplacement: true);
  }

  /// Goes to an url which is not in the app
  ///
  /// On the web, you can set [openNewTab] to true to open this url
  /// in a new tab
  void pushExternal(String newUrl, {bool openNewTab = false}) =>
      _updateUrl(newUrl, isUrlExternal: true, openNewTab: openNewTab);

  /// Starts a pop cycle
  ///
  /// Pop cycle:
  ///   1. onPop is called in all [VNavigationGuard]s
  ///   2. onPop is called in the nested-most [VRouteElement] of the current route
  ///   3. onPop is called in [VRouter]
  ///   4. Default behaviour of pop is called: [VRouterState._defaultPop]
  ///
  /// In any of the above steps, we can use [vRedirector] if you want to redirect or
  /// stop the navigation
  void pop({
    Map<String, String> queryParameters = const {},
    String routerState,
  }) =>
      _pop(queryParameters: queryParameters, newState: routerState);

  /// Starts a systemPop cycle
  ///
  /// systemPop cycle:
  ///   1. onSystemPop is called in all VNavigationGuards
  ///   2. onSystemPop is called in the nested-most VRouteElement of the current route
  ///   3. onSystemPop is called in VRouter
  ///   4. [pop] is called
  ///
  /// In any of the above steps, we can use [vRedirector] if you want to redirect or
  /// stop the navigation
  Future<void> systemPop({
    Map<String, String> queryParameters = const {},
    String routerState,
  }) =>
      _systemPop(queryParameters: queryParameters, newState: routerState);

  /// This replaces the current history state of [VRouterData] with given one
  void replaceHistoryState(String historyState) =>
      _replaceHistoryState(historyState);

  static VRouterData of(BuildContext context) {
    final vRouterData =
        context.dependOnInheritedWidgetOfExactType<VRouterData>();
    if (vRouterData == null) {
      throw FlutterError(
          'VRouterData.of(context) was called with a context which does not contain a VRouter.\n'
          'The context used to retrieve VRouterData must be that of a widget that '
          'is a descendant of a VRouter widget.');
    }
    return vRouterData;
  }
}
