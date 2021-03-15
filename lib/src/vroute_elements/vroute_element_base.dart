part of '../main.dart';

@immutable
abstract class VRouteElement {
  /// A list of subroutes composed of any type of [VRouteElement]
  List<VRouteElement> get subroutes;

  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required String? parentRemainingPath,
    required Map<String, String> parentPathParameters,
  });

  /// This function takes a name and tries to find the path corresponding to
  /// the route matching this name
  ///
  /// The deeper nested the route the better
  /// The given path parameters have to include at least every path parameters of the final path
  String? getPathFromName(
    String nameToMatch, {
    required Map<String, String> pathParameters,
    required String? parentPath,
    required Map<String, String> remainingPathParameters,
  }) {
    // Check if any subroute matches the name
    for (var vRouteElement in subroutes) {
      String? childPathFromName = vRouteElement.getPathFromName(
        nameToMatch,
        pathParameters: pathParameters,
        parentPath: parentPath,
        remainingPathParameters: remainingPathParameters,
      );
      if (childPathFromName != null) {
        return childPathFromName;
      }
    }

    // Else we return null
    return null;
  }

  /// [GetPathFromPopResult.didPop] is true if this [VRouteElement] popped
  /// [GetPathFromPopResult.path] is null if this path can't be the right one according to
  ///                                                                     the path parameters
  /// [GetPathFromPopResult] is null when this [VRouteElement] does not pop AND none of
  ///                                                                     its subroutes popped
  GetPathFromPopResult? getPathFromPop(
    VRouteElement elementToPop, {
    required Map<String, String> pathParameters,
    required String? parentPath,
  }) {
    // Try to pop from the subroutes
    for (var vRouteElement in subroutes) {
      final childPopResult = vRouteElement.getPathFromPop(
        elementToPop,
        pathParameters: pathParameters,
        parentPath: parentPath,
      );
      if (childPopResult != null) {
        return childPopResult;
      }
    }

    // If none of the subroutes popped and this did not pop, return a null result
    return null;
  }

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
  Future<void> Function(VRedirector vRedirector) get beforeEnter =>
      _voidBeforeEnter;

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
  ///   * [VNavigationGuard.beforeUpdate] for widget level beforeUpdate
  ///   * [VRedirector] to known how to redirect and have access to route information
  Future<void> Function(VRedirector vRedirector) get beforeUpdate =>
      _voidBeforeUpdate;

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
  Future<void> Function(
    VRedirector? vRedirector,
    void Function(Map<String, String> state) saveHistoryState,
  ) get beforeLeave => _voidBeforeLeave;

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
  ///   * [VNavigationGuard.afterEnter] for widget level afterEnter
  void Function(BuildContext context, String? from, String to) get afterEnter =>
      _voidAfterEnter;

  /// This is called after the url and the historyState are updated and this [VRouteElement]
  /// was in the previous route and is in the new route
  /// You can't prevent the navigation anymore
  /// You can get the new route parameters, and queryParameters
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VNavigationGuard.afterUpdate] for widget level afterUpdate
  void Function(BuildContext context, String? from, String to)
      get afterUpdate => _voidAfterUpdate;

  /// Called when a pop event occurs
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
  ///   * [VRouter.onPop] for router level onPop
  ///   * [VNavigationGuard.onPop] for widget level onPop
  ///   * [VRedirector] to known how to redirect and have access to route information
  Future<void> Function(VRedirector vRedirector) get onPop => _voidOnPop;

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
  ///   * [VNavigationGuard.onSystemPop] for widget level onSystemPop
  ///   * [VRedirector] to known how to redirect and have access to route information
  Future<void> Function(VRedirector vRedirector) get onSystemPop =>
      _voidOnSystemPop;

  /// Default function for [VRouteElement.beforeEnter]
  /// Basically does nothing
  static Future<void> _voidBeforeEnter(VRedirector vRedirector) async {}

  /// Default function for [VRouteElement.beforeUpdate]
  /// Basically does nothing
  static Future<void> _voidBeforeUpdate(VRedirector vRedirector) async {}

  /// Default function for [VRouteElement.beforeLeave]
  /// Basically does nothing
  static Future<void> _voidBeforeLeave(
    VRedirector? vRedirector,
    void Function(Map<String, String> state) saveHistoryState,
  ) async {}

  /// Default function for [VRouteElement.afterEnter]
  /// Basically does nothing
  static void _voidAfterEnter(BuildContext context, String? from, String to) {}

  /// Default function for [VRouteElement.afterUpdate]
  /// Basically does nothing
  static void _voidAfterUpdate(BuildContext context, String? from, String to) {}

  /// Default function for [VRouteElement.onPop]
  /// Basically does nothing
  static Future<void> _voidOnPop(VRedirector vRedirector) async {}

  /// Default function for [VRouteElement.pnSystemPop]
  /// Basically does nothing
  static Future<void> _voidOnSystemPop(VRedirector vRedirector) async {}
}

