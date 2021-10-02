import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:vrouter/src/core/route.dart';
import 'package:vrouter/src/core/vredirector.dart';

/// [VRouteElement] is the base class for any object used in routes, stackedRoutes
/// or nestedRoutes
@immutable
abstract class VRouteElement {
  /// [buildRoute] must return [VRoute] if it constitute (which its subroutes or not) a valid
  /// route given the input parameters
  /// [VRoute] should describe this valid route
  ///
  ///
  /// [vPathRequestData] contains all the information about the original request coming
  /// from [VRouter]
  /// It should not be changed and should be given as-is to its subroutes
  ///
  /// [parentRemainingPath] is the part on which to base any local path
  /// WARNING: [parentRemainingPath] is null if the parent did not match the path
  /// in which case only absolute path should be tested.
  ///
  /// [parentPathParameters] are the path parameters of every [VRouteElement] above this
  /// one in the route
  ///
  /// [buildRoute] basically just checks for a match in stackedRoutes and if any
  /// adds this [VRouteElement] to the [VRoute]
  ///
  /// For more info on buildRoute, see [VRouteElement.buildRoute]
  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required VPathMatch parentVPathMatch,
    required bool parentCanPop,
  });

  /// This function takes a name and tries to find the path corresponding to
  /// the route matching this name
  ///
  /// The deeper nested the route the better
  /// The given path parameters have to include at least every path parameters of the final path
  GetPathFromNameResult getPathFromName(
    String nameToMatch, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
    required Map<String, String> remainingPathParameters,
  });

  /// [VPopResult.didPop] is true if this [VRouteElement] popped
  /// [VPopResult.extendedPath] is null if this path can't be the right one according to
  ///                                                                     the path parameters
  /// [VPopResult] is null when this [VRouteElement] does not pop AND none of
  ///                                                                     its stackedRoutes popped
  VPopResult getPathFromPop(
    VRouteElement elementToPop, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
  });

  /// This is called before the url is updated if this [VRouteElement] was NOT in the
  /// previous route but is in the new route
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.beforeEnter] for router level beforeEnter
  ///   * [VRedirector] to known how to redirect and have access to route information
  Future<void> beforeEnter(VRedirector vRedirector);

  /// This is called before the url is updated if this [VRouteElement] was in the previous
  /// route and is in the new route
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VWidgetGuard.beforeUpdate] for widget level beforeUpdate
  ///   * [VRedirector] to known how to redirect and have access to route information
  Future<void> beforeUpdate(VRedirector vRedirector);

  /// Called when a url changes, before the url is updated
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// [saveHistoryState] can be used to save a history state before leaving
  /// This history state will be restored if the user uses the back button
  /// You will find the saved history state in the [VRouteElementData] using
  /// [VRouter.of(context).historyState]
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouteElement.beforeLeave] for route level beforeLeave
  ///   * [VWidgetGuard.beforeLeave] for widget level beforeLeave
  ///   * [VRedirector] to known how to redirect and have access to route information
  Future<void> beforeLeave(
    VRedirector vRedirector,
    void Function(Map<String, String> state) saveHistoryState,
  );

  /// This is called after the url and the historyState are updated and this [VRouteElement]
  /// was in the previous route and is NOT in the new route
  /// You can't prevent the navigation anymore
  /// You can get the new route parameters, and queryParameters
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.afterEnter] for router level afterEnter
  ///   * [VWidgetGuard.afterEnter] for widget level afterEnter
  void afterLeave(BuildContext context, String? from, String to);

  /// This is called after the url and the historyState are updated and this [VRouteElement]
  /// was NOT in the previous route and is in the new route
  /// You can't prevent the navigation anymore
  /// You can get the new route parameters, and queryParameters
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.afterEnter] for router level afterEnter
  ///   * [VWidgetGuard.afterEnter] for widget level afterEnter
  void afterEnter(BuildContext context, String? from, String to);

  /// This is called after the url and the historyState are updated and this [VRouteElement]
  /// was in the previous route and is in the new route
  /// You can't prevent the navigation anymore
  /// You can get the new route parameters, and queryParameters
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VWidgetGuard.afterUpdate] for widget level afterUpdate
  void afterUpdate(BuildContext context, String? from, String to);

  /// Called when a pop event occurs
  /// A pop event can be called programmatically (with [VRouter.of(context).pop()])
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
  ///   * [VRouter.onPop] for router level onPop
  ///   * [VWidgetGuard.onPop] for widget level onPop
  ///   * [VRedirector] to known how to redirect and have access to route information
  Future<void> onPop(VRedirector vRedirector);

  /// Called when a system pop event occurs.
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
  ///   * [VRouter.onSystemPop] for route level onSystemPop
  ///   * [VWidgetGuard.onSystemPop] for widget level onSystemPop
  ///   * [VRedirector] to known how to redirect and have access to route information
  Future<void> onSystemPop(VRedirector vRedirector);
}

