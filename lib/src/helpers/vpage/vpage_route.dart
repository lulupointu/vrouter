import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vrouter/src/helpers/vpage/vdefault_page.dart';

/// Helper to create a PageRoute which displays the desired animation
class VPageRoute<T> extends PageRoute<T> {
  @override
  final Duration transitionDuration;
  @override
  final Duration reverseTransitionDuration;
  final Widget Function(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) customTransition;

  VPageRoute({
    required VDefaultPage<T> page,
    required this.customTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  })  : transitionDuration = transitionDuration ?? Duration(milliseconds: 300),
        reverseTransitionDuration = reverseTransitionDuration ??
            (transitionDuration ?? Duration(milliseconds: 300)),
        super(settings: page) {
    assert(opaque);
  }

  VDefaultPage<T> get _page => settings as VDefaultPage<T>;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  Color get barrierColor => const Color(0x00000000);

  @override
  String get barrierLabel => settings.name ?? '';

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    // Don't perform outgoing animation if the next route is a fullscreen dialog.
    return (nextRoute is MaterialRouteTransitionMixin &&
            !nextRoute.fullscreenDialog) ||
        (nextRoute is CupertinoRouteTransitionMixin &&
            !nextRoute.fullscreenDialog);
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return _page.child;
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return customTransition(context, animation, secondaryAnimation, child);
  }
}