/// Return type of [VRouteElement.getPathFromPop]
///
/// [didPop] should be true if this [VRouteElement] is to be popped
/// [path] should be deducted from the parent path, [VRouteElement.path] and the path parameters,
///   Note the it should be null if the path can not be deduced from the said parameters
class GetPathFromPopResult {
  final String? path;
  final bool didPop;

  GetPathFromPopResult({
    required this.path,
    required this.didPop,
  });
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
  final String? previousUrl;
  final Uri uri;
  final Map<String, String> historyState;
  final BuildContext rootVRouterContext;

  VPathRequestData({
    required this.previousUrl,
    required this.uri,
    required this.historyState,
    required this.rootVRouterContext,
  });

  String get path => uri.path;

  Map<String, String> get queryParameters => uri.queryParameters;

  String get url => uri.toString();
}

/// [VRouteElementNode] is used to represent the current route configuration as a tree
class VRouteElementNode {
  /// The [VRouteElementNode] containing the [VRouteElement] which is the current nested route
  /// to be valid, if any
  ///
  /// The is used be all types of [VNestedPage]
  final VRouteElementNode? nestedVRouteElementNode;

  /// The [VRouteElementNode] containing the [VRouteElement] which is the current sub route
  /// to be valid, if any
  final VRouteElementNode? subVRouteElementNode;

  /// The [VRouteElement] attached to this node
  final VRouteElement vRouteElement;

  VRouteElementNode(
    this.vRouteElement, {
    this.nestedVRouteElementNode,
    this.subVRouteElementNode,
  });

  /// Finding the element to pop for a [VRouteElementNode] means finding which one is at the
  /// end of the chain of subVRouteElementNode (if none then this should be popped)
  VRouteElement getVRouteElementToPop() {
    if (subVRouteElementNode != null) {
      return subVRouteElementNode!.getVRouteElementToPop();
    }
    return vRouteElement;
  }

  /// This function will search this node and the nested and sub nodes to try to find the node
  /// that hosts [vRouteElement]
  VRouteElementNode? getChildVRouteElementNode({
    required VRouteElement vRouteElement,
  }) {
    // If this VRouteElementNode contains the given VRouteElement, return this
    if (vRouteElement == this.vRouteElement) {
      return this;
    }

    // Search if the VRouteElementNode containing the VRouteElement is in the nestedVRouteElementNode
    if (nestedVRouteElementNode != null) {
      VRouteElementNode? vRouteElementNode = nestedVRouteElementNode!
          .getChildVRouteElementNode(vRouteElement: vRouteElement);
      if (vRouteElementNode != null) {
        return vRouteElementNode;
      }
    }

    // Search if the VRouteElementNode containing the VRouteElement is in the subVRouteElementNode
    if (subVRouteElementNode != null) {
      VRouteElementNode? vRouteElementNode = subVRouteElementNode!
          .getChildVRouteElementNode(vRouteElement: vRouteElement);
      if (vRouteElementNode != null) {
        return vRouteElementNode;
      }
    }

    // If the VRouteElement was not find anywhere, return null
    return null;
  }
}
