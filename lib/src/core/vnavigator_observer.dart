import 'package:flutter/material.dart';
import 'package:vrouter/src/core/vrouter_delegate.dart';
import 'package:vrouter/vrouter.dart';

/// This [NavigatorObserver] is used to observe the events caused by the Navigator 1.0 API
///
/// It helps us determine what to do when pop is called
class VNavigatorObserver extends NavigatorObserver {
  /// Whether or not a route was pushed using the Navigator 1.0 API
  ///
  /// This is useful when calling pop or systemPop. Since when such a route exists,
  /// it should be popped and [VRouterDelegate.pop] should not.
  bool get hasNavigator1Pushed {
    return (navigator == null)
        ? false
        : _navigatorEntriesCount != (navigator!.widget.pages.length);
  }

  /// How much time Navigator.push was used in the context of this [navigator]
  ///
  /// This is useful to know how much time to call pop in order to pop every navigator 1.0 push
  int get navigator1PushCount {
    return (navigator != null && hasNavigator1Pushed)
        ? _navigatorEntriesCount - navigator!.widget.pages.length
        : 0;
  }

  @override
  void didPush(Route route, Route? previousRoute) => _navigatorEntriesCount++;

  @override
  void didPop(Route route, Route? previousRoute) => _navigatorEntriesCount--;

  @override
  void didRemove(Route route, Route? previousRoute) => _navigatorEntriesCount--;

  /// The number of entries in the associated navigator
  int _navigatorEntriesCount = 0;
}

/// Build a [VNavigatorObserver] to provide to a [Navigator]
///
///
/// The create [VNavigatorObserver] can be accessed:
///   - AFTER build using [controller.vNavigationObserver]
///   - DURING and AFTER build using [VNavigatorObserverBuilder.of(context).vNavigationObserver]
class VNavigatorObserverBuilder extends StatefulWidget {
  /// A controller which can be used to access [VNavigatorObserver] without
  /// context after this widget has been built
  final VNavigatorObserverController controller;

  /// The widget to put bellow this one
  final Widget child;

  /// The key of the navigator to be observed
  ///
  ///
  /// The key MUST be given to the navigator as well
  final GlobalKey<NavigatorState> navigatorKey;

  const VNavigatorObserverBuilder({
    Key? key,
    required this.controller,
    required this.child,
    required this.navigatorKey,
  }) : super(key: key);

  @override
  VNavigatorObserverBuilderState createState() =>
      VNavigatorObserverBuilderState();

  // This is not the most effective but good enough since this should be placed just
  // above a [Navigator]
  static VNavigatorObserverBuilderState of(BuildContext context) {
    final VNavigatorObserverBuilderState? result =
        context.findAncestorStateOfType<VNavigatorObserverBuilderState>();
    assert(result != null, 'No VNavigatorObserverBuilderData found in context');
    return result!;
  }
}

/// [State] of [VNavigatorObserverBuilder]
class VNavigatorObserverBuilderState extends State<VNavigatorObserverBuilder> {
  /// The [VNavigatorObserver] to give to the [Navigator]
  ///
  ///
  /// This is created in a [State] rather than in the widget so that it does not
  /// get rebuilt
  late VNavigatorObserver _vNavigatorObserver;

  /// A helpful method to get the controller associated with
  /// [VNavigatorObserverBuilder]
  VNavigatorObserverController get controller => widget.controller;

  @override
  void initState() {
    super.initState();

    // Create the initial observer which might later change
    // in [didUpdateWidget]
    _vNavigatorObserver = VNavigatorObserver();

    // Update the controller with the new observer
    widget.controller.vNavigationObserver = _vNavigatorObserver;
  }

  @override
  void didUpdateWidget(covariant VNavigatorObserverBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the key changed, the Navigator changed, so create
    // a new observer
    if (oldWidget.navigatorKey != widget.navigatorKey) {
      _vNavigatorObserver = VNavigatorObserver();

      // Update the controller with the new observer
      widget.controller.vNavigationObserver = _vNavigatorObserver;
    }
  }

  @override
  Widget build(BuildContext context) {

    return widget.child;
  }
}

class VNavigatorObserverController {
  VNavigatorObserver? vNavigationObserver;
}
