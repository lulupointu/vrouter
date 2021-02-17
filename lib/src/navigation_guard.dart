part of 'main.dart';

/// Widget which allows you to handle navigation event directly in
/// you widgets.
/// Any [VNavigationGuard] is associated to the [VRouteElement] above it
/// in the route tree.
class VNavigationGuard extends StatefulWidget {
  /// The child of this widget
  final Widget child;

  /// Called when the route changes and the [VRouteElement]
  /// associated to this [VNavigationGuard] is in the previous route
  /// but not in the new one
  ///
  /// [context] can be used to access the [VRouteElementData] associated
  /// to this [VNavigationGuard]
  ///
  /// [saveHistoryState] can be used to save a history state before leaving
  /// This history state will be restored if the user uses the back button
  /// You will find the saved history state in the [VRouteElementData] using
  /// [VRouteElementData.of(context).historyState]
  /// WARNING: Since the history state is saved in [VRouteElementData], if you have
  /// multiple VNavigationGuards associated to the same [VRouteElement], only one
  /// should use [saveHistoryState].
  ///
  /// return false if you want to stop the navigation from happening
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.beforeLeave] for global level beforeLeave
  ///   * [VRouteElement.beforeLeave] for route level beforeLeave
  final Future<bool> Function(BuildContext context, String from, String to, VRouteData newVRouteData,
      void Function(String state) saveHistoryState) beforeLeave;

  /// Called when the url changes and this [VNavigationGuard] was NOT part
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
  final void Function(BuildContext context, String from, String to) afterEnter;

  /// Called when the url changes and this [VNavigationGuard] was already part
  /// of the previous route.
  ///
  /// This is called after the url and the state of you app has change
  /// so any data in [VRouteElementData] is up to date
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  final void Function(BuildContext context, String from, String to) afterUpdate;

  /// Called when a pop event occurs.
  /// A pop event can be called programmatically (with
  /// [VRouterData.of(context).pop()]) or by other widgets
  /// such as the appBar back button
  ///
  /// return false to stop the pop event
  ///
  /// Note that you should consider the pop cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Pop%20Events/onPop]
  ///
  /// Also see:
  ///   * [VRouter.onPop] for global level onPop
  ///   * [VRouteElement.onPop] for route level onPop
  ///   * [VRouterState._defaultPop] for the default onPop
  final Future<bool> Function(BuildContext context) onPop;

  /// Called when a system pop event occurs. This happens on android
  /// when the system back button is pressed
  ///
  /// return false to stop the pop event
  ///
  /// Note that you should consider the systemPop cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Pop%20Events/onSystemPop]
  ///
  /// Also see:
  ///   * [VRouter.onSystemPop] for global level onSystemPop
  ///   * [VRouteElement.onSystemPop] for route level onSystemPop
  final Future<bool> Function(BuildContext context) onSystemPop;

  const VNavigationGuard({
    Key key,
    this.afterEnter,
    this.beforeLeave,
    this.afterUpdate,
    this.onPop,
    this.onSystemPop,
    @required this.child,
  }) : super(key: key);

  @override
  _VNavigationGuardState createState() => _VNavigationGuardState();
}

class _VNavigationGuardState extends State<VNavigationGuard> {
  @override
  void initState() {
    VNavigationGuardMessage(vNavigationGuard: widget, localContext: context)
        .dispatch(context);
    super.initState();
    if (widget.afterEnter != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.afterEnter(context, VRouterData.of(context).previousUrl,
            VRouterData.of(context).url);
      });
    }
  }

  // This is used to try to support hot restart
  // However it seems that even with this, two hot reloads
  // are necessary when changes to VNavigationGuard are made
  @override
  void reassemble() {
    VNavigationGuardMessage(vNavigationGuard: widget, localContext: context)
        .dispatch(context);
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// This message is a notification that each [VNavigationGuard] sends
/// and received by their associated [VRouteElement] to air them
class VNavigationGuardMessage extends Notification {
  final VNavigationGuard vNavigationGuard;
  final BuildContext localContext;

  VNavigationGuardMessage(
      {@required this.vNavigationGuard, @required this.localContext});
}
