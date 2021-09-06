import 'package:flutter/widgets.dart';
import 'package:vrouter/src/vrouter_core.dart';
import 'package:vrouter/src/vrouter_vroute_elements.dart';
import 'package:vrouter/src/vrouter_widgets.dart';

/// [VGuard] is a [VRouteElement] which is used to control navigation changes
///
/// Use [beforeLeave] or [beforeUpdate] to get navigation changes before
/// they take place. These methods will give you a [VRedirector] that you can use to:
///   - know about the navigation changes [VRedirector.previousVRouterData] and [VRedirector.newVRouterData]
///   - redirect using [VRedirector.to] or stop the navigation using [VRedirector.stopRedirection]
///
/// Use [afterEnter] or [afterUpdate] to get notification changes after they happened. At this point
/// you can use [VRouter.of(context)] to get any information about the new route
///
/// See also [VGuard] for a [VRouteElement] which control navigation changes
class VWidgetGuard extends StatefulWidget {
  /// The child of this widget
  final Widget child;

  /// Called when the route changes and the [VRouteElement]
  /// associated to this [VWidgetGuard] is in the previous route
  /// but not in the new one
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// Use [newVRouteData] if you want information on the new route but be
  /// careful, on the web newVRouteData is null when a user types a url manually
  ///
  /// Use [newVRouteData] if you want information on the new route but be
  /// careful, on the web newVRouteData is null when a user types a url manually
  ///
  /// [saveHistoryState] can be used to save a history state before leaving
  /// This history state will be restored if the user uses the back button
  /// You will find the saved history state in the [VRouteElementData] using
  /// [VRouteElementData.of(context).historyState]
  /// WARNING: Since the history state is saved in [VRouteElementData], if you have
  /// multiple VWidgetGuards associated to the same [VRouteElement], only one
  /// should use [saveHistoryState].
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.beforeLeave] for global level beforeLeave
  ///   * [VRouteElement.beforeLeave] for route level beforeLeave
  ///   * [VRedirector] to known how to redirect and have access to route information
  final Future<void> Function(
    VRedirector? vRedirector,
    void Function(Map<String, String> state) saveHistoryState,
  ) beforeLeave;

  /// This is called before the url is updated, if this [VRouteElement] is in the previous route
  /// AND in the new route
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouter methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.beforeEnter] for global level beforeEnter
  ///   * [VRedirector] to known how to redirect and have access to route information
  final Future<void> Function(VRedirector vRedirector) beforeUpdate;

  /// Called when the url changes and this [VWidgetGuard] was NOT part
  /// of the previous route.
  ///
  /// This is called after the url and the state of you app has change
  /// so any data in [VRouteElementData] is up to date
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.afterEnter] for global level afterEnter
  ///   * [VRouteElement.afterEnter] for route level afterEnter
  final void Function(BuildContext context, String? from, String to) afterEnter;

  /// Called when the url changes and this [VWidgetGuard] was already part
  /// of the previous route.
  ///
  /// This is called after the url and the state of you app has change
  /// so any data in [VRouteElementData] is up to date
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  final void Function(BuildContext context, String? from, String to)
      afterUpdate;

  /// Called when a pop event occurs.
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
  ///   * [VRouter.onPop] for global level onPop
  ///   * [VRouteElement.onPop] for route level onPop
  ///   * [VRedirector] to known how to redirect and have access to route information
  final Future<void> Function(VRedirector vRedirector) onPop;

  /// Called when a system pop event occurs.
  /// This happens on android when the system back button is pressed
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
  ///   * [VRouter.onSystemPop] for global level onSystemPop
  ///   * [VRouteElement.onSystemPop] for route level onSystemPop
  ///   * [VRedirector] to known how to redirect and have access to route information
  final Future<void> Function(VRedirector vRedirector) onSystemPop;

  const VWidgetGuard({
    Key? key,
    this.afterEnter = VoidVGuard.voidAfterEnter,
    this.afterUpdate = VoidVGuard.voidAfterUpdate,
    this.beforeUpdate = VoidVGuard.voidBeforeUpdate,
    this.beforeLeave = VoidVGuard.voidBeforeLeave,
    this.onPop = VoidVPopHandler.voidOnPop,
    this.onSystemPop = VoidVPopHandler.voidOnSystemPop,
    required this.child,
  }) : super(key: key);

  @override
  _VWidgetGuardState createState() => _VWidgetGuardState();
}

class _VWidgetGuardState extends State<VWidgetGuard> {
  @override
  void didChangeDependencies() {
    VWidgetGuardMessage(vWidgetGuardState: this, localContext: context)
        .dispatch(context);
    super.didChangeDependencies();
  }

  // This is used to try to support hot restart
  // However it seems that even with this, two hot reloads
  // are necessary when changes to VWidgetGuard are made
  @override
  void reassemble() {
    VWidgetGuardMessage(vWidgetGuardState: this, localContext: context)
        .dispatch(context);
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    VRouter.of(
        context); // Makes didChangeDependencies be called when VRouterData changes
    return widget.child;
  }
}

/// This message is a notification that each [VWidgetGuard] sends
/// and received by their associated [VRouteElementWidget] which will in turn
/// send a [VWidgetGuardRootMessage] for the [VRouter]
class VWidgetGuardMessage extends Notification {
  final _VWidgetGuardState vWidgetGuardState;
  final BuildContext localContext;

  VWidgetGuardMessage(
      {required this.vWidgetGuardState, required this.localContext});
}

class VWidgetGuardMessageRoot extends Notification {
  final _VWidgetGuardState vWidgetGuardState;
  final BuildContext localContext;
  final VRouteElement associatedVRouteElement;

  VWidgetGuardMessageRoot({
    required this.vWidgetGuardState,
    required this.localContext,
    required this.associatedVRouteElement,
  });

  /// The VWidgetGuard associated with the [_VWidgetGuardState]
  VWidgetGuard get vWidgetGuard => vWidgetGuardState.widget;
}