/// Return type of [VRouteElement.getPathFromPop]
abstract class VPopResult {}

/// This is to be returned if the [VPopResult] is valid
abstract class FoundPopResult extends VPopResult {
  /// List of every popping [VRouteElement]
  List<VRouteElement> get poppedVRouteElements;
}

/// Return from [VRouteElement.getPathFromPop] when the [VRouteElement] is being popped
/// due to the pop event
class PoppingPopResult extends FoundPopResult {
  /// List of every popping [VRouteElement]
  ///
  /// The [VRouteElement] returning this should be part of [poppedVRouteElements]
  final List<VRouteElement> poppedVRouteElements;

  PoppingPopResult({required this.poppedVRouteElements});
}

/// Return from [VRouteElement.getPathFromPop] when the [VRouteElement] to pop has been found
/// but this [VRouteElement] won't pop
class ValidPopResult extends FoundPopResult {
  /// [extendedPath] should be deducted from the parent path, [VRouteElement.path]
  /// and the path parameters
  ///
  /// If [path] is null, the app will be put in the background on IOS and Android
  final String? path;

  /// The names of the [VRouteElement]s of the new path
  ///
  /// NOTE that this is not exact (because of [VNester]). To make this exact
  /// requires to rewrite the pop flow
  final List<String> names;

  /// List of every popping [VRouteElement]
  ///
  /// This should either be passed from [PoppingPopResult] or [ValidPopResult] but never changed
  final List<VRouteElement> poppedVRouteElements;

  ValidPopResult({
    required this.path,
    required this.poppedVRouteElements,
    required this.names,
  });
}

/// This is to be returned if the [VPopResult] is NOT valid
abstract class ErrorPopResult extends VPopResult implements Exception {}

/// Return from [VRouteElement.getPathFromPop] if the [VRouteElement] to pop was
/// NOT found (it is not this and not in subroutes)
class NotFoundPopResult extends ErrorPopResult {
  @override
  String toString() =>
      'The VRouteElement to pop was not found. Please open an issue, this should never happen.';
}

/// Return from [VRouteElement.getPathFromPop] if the [VRouteElement] to pop was
/// found but the deduced path is not valid due to missing path parameters
class PathParamsPopErrors extends ErrorPopResult implements FoundPopResult {
  final List<MissingPathParamsError> values;
  @override
  List<VRouteElement> poppedVRouteElements;

  PathParamsPopErrors({
    required this.values,
    required this.poppedVRouteElements,
  });

  @override
  String toString() =>
      'Could not pop because some path parameters where missing. \n'
          'Here are the possible path parameters that were expected and the missing ones:\n' +
      [
        for (var value in values)
          '  - Expected path parameters: ${value.pathParams}, missing ones: ${value.missingPathParams}'
      ].join('\n');
}

/// Return type of [VRouteElement.getPathFromName]
abstract class GetPathFromNameResult {}

class ValidNameResult extends GetPathFromNameResult {
  /// [extendedPath] should be deducted from the parent path, [VRouteElement.path] and the path parameters,
  ///  Note the it should be null if the path can not be deduced from the said parameters
  final String path;

  ValidNameResult({required this.path});
}

abstract class ErrorGetPathFromNameResult extends GetPathFromNameResult
    implements Error {
  String get error;

  @override
  String toString() => error;

  @override
  StackTrace? get stackTrace => StackTrace.current;
}

class NotFoundErrorNameResult extends ErrorGetPathFromNameResult {
  final String name;

  NotFoundErrorNameResult({required this.name});

  String get error => 'Could not find the VRouteElement named $name.';
}

class NullPathErrorNameResult extends ErrorGetPathFromNameResult {
  final String name;

  NullPathErrorNameResult({required this.name});

  String get error =>
      'The VRouteElement named $name as a null path but no parent VRouteElement with a path.\n'
      'No valid path can therefore be formed.';
}

abstract class PathParamsError implements Error {
  List<String> get pathParams;

  String get error;

  @override
  String toString() => error;

  @override
  StackTrace? get stackTrace => StackTrace.current;
}

class MissingPathParamsError extends PathParamsError {
  final List<String> missingPathParams;
  final List<String> pathParams;

  MissingPathParamsError(
      {required this.pathParams, required this.missingPathParams});

  String get error =>
      'Path parameters given: $pathParams, missing: $missingPathParams';
}

class OverlyPathParamsError extends PathParamsError {
  final List<String> expectedPathParams;
  final List<String> pathParams;

  OverlyPathParamsError(
      {required this.pathParams, required this.expectedPathParams});

  String get error =>
      'Path parameters given: $pathParams, expected: $expectedPathParams';
}

class PathParamsErrorsNameResult extends ErrorGetPathFromNameResult {
  final List<PathParamsError> values;
  final String name;

