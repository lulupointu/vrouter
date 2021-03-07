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

  /// Called when a url changes, before the url is updated
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
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
    VRedirector? vRedirector,
    void Function(String historyState) saveHistoryState,
  )? beforeLeave;

  /// This is called before the url is updated but after all beforeLeave are called
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouteElement.beforeEnter] for route level beforeEnter
  ///   * [VRedirector] to known how to redirect and have access to route information
  final Future<void> Function(VRedirector vRedirector)? beforeEnter;

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
  final void Function(BuildContext context, String? from, String to)? afterEnter;

  /// Called after the [VRouteElement.onPopPage] when a pop event occurs
  /// A pop event can be called programmatically (with [VRouterData.of(context).pop()])
  /// or by other widgets such as the appBar back button
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
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
  final Future<void> Function(VRedirector vRedirector)? onPop;

  /// Called after the [VRouteElement.onPopPage] when a system pop event occurs.
  /// This happens on android when the system back button is pressed.
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
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
  final Future<void> Function(VRedirector vRedirector)? onSystemPop;

  /// This allows you to change the initial url
  ///
  /// The default is '/'
  final InitialUrl initialUrl;

  VRouter({
    Key? key,
    required this.routes,
    this.beforeEnter,
    this.beforeLeave,
    this.onPop,
    this.onSystemPop,
    this.afterEnter,
    this.buildTransition,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.mode = VRouterModes.hash,
    this.initialUrl = const InitialUrl(url: '/'),
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
  final BackButtonDispatcher? backButtonDispatcher;

  /// {@macro flutter.widgets.widgetsApp.builder}
  ///
  /// Material specific features such as [showDialog] and [showMenu], and widgets
  /// such as [Tooltip], [PopupMenuButton], also require a [Navigator] to properly
  /// function.
  final TransitionBuilder? builder;

  /// {@macro flutter.widgets.widgetsApp.title}
  ///
  /// This value is passed unmodified to [WidgetsApp.title].
  final String? title;

  /// {@macro flutter.widgets.widgetsApp.onGenerateTitle}
  ///
  /// This value is passed unmodified to [WidgetsApp.onGenerateTitle].
  final GenerateAppTitle? onGenerateTitle;

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
  final ThemeData? theme;

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
  final ThemeData? darkTheme;

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
  final ThemeData? highContrastTheme;

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
  final ThemeData? highContrastDarkTheme;

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
  final ThemeMode? themeMode;

  /// {@macro flutter.widgets.widgetsApp.color}
  final Color? color;

  /// {@macro flutter.widgets.widgetsApp.locale}
  final Locale? locale;

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
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  /// {@macro flutter.widgets.widgetsApp.localeListResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleListResolutionCallback? localeListResolutionCallback;

  /// {@macro flutter.widgets.LocaleResolutionCallback}
  ///
  /// This callback is passed along to the [WidgetsApp] built by this widget.
  final LocaleResolutionCallback? localeResolutionCallback;

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
  final Iterable<Locale>? supportedLocales;

  /// Turns on a performance overlay.
  ///
  /// See also:
  ///
  ///  * <https://flutter.dev/debugging/#performanceoverlay>
  final bool? showPerformanceOverlay;

  /// Turns on checkerboarding of raster cache images.
  final bool? checkerboardRasterCacheImages;

  /// Turns on checkerboarding of layers rendered to offscreen bitmaps.
  final bool? checkerboardOffscreenLayers;

  /// Turns on an overlay that shows the accessibility information
  /// reported by the framework.
  final bool? showSemanticsDebugger;

  /// {@macro flutter.widgets.widgetsApp.debugShowCheckedModeBanner}
  final bool? debugShowCheckedModeBanner;

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
  final Map<LogicalKeySet, Intent>? shortcuts;

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
  final Map<Type, Action<Intent>>? actions;

  /// Turns on a [GridPaper] overlay that paints a baseline grid
  /// Material apps.
  ///
  /// Only available in checked mode.
  ///
  /// See also:
  ///
  ///  * <https://material.io/design/layout/spacing-methods.html>
  final bool? debugShowMaterialGrid;

  static VRouterMethodsHolder of(BuildContext context) {
    final vRouterMethodsHolder =
        context.dependOnInheritedWidgetOfExactType<VRouterMethodsHolder>();
    if (vRouterMethodsHolder == null) {
      throw FlutterError(
          'VRouter.of(context) was called with a context which does not contain a VRouter.\n'
          'The context used to retrieve VRouter must be that of a widget that '
          'is a descendant of a VRouter widget.');
    }
    return vRouterMethodsHolder;
  }
}

class VRouterState extends State<VRouter> {
  /// Those are all the pages of the current route
  /// It is computed every time the url is updated
  /// This is mainly used to see which pages are deactivated
  /// vs which ones are reused when the url changes
  List<VPage> _flattenPages = [];

  /// This is a list which maps every possible path to the corresponding route
  /// by looking at every [VRouteElement] in [VRouter.routes]
  /// This is only computed once
  late List<_VRoutePath> _pathToRoutes;

  /// This is a context which contains the VRouter.
  /// It is used is VRouter.beforeLeave for example.
  late BuildContext _vRouterInformationContext;

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

  /// Those are used in the root navigator
  /// They are here to prevent breaking animations
  final GlobalKey<NavigatorState> _navigatorKey;
  final HeroController _heroController;

  /// The [VRouterNode] corresponding to the topmost VRouterNode
  VRouterNode? vRouterNode;

  VRouterState()
      : _navigatorKey = GlobalKey<NavigatorState>(),
        _heroController = HeroController();

  /// See [VRouterData.url]
  String? url;

  /// See [VRouterData.previousUrl]
  String? previousUrl;

  /// See [VRouterData.historyState]
  String? historyState;

  /// See [VRouterData.pathParameters]
  Map<String, String> pathParameters = <String, String>{};

  /// See [VRouterData.queryParameters]
  Map<String, String> queryParameters = <String, String>{};

  @override
  void initState() {
    // When the app starts, get the serialCount. Default to 0.
    _serialCount = (kIsWeb) ? (BrowserHelpers.getHistorySerialCount() ?? 0) : 0;

    // Setup the url strategy
    if (widget.mode == VRouterModes.history) {
      setPathUrlStrategy();
    } else {
      setHashUrlStrategy();
    }

    // Compute every possible path
    _pathToRoutes = _getRoutesFlatten(childRoutes: widget.routes);

    // If we are on the web, we listen to any unload event.
    // This allows us to call beforeLeave when the browser or the tab
    // is being closed for example
    if (kIsWeb) {
      BrowserHelpers.onBrowserBeforeUnload.listen((e) => _onBeforeUnload());
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SimpleUrlHandler(
      urlToAppState: (BuildContext context, RouteInformation routeInformation) async {
        if (routeInformation.location != null && !_ignoreNextBrowserCalls) {
          // Get the new state
          final newState = (kIsWeb)
              ? Map<String, String?>.from(jsonDecode((routeInformation.state as String?) ??
                  (BrowserHelpers.getHistoryState() ?? '{}')))
              : <String, String>{};

          // Get the new serial count
          var newSerialCount;
          try {
            newSerialCount = int.parse(newState['serialCount'] ?? '');
            // ignore: empty_catches
          } on FormatException {}

          // Check if this is the first route
          if (newSerialCount == null || newSerialCount == 0) {
            // If so, check is the url reported by the browser is the same as the initial url
            // We check "routeInformation.location == '/'" to enable deep linking
            if (routeInformation.location == '/' &&
                routeInformation.location != widget.initialUrl.url) {
              return;
            }
          }

          // Update the app with the new url
          await _updateUrl(
            routeInformation.location!,
            newState: newState,
            fromBrowser: true,
            newSerialCount: newSerialCount ?? _serialCount + 1,
          );
        }
        return null;
      },
      appStateToUrl: () {
        return RouteInformation(
          location: url ?? '/',
          state: jsonEncode({
            'serialCount': '$_serialCount',
            '-1': vRouterNode?.historyState,
            for (var pages in _flattenPages)
              '${pages.child.depth}': pages.child.stateKey?.currentState?.historyState ??
                  pages.child.initialHistorySate,
          }),
        );
      },
      child: VRouterMethodsHolder(
        state: this,
        child: Builder(
          builder: (context) {
            _vRouterInformationContext = context;

            // When the app starts, before we process the '/' route, we display
            // a CircularProgressIndicator.
            // Ideally this should never be needed, or replaced with a splash screen
            // Should we add the option ?
            return vRouterNode != null
                ? VRouterData(
                    child: vRouterNode!,
                    state: this,
                    url: url,
                    previousUrl: previousUrl,
                    historyState: historyState,
                    pathParameters: pathParameters,
                    queryParameters: queryParameters,
                  )
                : Center(child: CircularProgressIndicator());
          },
        ),
      ),
      title: widget.title ?? '',
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
      supportedLocales: widget.supportedLocales ?? const <Locale>[Locale('en', 'US')],
      debugShowMaterialGrid: widget.debugShowMaterialGrid ?? false,
      showPerformanceOverlay: widget.showPerformanceOverlay ?? false,
      checkerboardRasterCacheImages: widget.checkerboardRasterCacheImages ?? false,
      checkerboardOffscreenLayers: widget.checkerboardOffscreenLayers ?? false,
      showSemanticsDebugger: widget.showSemanticsDebugger ?? false,
      debugShowCheckedModeBanner: widget.debugShowCheckedModeBanner ?? true,
      shortcuts: widget.shortcuts,
      actions: widget.actions,
    );
  }

  /// A recursive function which is used to build [_pathToRoutes]
  List<_VRoutePath> _getRoutesFlatten({
    required List<VRouteElement> childRoutes,
    _VRoutePath? parentVRoutePath,
  }) {
    final routesFlatten = <_VRoutePath>[];
    final parentPath = parentVRoutePath?.path ?? '';
    var parentVRouteElements =
        List<VRouteElement>.from(parentVRoutePath?.vRouteElements ?? <VRouteElement>[]);

    // For each childRoutes
    for (var childRoute in childRoutes) {
      // Add the VRouteElement to the parent ones to from the VRouteElements list
      final vRouteElements = List<VRouteElement>.from([...parentVRouteElements, childRoute]);

      // If the path is null, just get the route from the subroutes
      if (childRoute.path == null) {
        routesFlatten.addAll(
          _getRoutesFlatten(
            childRoutes: childRoute.subroutes ?? [],
            parentVRoutePath: _VRoutePath(
              pathRegExp: parentVRoutePath?.pathRegExp ?? RegExp(''),
              path: parentVRoutePath?.path ?? '',
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
        final globalPath = (childRoute.path!.startsWith('/'))
            ? childRoute.path!
            : parentPath + '/${childRoute.path!}';

        // Get the pathRegExp and the new parameters
        var newGlobalParameters = <String>[];
        final globalPathRegExp = pathToRegExp(globalPath, parameters: newGlobalParameters);

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

          for (var alias in childRoute.aliases!) {
            // Get the global path
            final globalPath = (alias.startsWith('/')) ? alias : parentPath + '/$alias';

            // Get the pathRegExp and the new parameters
            var newGlobalParameters = <String>[];
            final globalPathRegExp = pathToRegExp(globalPath, parameters: newGlobalParameters);

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
        if (childRoute.subroutes != null && childRoute.subroutes!.isNotEmpty) {
          // Get the routes from the subroutes

          // For the path
          routesFlatten.addAll(
            _getRoutesFlatten(
              childRoutes: childRoute.subroutes!,
              parentVRoutePath: vRoutePath,
            ),
          );

          // If there is any alias
          if (childRoute.aliases != null) {
            // For the aliases
            for (var i = 0; i < childRoute.aliases!.length; i++) {
              routesFlatten.addAll(
                _getRoutesFlatten(
                  childRoutes: childRoute.subroutes!,
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
  void _updateStateVariables(
    String newUrl,
    String newPath,
    _VRoutePath vRoutePath, {
    required List<VPage> pages,
    required List<VPage> flattenPages,
    Map<String, String> queryParameters = const {},
    String? routeHistoryState,
    String? historyState,
    Map<String, String> pathParameters = const {},
  }) {
    // Update the vRoute
    vRouterNode = VRouterNode(
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      pages: pages,
      navigatorKey: _navigatorKey,
      heroController: _heroController,
      historyState: historyState,
      systemPop: (
              {Map<String, String> queryParameters = const <String, String>{},
              String? routerState}) =>
          systemPop(
        queryParameters: queryParameters,
        newState: routerState,
      ),
      pop: (
              {Map<String, String> queryParameters = const <String, String>{},
              String? routerState}) =>
          pop(
        queryParameters: queryParameters,
        newState: routerState,
      ),
      state: this,
      previousUrl: url,
      url: newUrl,
    );

    // Update the url and the previousUrl
    previousUrl = url;
    url = newUrl;

    // Update the history state
    this.historyState = historyState;

    // Update the path parameters
    this.pathParameters = pathParameters;

    // Update the query parameters
    this.queryParameters = queryParameters;

    // Update flattenPages
    this._flattenPages = flattenPages;
  }

  /// See [VRouterMethodsHolder.pushNamed]
  void _updateUrlFromName(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    Map<String, String> newState = const {},
    bool isReplacement = false,
  }) {
    // Find the VRoutePath corresponding to the name
    // Since each alias represent a VRoutePath, there might be several element in the list
    var potentialRoutes = _pathToRoutes
        .where((_VRoutePath vRoutePathRegexp) => (vRoutePathRegexp.name == name))
        .toList();

    if (potentialRoutes.isEmpty) {
      throw Exception('Could not find VRouteElement with name $name');
    }

    // Get the path from the list of potentialRoute
    // To discriminate we find the one which pathParameters match the given pathParameters
    var newPath = potentialRoutes.firstWhere(
      (_VRoutePath vRoutePathRegexp) =>
          (listEquals(vRoutePathRegexp.parameters, pathParameters.keys.toList())),
      orElse: () {
        final potentialRoutesOrdered = List<_VRoutePath>.from(potentialRoutes)
          ..sort((routeA, routeB) => routeA.parameters.length - routeB.parameters.length);
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
    _updateUrl(newPath, queryParameters: queryParameters, isReplacement: isReplacement);
  }

  /// Recursive function which builds a nested representation of the given route
  /// The route is given as a list of [VRouteElement]s
  ///
  /// This function is also in charge of populating the given [flattenPages]
  /// which pages should be the same as in the nested structure
  List<VPage> _buildPagesFromVRouteClassList({
    required List<VPage> incompleteStack,
    required List<VRouteElement> vRouteElements,
    required String remainingUrl,
    int index = 0,
    required List<VPage> flattenPages,
    Map<String, String?> historyState = const {},
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
      var localPath = vRouteElement.path!;

      // First remove any / that would be in first position
      if (remainingUrl.startsWith('/')) remainingUrl = remainingUrl.replaceFirst('/', '');
      if (localPath.startsWith('/')) localPath = localPath.replaceFirst('/', '');

      // We try to match the pathRegExp with the remainingUrl
      // This is null if a deeper-nester VRouteElement has a path
      // which starts with '/' (which means that this pathRegExp is not part
      // of the url)
      final match = vRouteElement.pathRegExp!.matchAsPrefix(Uri.decodeComponent(remainingUrl));

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
      final newVPage = VPage.fromPlatform(
        key: vRouteElement.key ?? ValueKey(vRouteElement.path),
        name: vRouteElement.name ?? vRouteElement.path,
        buildTransition: vRouteElement.buildTransition ?? widget.buildTransition,
        transitionDuration: vRouteElement.transitionDuration ?? widget.transitionDuration,
        reverseTransitionDuration:
            vRouteElement.reverseTransitionDuration ?? widget.reverseTransitionDuration,
        child: VRouteElementWidget(
          vRouteElement: vRouteElement,
          stateKey: vRouteElement.stateKey,
          depth: index,
          pathParameters: localParameters,
          initialHistorySate: historyState['$index'],
        ),
      );
      incompleteStack.add(
        VPage.fromPlatform(
          key: lastPage.key,
          name: lastPage.name,
          buildTransition: lastPage.buildTransition,
          transitionDuration: lastPage.transitionDuration,
          reverseTransitionDuration: lastPage.reverseTransitionDuration,
          child: VRouteElementWidget(
            vRouteElement: lastVRouteElementWidget._vRouteElement,
            stateKey: lastVRouteElementWidget.stateKey,
            depth: lastVRouteElementWidget.depth,
            pathParameters: lastVRouteElementWidget.pathParameters,
            initialHistorySate: lastVRouteElementWidget.initialHistorySate,
            vChildName: vRouteElement.name,
            vChild: VRouterHelper(
              observers: [vRouteElements[index - 1].heroController!],
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
                pop();
                return false;
              },
              onSystemPopPage: () async {
                await systemPop();
                return true;
              },
            ),
          ),
        ),
      );

      // Pop flatten pages
      // We use insert to flattenPagesPreviousLength to be sure that the order if which the
      // pages are inserted in flattenPages corresponds to the order in which VRouteElements
      // are nested
      flattenPages.insert(flattenPagesPreviousLength, newVPage);
      return incompleteStack;
    } else {
      // If the next vRoute is not a child, just add it to the stack and make a recursive call
      final newVPage = VPage.fromPlatform(
        key: vRouteElement.key ?? ValueKey(vRouteElement.path),
        name: vRouteElement.name ?? vRouteElement.path,
        buildTransition: vRouteElement.buildTransition ?? widget.buildTransition,
        transitionDuration: vRouteElement.transitionDuration ?? widget.transitionDuration,
        reverseTransitionDuration:
            vRouteElement.reverseTransitionDuration ?? widget.reverseTransitionDuration,
        child: VRouteElementWidget(
          stateKey: vRouteElement.stateKey,
          vRouteElement: vRouteElement,
          depth: index,
          pathParameters: localParameters,
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
  /// 1. Call beforeLeave in all deactivated [VNavigationGuard]
  /// 2. Call beforeLeave in all deactivated [VRouteElement]
  /// 3. Call beforeLeave in the [VRouter]
  /// 4. Call beforeEnter in the [VRouter]
  /// 5. Call beforeEnter in all initialized [VRouteElement] of the new route
  /// 6. Call beforeUpdate in all reused [VRouteElement]
  ///
  /// ## The history state got in beforeLeave are stored
  /// ## The state is updated
  ///
  /// 7. Call afterEnter in all initialized [VNavigationGuard]
  /// 8. Call afterEnter all initialized [VRouteElement]
  /// 9. Call afterEnter in the [VRouter]
  /// 10. Call afterUpdate in all reused [VNavigationGuard]
  /// 11. Call afterUpdate in all reused [VRouteElement]
  Future<void> _updateUrl(
    String newUrl, {
    Map<String, String?>? newState,
    bool fromBrowser = false,
    int? newSerialCount,
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
    final path = (url != null) ? Uri.parse(url!).path : null;

    var newPathParameters = <String, String>{};
    List<VPage> deactivatedPages;
    List<VPage> reusedPages;
    List<VPage> initializedPages;
    _VRoutePath? newVRoutePathOfPath;
    List<VPage> newFlattenPages;
    List<VPage> newRouterPages;
    if (isUrlExternal) {
      deactivatedPages = List.from(_flattenPages);
      reusedPages = <VPage>[];
      newVRoutePathOfPath = null;
      newFlattenPages = <VPage>[];
      newRouterPages = <VPage>[];
      initializedPages = <VPage>[];
    } else {
      // Get the new route
      newVRoutePathOfPath = _pathToRoutes.firstWhere(
          (_VRoutePath vRoutePathRegexp) => vRoutePathRegexp.pathRegExp.hasMatch(newPath),
          orElse: () => throw InvalidUrlException(url: newUrl));

      // This copy is necessary in order not to modify vRoutePath.vRoutePathLocals
      final localInformationOfPath =
          List<VRouteElement>.from(newVRoutePathOfPath.vRouteElements);

      // Extract the path parameters from the url
      final match = newVRoutePathOfPath.pathRegExp.matchAsPrefix(newPath);
      newPathParameters = (match != null)
          ? extract(newVRoutePathOfPath.parameters, match)
          : <String, String>{};
      // Decode path parameters
      newPathParameters =
          newPathParameters.map((key, value) => MapEntry(key, Uri.decodeComponent(value)));

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
      if (_flattenPages.isNotEmpty) {
        for (var vPage in _flattenPages.reversed) {
          try {
            newFlattenPages.firstWhere((newPage) => (newPage.key == vPage.key));
            reusedPages.add(vPage);
          } on StateError {
            deactivatedPages.add(vPage);
          }
        }
      }
      initializedPages = newFlattenPages
          .where(
            (newPage) => _flattenPages.indexWhere((page) => page.key == newPage.key) == -1,
          )
          .toList();
    }

    var shouldSaveHistoryState = false;
    var historyStatesToSave = {
      'serialCount': '$_serialCount',
      '-1': vRouterNode?.historyState,
      for (var pages in _flattenPages)
        '${pages.child.depth}':
            pages.child.stateKey?.currentState?.historyState ?? pages.child.initialHistorySate,
    };
    String? objectToSave;
    void saveHistoryState(String historyState) {
      if (objectToSave != null) {
        throw Exception("""You should only call saveHistoryState once.
This might be because: 
  - You try to use saveHistoryState in a VNavigationGuard AND its corresponding VRouteElement. Use it in one of them but not the two.
  - You try to use saveHistoryState in multiple VNavigationGuard corresponding to the same VRouteElement. Use it in maximum one of them.""");
      }
      objectToSave = historyState;
    }

    // Instantiate VRedirector
    final vRedirector = VRedirector(
      context: _vRouterInformationContext,
      from: url,
      to: newUrl,
      previousVRouteData: VRouteData(
        child: Container(),
        historyState: vRouterNode?.historyState,
        replaceHistoryState: (String _) =>
            throw 'replaceHistoryState cannot be called using this object.\n'
                'If you want to save the state of the current route: Use saveHistoryState in beforeLeave.\n'
                'If you want to change the history state of the new route: call VRouterData.replaceHistoryState in afterEnter or afterUpdate.',
        pathParameters: vRouterNode?.pathParameters ?? {},
        queryParameters: vRouterNode?.queryParameters ?? {},
      ),
      newVRouteData: VRouteData(
        child: Container(),
        historyState: newState['-1'],
        replaceHistoryState: (String _) =>
            throw 'replaceHistoryState cannot be called using this object.\n'
                'If you want to save the state of the current route: Use saveHistoryState in beforeLeave.\n'
                'If you want to change the history state of the new route: call VRouterData.replaceHistoryState in afterEnter or afterUpdate.',
        pathParameters: newPathParameters,
        queryParameters: queryParameters,
      ),
      previousVRouterData: VRouterData(
        child: Container(),
        historyState: vRouterNode?.historyState,
        pathParameters: vRouterNode?.pathParameters ?? {},
        queryParameters: vRouterNode?.queryParameters ?? {},
        state: this,
        url: url,
        previousUrl: previousUrl,
      ),
      newVRouterData: VRouterData(
        child: Container(),
        historyState: newState['-1'],
        pathParameters: newPathParameters,
        queryParameters: queryParameters,
        state: this,
        url: newUrl,
        previousUrl: url,
      ),
    );

    if (url != null) {
      ///   1. Call beforeLeave in all deactivated [VNavigationGuard]
      ///   2. Call beforeLeave in all deactivated [VRouteElement]
      for (var deactivatedPage in deactivatedPages) {
        final vNavigationGuardMessages =
            deactivatedPage.child.stateKey?.currentState?.vNavigationGuardMessages ?? [];
        for (var vNavigationGuardMessage in vNavigationGuardMessages) {
          if (vNavigationGuardMessage.vNavigationGuard.beforeLeave != null) {
            await vNavigationGuardMessage.vNavigationGuard.beforeLeave!(
                vRedirector, saveHistoryState);
            if (!vRedirector._shouldUpdate) {
              break;
            }
          }
        }
        if (vRedirector._shouldUpdate) {
          if (deactivatedPage.child._vRouteElement.beforeLeave != null) {
            deactivatedPage.child._vRouteElement.beforeLeave!(vRedirector, saveHistoryState);
          }
        }
        if (!vRedirector._shouldUpdate) {
          break;
        } else if (objectToSave != null &&
            historyStatesToSave['${deactivatedPage.child.depth}'] != objectToSave) {
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
            (BrowserHelpers.getHistorySerialCount() ?? 0) != _serialCount) {
          _ignoreNextBrowserCalls = true;
          BrowserHelpers.browserGo(_serialCount - newSerialCount!);
          await BrowserHelpers.onBrowserPopState
              .firstWhere((element) => BrowserHelpers.getHistorySerialCount() == _serialCount);
          _ignoreNextBrowserCalls = false;
        }
        vRedirector._redirectFunction?.call();
        return;
      }

      /// 3. Call beforeLeave in the [VRouter]
      if (widget.beforeLeave != null) {
        await widget.beforeLeave!(vRedirector, saveHistoryState);
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
              (BrowserHelpers.getHistorySerialCount() ?? 0) != _serialCount) {
            _ignoreNextBrowserCalls = true;
            BrowserHelpers.browserGo(_serialCount - newSerialCount!);
            await BrowserHelpers.onBrowserPopState.firstWhere(
                (element) => BrowserHelpers.getHistorySerialCount() == _serialCount);
            _ignoreNextBrowserCalls = false;
          }
          vRedirector._redirectFunction?.call();
          return;
        }
      }
    }

    if (!isUrlExternal) {
      /// 4. Call beforeEnter in the [VRouter]
      if (widget.beforeEnter != null) {
        await widget.beforeEnter!(vRedirector);
        if (!vRedirector._shouldUpdate) {
          // If the url change comes from the browser, chances are the url is already changed
          // So we have to navigate back to the old url (stored in _url)
          // Note: in future version it would be better to delete the last url of the browser
          //        but it is not yet possible
          if (kIsWeb &&
              fromBrowser &&
              (BrowserHelpers.getHistorySerialCount() ?? 0) != _serialCount) {
            _ignoreNextBrowserCalls = true;
            BrowserHelpers.browserGo(_serialCount - newSerialCount!);
            await BrowserHelpers.onBrowserPopState.firstWhere(
                (element) => BrowserHelpers.getHistorySerialCount() == _serialCount);
            _ignoreNextBrowserCalls = false;
          }
          vRedirector._redirectFunction?.call();
          return;
        }
      }

      /// 5. Call beforeEnter in all initialized [VRouteElement] of the new route
      for (var vPage in initializedPages) {
        if (vPage.child._vRouteElement.beforeEnter != null) {
          await vPage.child._vRouteElement.beforeEnter!(vRedirector);
          if (!vRedirector._shouldUpdate) {
            // If the url change comes from the browser, chances are the url is already changed
            // So we have to navigate back to the old url (stored in _url)
            // Note: in future version it would be better to delete the last url of the browser
            //        but it is not yet possible
            if (kIsWeb &&
                fromBrowser &&
                (BrowserHelpers.getHistorySerialCount() ?? 0) != _serialCount) {
              _ignoreNextBrowserCalls = true;
              BrowserHelpers.browserGo(_serialCount - newSerialCount!);
              await BrowserHelpers.onBrowserPopState.firstWhere(
                  (element) => BrowserHelpers.getHistorySerialCount() == _serialCount);
              _ignoreNextBrowserCalls = false;
            }
            vRedirector._redirectFunction?.call();
            return;
          }
        }
      }

      /// 6. Call beforeUpdate in all reused [VRouteElement]
      for (var vPage in reusedPages) {
        if (vPage.child._vRouteElement.beforeUpdate != null) {
          await vPage.child._vRouteElement.beforeUpdate!(vRedirector);
          if (!vRedirector._shouldUpdate) {
            // If the url change comes from the browser, chances are the url is already changed
            // So we have to navigate back to the old url (stored in _url)
            // Note: in future version it would be better to delete the last url of the browser
            //        but it is not yet possible
            if (kIsWeb &&
                fromBrowser &&
                (BrowserHelpers.getHistorySerialCount() ?? 0) != _serialCount) {
              _ignoreNextBrowserCalls = true;
              BrowserHelpers.browserGo(_serialCount - newSerialCount!);
              await BrowserHelpers.onBrowserPopState.firstWhere(
                      (element) => BrowserHelpers.getHistorySerialCount() == _serialCount);
              _ignoreNextBrowserCalls = false;
            }
            vRedirector._redirectFunction?.call();
            return;
          }
        }
      }
    }

    final oldSerialCount = _serialCount;
    if (shouldSaveHistoryState && path != null && historyStatesToSave.isNotEmpty) {
      if (!kIsWeb) {
        print(
            ' WARNING: Tried to store the state $historyStatesToSave while not on the web. State saving/restoration only work on the web.\n'
            'You can safely ignore this message if you just want this functionality on the web.');
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
          await BrowserHelpers.onBrowserPopState.firstWhere(
              (element) => BrowserHelpers.getHistorySerialCount() == oldSerialCount);
        }
        BrowserHelpers.replaceHistoryState(jsonEncode(historyStatesToSave));
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
      await BrowserHelpers.pushExternal(newUrl, openNewTab: openNewTab);
      return;
    }

    ///   The state of the VRouter changes            ///
    // Add the new serial count to the state
    newState.addAll(Map<String, String>.from({'serialCount': '$_serialCount'}));
    final oldUrl = url;
    final newRouterState = newState['-1'];
    if (url != newUrl || newRouterState != vRouterNode?.historyState) {
      _updateStateVariables(
        newUrl,
        newPath,
        newVRoutePathOfPath!,
        historyState: newRouterState,
        pages: newRouterPages,
        flattenPages: newFlattenPages,
        queryParameters: queryParameters,
        routeHistoryState: newState['-1'],
        pathParameters: newPathParameters,
      );
      if (isReplacement) {
        _ignoreNextBrowserCalls = true;
        if (BrowserHelpers.getPathAndQuery(routerMode: widget.mode) != newUrl) {
          BrowserHelpers.pushReplacement(newUrl, routerMode: widget.mode);
          if (BrowserHelpers.getPathAndQuery(routerMode: widget.mode) != newUrl) {
            await BrowserHelpers.onBrowserPopState.firstWhere((element) =>
                BrowserHelpers.getPathAndQuery(routerMode: widget.mode) == newUrl);
          }
        }
        BrowserHelpers.replaceHistoryState(jsonEncode(newState));
        _ignoreNextBrowserCalls = false;
      } else {
        _serialCount = newSerialCount ?? _serialCount + 1;
      }
      setState(() {});
    }

    // We need to do this after rebuild as completed so that the user can have access
    // to the new state variables
    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      /// 7. Call afterEnter in all initialized [VNavigationGuard]
      // This is done automatically by VNotificationGuard

      /// 8. Call afterEnter all initialized [VRouteElement]
      for (var vPage in initializedPages) {
        if (vPage.child._vRouteElement.afterEnter != null) {
          vPage.child._vRouteElement.afterEnter!(
            vPage.child._vRouteElement.stateKey!.currentContext!,
            oldUrl,
            newUrl,
          );
        }
      }

      /// 9. Call afterEnter in the [VRouter]
      if (widget.afterEnter != null) {
        widget.afterEnter!(_vRouterInformationContext, oldUrl, newUrl);
      }

      /// 10. Call afterUpdate in all reused [VNavigationGuard]
      for (var vPage in reusedPages) {
        final vNavigationMessages =
            vPage.child.stateKey?.currentState?.vNavigationGuardMessages ?? [];
        for (var vNavigationMessage in vNavigationMessages) {
          if (vNavigationMessage.vNavigationGuard.afterUpdate != null) {
            vNavigationMessage.vNavigationGuard.afterUpdate!(
              vNavigationMessage.localContext,
              oldUrl,
              newUrl,
            );
          }
        }
      }

      /// 11. Call afterUpdate in all reused [VRouteElement]
      for (var vPage in reusedPages) {
        if (vPage.child._vRouteElement.afterUpdate != null) {
          vPage.child._vRouteElement.afterUpdate!(
            vPage.child._vRouteElement.stateKey!.currentContext!,
            oldUrl,
            newUrl,
          );
        }
      }
    });
  }

  Future<void> _pop({
    VRedirector? vRedirector,
    Map<String, String> queryParameters = const {},
    String? newState,
  }) async {
    assert(url != null);

    // Instantiate VRedirector if null
    // It might be not null if called from systemPop
    vRedirector ??= _defaultPop(queryParameters: queryParameters);

    /// Call onPop in all active VNavigationGuards
    for (var page in _flattenPages.reversed) {
      final vNavigationMessages =
          page.child.stateKey?.currentState?.vNavigationGuardMessages ?? [];
      for (var vNavigationMessage in vNavigationMessages.reversed) {
        if (vNavigationMessage.vNavigationGuard.onPop != null) {
          await vNavigationMessage.vNavigationGuard.onPop!(vRedirector);
          if (!vRedirector.shouldUpdate) {
            return;
          }
        }
      }
    }

    /// Call onPop of the nested-most VRouteElement
    // Get the current path
    final path = Uri.parse(url!).path;

    // Get the current route
    final vRoutePathLocals = _pathToRoutes
        .firstWhere(
            (_VRoutePath vRoutePathRegexp) => vRoutePathRegexp.pathRegExp.hasMatch(path),
            orElse: () => throw InvalidUrlException(url: path))
        .vRouteElements;

    // Find the VRouteClass which is the deepest possible
    // having onPopPage implemented
    final vRouteElement = vRoutePathLocals.last;
    if (vRouteElement.onPop != null) {
      await vRouteElement.onPop!(vRedirector);
      if (!vRedirector.shouldUpdate) {
        return;
      }
    }

    /// Call onPop of VRouter
    if (widget.onPop != null) {
      await widget.onPop!(vRedirector);
      if (!vRedirector.shouldUpdate) {
        return;
      }
    }

    /// Update the url to the one found in [_defaultPop]
    if (vRedirector.newVRouterData != null) {
      _updateUrl(vRedirector.to!,
          queryParameters: queryParameters, newState: {'-1': newState});
    } else if (!kIsWeb) {
      // If we didn't find a url to go to, we are at the start of the stack
      // so we close the app on mobile
      // TODO: call move_to_background once it's migrated to null-safety
    }
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
    String? newState,
  }) {
    assert(url != null);
    final path = Uri.parse(url!).path;

    // Get the current route (we copy it to avoid modifying it)
    final vRouteElements = List<VRouteElement>.from(
      _pathToRoutes
          .firstWhere(
              (_VRoutePath vRoutePathRegexp) => vRoutePathRegexp.pathRegExp.hasMatch(path),
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
    VRouteData? newVRouteData;

    // This VRouterData will be not null if we find a route to go to
    VRouterData? newVRouterData;

    // This url will be not null if we find a route to go to
    String? newUrl;

    if (vRouteElements.isNotEmpty) {
      // Get the VRoutePath from the vRouteElements
      final newVRoutePath = _pathToRoutes.firstWhere(
        (vRoutePath) => listEquals(vRoutePath.vRouteElements, vRouteElements),
      );

      // Get the new pathRegexp as a prefix regExp
      final newPathRegExpPrefix = pathToRegExp(newVRoutePath.path, prefix: true);

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
      newPathParameters =
          newPathParameters.map((key, value) => MapEntry(key, Uri.decodeComponent(value)));

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

      newVRouterData = VRouterData(
        child: Container(),
        historyState: newState,
        pathParameters: newPathParameters,
        queryParameters: queryParameters,
        url: newUrl,
        previousUrl: url,
        state: this,
      );
    }

    return VRedirector(
      context: _vRouterInformationContext,
      from: url,
      to: newUrl,
      previousVRouteData: VRouteData(
        child: Container(),
        historyState: vRouterNode?.historyState,
        replaceHistoryState: (String _) =>
            throw 'replaceHistoryState cannot be called using this object.\n'
                'If you want to save the state of the current route: Use saveHistoryState in beforeLeave.\n'
                'If you want to change the history state of the new route: call VRouterData.replaceHistoryState in afterEnter or afterUpdate.',
        pathParameters: vRouterNode?.pathParameters ?? {},
        queryParameters: vRouterNode?.queryParameters ?? {},
      ),
      previousVRouterData: VRouterData(
        child: Container(),
        historyState: vRouterNode?.historyState,
        pathParameters: vRouterNode?.pathParameters ?? {},
        queryParameters: vRouterNode?.queryParameters ?? {},
        state: this,
        previousUrl: previousUrl,
        url: url,
      ),
      newVRouteData: newVRouteData,
      newVRouterData: newVRouterData,
    );
  }

  /// See [VRouterMethodsHolder.replaceHistoryState]
  void replaceHistoryState(String newRouterState) {
    if (kIsWeb) {
      final historyState = BrowserHelpers.getHistoryState() ?? '{}';
      final historyStateMap = Map<String, String>.from(jsonDecode(historyState));
      historyStateMap['-1'] = newRouterState;
      final newHistoryState = jsonEncode(historyStateMap);
      BrowserHelpers.replaceHistoryState(newHistoryState);
    }
    setState(() {
      historyState = newRouterState;
    });
  }

  /// WEB ONLY
  /// Save the state if needed before the app gets unloaded
  /// Mind that this happens when the user enter a url manually in the
  /// browser so we can't prevent him from leaving the page
  void _onBeforeUnload() async {
    if (url == null) return;
    final newSerialCount = _serialCount + 1;
    final path = Uri.parse(url!).path;

    var shouldSaveHistoryState = true;

    var historyStatesToSave = <String, String>{};
    String? objectToSave;
    void saveHistoryState(String historyState) {
      if (objectToSave != null) {
        throw Exception('You should only call saveHistoryState once');
      }
      objectToSave = historyState;
    }

    ///   1. beforeLeave in all deactivated vRouteElement
    for (var deactivatedPage in _flattenPages) {
      final vNavigationMessages =
          deactivatedPage.child.stateKey?.currentState?.vNavigationGuardMessages ?? [];
      for (var vNavigationMessage in vNavigationMessages) {
        if (vNavigationMessage.vNavigationGuard.beforeLeave != null) {
          await vNavigationMessage.vNavigationGuard.beforeLeave!(null, saveHistoryState);
          if (objectToSave != null) {
            historyStatesToSave['${deactivatedPage.child.depth}'] = objectToSave!;
            objectToSave = null;
            shouldSaveHistoryState = true;
          }
        }
      }
    }

    ///   2. beforeLeave in the nest-most [VRouteElement] of the current route
    // Get the actual route
    final vRoutePathOfPath = _pathToRoutes.firstWhere(
        (_VRoutePath vRoutePathRegexp) => vRoutePathRegexp.pathRegExp.hasMatch(path),
        orElse: () => throw InvalidUrlException(url: path));

    // Call the nest-most VRouteClass of the current route
    final vRouteElement = vRoutePathOfPath.vRouteElements.last;
    if (vRouteElement.beforeLeave != null) {
      vRouteElement.beforeLeave!(null, saveHistoryState);

      if (objectToSave != null && historyStatesToSave['-1'] != objectToSave) {
        historyStatesToSave['-1'] = objectToSave!;
        objectToSave = null;
        shouldSaveHistoryState = true;
      }
    }

    ///   3. beforeLeave in the VRouter
    if (widget.beforeLeave != null) {
      await widget.beforeLeave!(null, saveHistoryState);
      if (objectToSave != null) {
        historyStatesToSave['-1'] = objectToSave!;
        objectToSave = null;
        shouldSaveHistoryState = true;
      }
    }

    if (historyStatesToSave.isNotEmpty && shouldSaveHistoryState) {
      ///   The historyStates got in beforeLeave are stored   ///
      _serialCount = newSerialCount;
      BrowserHelpers.replaceHistoryState(jsonEncode(historyStatesToSave));
    }
  }

  /// See [VRouterMethodsHolder.pop]
  Future<void> pop({
    Map<String, String> queryParameters = const {},
    String? newState,
  }) async {
    _pop(queryParameters: queryParameters, newState: newState);
  }

  /// See [VRouterMethodsHolder.systemPop]
  Future<void> systemPop({
    Map<String, String> queryParameters = const {},
    String? newState,
  }) async {
    assert(url != null);

    // Instantiate VRedirector if null
    // It might be not null if called from systemPop
    final vRedirector = _defaultPop(queryParameters: queryParameters);

    /// Call onSystemPop in all active VNavigationGuards
    for (var page in _flattenPages.reversed) {
      final vNavigationMessages =
          page.child.stateKey?.currentState?.vNavigationGuardMessages ?? [];
      for (var vNavigationMessage in vNavigationMessages.reversed) {
        if (vNavigationMessage.vNavigationGuard.onSystemPop != null) {
          await vNavigationMessage.vNavigationGuard.onSystemPop!(vRedirector);
          if (!vRedirector.shouldUpdate) {
            return;
          }
        }
      }
    }

    /// Call onSystemPop of the nested-most VRouteElement
    // Get the current path
    final path = Uri.parse(url!).path;

    // Get the current route
    final vRoutePathLocals = _pathToRoutes
        .firstWhere(
            (_VRoutePath vRoutePathRegexp) => vRoutePathRegexp.pathRegExp.hasMatch(path),
            orElse: () => throw InvalidUrlException(url: path))
        .vRouteElements;

    // Find the VRouteClass which is the deepest possible
    // having onSystemPopPage implemented
    final vRouteElement = vRoutePathLocals.last;
    if (vRouteElement.onSystemPop != null) {
      // If we did find a VRouteClass, call onSystemPopPage
      await vRouteElement.onSystemPop!(vRedirector);
      if (!vRedirector.shouldUpdate) {
        return;
      }
    }

    /// Call VRouter onSystemPop
    if (widget.onSystemPop != null) {
      // Call VRouter.onSystemPopPage if implemented
      await widget.onSystemPop!(vRedirector);
      if (!vRedirector.shouldUpdate) {
        return;
      }
    }

    /// Call onPop, which start a onPop cycle
    await _pop(vRedirector: vRedirector);
  }

  /// See [VRouterMethodsHolder.push]
  void push(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String? routerState,
  }) {
    if (!newUrl.startsWith('/')) {
      if (url == null) {
        throw Exception(
            "The current url is null but you are trying to access a path which does not start with '/'.");
      }
      final currentPath = Uri.parse(url!).path;
      newUrl = currentPath + '/$newUrl';
    }

    _updateUrl(newUrl,
        queryParameters: queryParameters,
        newState: (routerState != null) ? {'-1': routerState} : {});
  }

  /// See [VRouterMethodsHolder.pushNamed]
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? routerState,
  }) {
    _updateUrlFromName(name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newState: (routerState != null) ? {'-1': routerState} : {});
  }

  /// See [VRouterMethodsHolder.pushReplacement]
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String? routerState,
  }) {
    // If not on the web, this is the same as push
    if (!kIsWeb) {
      return push(newUrl, queryParameters: queryParameters, routerState: routerState);
    }

    if (!newUrl.startsWith('/')) {
      if (url == null) {
        throw Exception(
            "The current url is null but you are trying to access a path which does not start with'/'.");
      }
      final currentPath = Uri.parse(url!).path;
      newUrl = currentPath + '/$newUrl';
    }

    // Update the url, setting isReplacement to true
    _updateUrl(
      newUrl,
      queryParameters: queryParameters,
      newState: (routerState != null) ? {'-1': routerState} : {},
      isReplacement: true,
    );
  }

  /// See [VRouterMethodsHolder.pushReplacementNamed]
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? routerState,
  }) {
    _updateUrlFromName(name,
        pathParameters: pathParameters,
        queryParameters: queryParameters,
        newState: (routerState != null) ? {'-1': routerState} : {},
        isReplacement: true);
  }

  /// See [VRouterMethodsHolder.pushExternal]
  void pushExternal(String newUrl, {bool openNewTab = false}) =>
      _updateUrl(newUrl, isUrlExternal: true, openNewTab: openNewTab);
}

class VRouterNode extends StatelessWidget {
  final List<VPage> pages;
  final GlobalKey<NavigatorState> navigatorKey;
  final HeroController heroController;
  final void Function({
    Map<String, String> queryParameters,
    String? routerState,
  }) pop;
  final Future<void> Function({
    Map<String, String> queryParameters,
    String? routerState,
  }) systemPop;

  /// See [VRouterData.state]
  final VRouterState state;

  /// See [VRouterData.url]
  final String? url;

  /// See [VRouterData.previousUrl]
  final String? previousUrl;

  /// See [VRouterData.historyState]
  final String? historyState;

  /// See [VRouterData.pathParameters]
  final Map<String, String> pathParameters;

  /// See [VRouterData.queryParameters]
  final Map<String, String> queryParameters;

  const VRouterNode({
    Key? key,
    required this.pages,
    required this.navigatorKey,
    required this.heroController,
    required this.pop,
    required this.systemPop,
    required this.state,
    required this.url,
    required this.previousUrl,
    required this.historyState,
    required this.pathParameters,
    required this.queryParameters,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return VRouterData(
      state: state,
      url: url,
      previousUrl: previousUrl,
      historyState: historyState,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      child: VRouterHelper(
        pages: pages,
        navigatorKey: navigatorKey,
        observers: [heroController],
        backButtonDispatcher: RootBackButtonDispatcher(),
        onPopPage: (_, __) {
          pop();

          // We always prevent popping because we handle it in VRouter
          return false;
        },
        onSystemPopPage: () async {
          await systemPop();
          // We always prevent popping because we handle it in VRouter
          return true;
        },
      ),
    );
  }
}

class VRouterData extends InheritedWidget {
  final VRouterState _state;

  VRouterData({
    Key? key,
    required Widget child,
    required VRouterState state,
    required this.url,
    required this.previousUrl,
    required this.historyState,
    required this.pathParameters,
    required this.queryParameters,
  })   : _state = state,
        super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(VRouterData old) {
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
  final String? historyState;

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
  /// push) accessible with VRouterData.of(context).historyState
  @Deprecated("""Use VRouter.push instead.
  
Here are the important modification:
    - context.vRouter (or VRouter.of(context)): Holds every navigation methods (push, ...) 
    - context.vRouterData (or VRouterData.of(context)): holds every general route information 
    - context.vRouteElementData (or VRouteElementData.of(context)): Holds every local information 
""")
  void push(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String? routerState,
  }) =>
      _state.push(newUrl, queryParameters: queryParameters, routerState: routerState);

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
  @Deprecated("""Use VRouter.pushNamed instead.
  
Here are the important modification:
    - context.vRouter (or VRouter.of(context)): Holds every navigation methods (push, ...) 
    - context.vRouterData (or VRouterData.of(context)): holds every general route information 
    - context.vRouteElementData (or VRouteElementData.of(context)): Holds every local information 
""")
  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? routerState,
  }) =>
      _state.pushNamed(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          routerState: routerState);

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
  @Deprecated("""Use VRouter.pushReplacement instead.
  
Here are the important modification:
    - context.vRouter (or VRouter.of(context)): Holds every navigation methods (push, ...) 
    - context.vRouterData (or VRouterData.of(context)): holds every general route information 
    - context.vRouteElementData (or VRouteElementData.of(context)): Holds every local information 
""")
  void pushReplacement(
    String newUrl, {
    Map<String, String> queryParameters = const {},
    String? routerState,
  }) =>
      _state.pushReplacement(newUrl,
          queryParameters: queryParameters, routerState: routerState);

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
  @Deprecated("""Use VRouter.pushReplacementNamed instead.
  
Here are the important modification:
    - context.vRouter (or VRouter.of(context)): Holds every navigation methods (push, ...) 
    - context.vRouterData (or VRouterData.of(context)): holds every general route information 
    - context.vRouteElementData (or VRouteElementData.of(context)): Holds every local information 
""")
  void pushReplacementNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
    String? routerState,
  }) =>
      _state.pushReplacementNamed(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          routerState: routerState);

  /// Goes to an url which is not in the app
  ///
  /// On the web, you can set [openNewTab] to true to open this url
  /// in a new tab
  @Deprecated("""Use VRouter.pushExternal instead.
  
Here are the important modification:
    - context.vRouter (or VRouter.of(context)): Holds every navigation methods (push, ...) 
    - context.vRouterData (or VRouterData.of(context)): holds every general route information 
    - context.vRouteElementData (or VRouteElementData.of(context)): Holds every local information 
""")
  void pushExternal(String newUrl, {bool openNewTab = false}) =>
      _state.pushExternal(newUrl, openNewTab: openNewTab);

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
  @Deprecated("""Use VRouter.pop instead.
  
Here are the important modification:
    - context.vRouter (or VRouter.of(context)): Holds every navigation methods (push, ...) 
    - context.vRouterData (or VRouterData.of(context)): holds every general route information 
    - context.vRouteElementData (or VRouteElementData.of(context)): Holds every local information 
""")
  void pop({
    Map<String, String> queryParameters = const {},
    String? routerState,
  }) =>
      _state.pop(queryParameters: queryParameters, newState: routerState);

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
  @Deprecated("""Use VRouter.systemPop instead.
  
Here are the important modification:
    - context.vRouter (or VRouter.of(context)): Holds every navigation methods (push, ...) 
    - context.vRouterData (or VRouterData.of(context)): holds every general route information 
    - context.vRouteElementData (or VRouteElementData.of(context)): Holds every local information 
""")
  Future<void> systemPop({
    Map<String, String> queryParameters = const {},
    String? routerState,
  }) =>
      _state.systemPop(queryParameters: queryParameters, newState: routerState);

  /// This replaces the current history state of [VRouterData] with given one
  @Deprecated("""Use VRouter.replaceHistoryState instead.
  
Here are the important modification:
    - context.vRouter (or VRouter.of(context)): Holds every navigation methods (push, ...) 
    - context.vRouterData (or VRouterData.of(context)): holds every general route information 
    - context.vRouteElementData (or VRouteElementData.of(context)): Holds every local information 
""")
  void replaceHistoryState(String historyState) => _state.replaceHistoryState(historyState);

  static VRouterData of(BuildContext context) {
    final vRouterData = context.dependOnInheritedWidgetOfExactType<VRouterData>();
    if (vRouterData == null) {
      throw FlutterError(
          'VRouterData.of(context) was called with a context which does not contain a VRouter.\n'
          'The context used to retrieve VRouterData must be that of a widget that '
          'is a descendant of a VRouter widget.');
    }
    return vRouterData;
  }
}

class VRouterMethodsHolder extends InheritedWidget {
  final VRouterState _state;

  VRouterMethodsHolder({
    Key? key,
    required Widget child,
    required VRouterState state,
  })   : _state = state,
        super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(VRouterMethodsHolder old) => false;

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
    String? routerState,
  }) =>
      _state.push(newUrl, queryParameters: queryParameters, routerState: routerState);

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
    String? routerState,
  }) =>
      _state.pushNamed(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          routerState: routerState);

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
    String? routerState,
  }) =>
      _state.pushReplacement(newUrl,
          queryParameters: queryParameters, routerState: routerState);

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
    String? routerState,
  }) =>
      _state.pushReplacementNamed(name,
          pathParameters: pathParameters,
          queryParameters: queryParameters,
          routerState: routerState);

  /// Goes to an url which is not in the app
  ///
  /// On the web, you can set [openNewTab] to true to open this url
  /// in a new tab
  void pushExternal(String newUrl, {bool openNewTab = false}) =>
      _state.pushExternal(newUrl, openNewTab: openNewTab);

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
    String? routerState,
  }) =>
      _state.pop(queryParameters: queryParameters, newState: routerState);

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
    String? routerState,
  }) =>
      _state.systemPop(queryParameters: queryParameters, newState: routerState);

  /// This replaces the current history state of [VRouterData] with given one
  void replaceHistoryState(String historyState) => _state.replaceHistoryState(historyState);
}

extension VRouterContext on BuildContext {
  VRouterMethodsHolder get vRouter => VRouter.of(this);
}

extension VRouterDataContext on BuildContext {
  VRouterData get vRouterData => VRouterData.of(this);
}

extension VRouteElementDataContext on BuildContext {
  VRouteElementData get vRouteElementData => VRouteElementData.of(this);
}