  PathParamsErrorsNameResult({required this.name, required this.values});

  @override
  String get error =>
      'Could not find value route for name $name because of path parameters. \n'
          'Here are the possible path parameters that were expected compared to what you gave:\n' +
      [for (var value in values) '  - ${value.error}'].join('\n');
}

/// Hold every information of the current route we are building
/// This is used is [VRouteElement.buildRoute] and should be passed down to the next
/// [VRouteElement.buildRoute] without modification.
///
/// The is used for two purposes:
///   1. Giving the needed information for [VRouteElement.buildRoute] to decide how/if it should
///       build its route
///   2. Holds information that are used to populate the [LocalVRouterData] attached to every
///   _  [VRouteElement]
class VPathRequestData {
  /// The previous url (which is actually the current one since when [VPathRequestData] is passed
  /// the url did not yet change from [VRouter] point of view)
  final String? previousUrl;

  /// The new uri. This is what should be used to determine the validity of the [VRouteElement]
  final Uri uri;

  /// The new history state, used to populate the [LocalVRouterData]
  final Map<String, String> historyState;

  /// A [BuildContext] with which we can access [RootVRouterData]
  final BuildContext rootVRouterContext;

  final List<NavigatorObserver> navigatorObserversToReportTo;

  VPathRequestData({
    required this.previousUrl,
    required this.uri,
    required this.historyState,
    required this.rootVRouterContext,
    required this.navigatorObserversToReportTo,
  });

  /// The path contained in the uri
  String get path => uri.path;

  /// The query parameters contained in the uri
  Map<String, String> get queryParameters => uri.queryParameters;

  /// The url corresponding to the uri
  String get url => uri.toString();

  /// The hash contained in the uri
  String get hash => Uri.decodeComponent(uri.fragment);
}

/// Part of [VRouteElement.buildRoute] that must be passed down but can be modified
abstract class VPathMatch {
  /// The local path is the one of the current VRouteElement
  /// If the path has path parameters, those should be replaced
  String? get localPath;

  /// The names of the [VRouteElement] in the path match
  List<String> get names;
}

class ValidVPathMatch extends VPathMatch {
  /// The remaining of the path after having remove the part of the path that this
  /// [VPath] has matched
  final String remainingPath;

  /// The path parameters of the valid [VRoute] which are
  ///   - Empty if no valid [VRoute] has been found
  ///   - This [VPath.pathParameters] if [VRouteElement.extendedPath] is absolute
  ///   - This [VPath.pathParameters] and the parent pathParameters if  [VRouteElement.extendedPath] is relative
  final Map<String, String> pathParameters;

  /// The local path is the one of the current VRouteElement
  /// If the path has path parameters, those should be replaced
  final String? localPath;

  @override
  final List<String> names;

  ValidVPathMatch({
    required this.remainingPath,
    required this.pathParameters,
    required this.localPath,
    required this.names,
  });
}

class InvalidVPathMatch extends VPathMatch implements Error {
  /// If there is no pathMatch but a VRouteElement needs a ValueKey
  /// use a constant path (which the user is likely to pop on)
  final String? localPath;

  @override
  final List<String> names;

  InvalidVPathMatch({required this.localPath, required this.names});

  @override
  StackTrace? get stackTrace => StackTrace.current;
}

/// The value of the new parentPath in [VRouteElement.getPathFromPop] and [VRouteElement.getPathFromName]
/// If this path is invalid:
///   - return [ValidGetNewParentPathResult(value: parentPathParameter)]
/// If this path starts with '/':
///   - Either the path parameters from [pathParameters] include those of this path and
///       we return the corresponding path
///   - Or we return [InvalidGetNewParentPathResult(missingPathParameters: this missing path parameters)]
/// If this path does not start with '/':
///   - If the parent path is invalid:
///   _  * [InvalidGetNewParentPathResult(missingPathParameters: parentPathParameterResult.missingPathParameters + this missingPathParameters)]
///   - If the parent path is not invalid:
///   _  * Either the path parameters from [pathParameters] include those of this path and
///             we return [ValidGetNewParentPathResult(the parent path + this path)]
///   _  * Or we return [InvalidGetNewParentPathResult(missingPathParameters: this missing path parameters)]
abstract class GetNewParentPathResult {}

/// Class to return when the parents have a valid path
class ValidParentPathResult extends GetNewParentPathResult {
  /// Null is a valid value, it just means that this path is null
  /// and the parent one was as well
  final String? path;

  /// The path parameters of the parent paths
  final Map<String, String> pathParameters;

  ValidParentPathResult({
    required this.path,
    required this.pathParameters,
  });
}

/// Return when the parent path does not match the current path
class PathParamsErrorNewParentPath extends GetNewParentPathResult {
  /// The missing path parameters that prevents us from creating the path
  final List<String> pathParameters;

  PathParamsErrorNewParentPath({required this.pathParameters});
}
