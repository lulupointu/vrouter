import 'package:flutter/material.dart';
import 'package:vrouter/src/helpers/vpage/vdefault_page.dart';
import 'package:vrouter/src/helpers/vpage/vpage_route.dart';
import 'package:vrouter/src/vrouter_core.dart';

/// A page to put in [Navigator] pages
///
/// This is a normal material page except that it allows for
/// custom transitions easily.
class VMaterialPage<T> extends MaterialPage<T> implements VDefaultPage<T> {
  /// The child of this page
  @override
  final Widget child;

  /// The name of this page
  @override
  final String? name;

  /// The key of this page
  @override
  final LocalKey key;

  /// The duration of the transition which happens when this page
  /// is put in the widget tree
  final Duration? transitionDuration;

  /// The duration of the transition which happens when this page
  /// is removed from the widget tree
  final Duration? reverseTransitionDuration;

  /// A function to build the transition to or from this route
  ///
  /// [child] is the child of the page
  ///
  /// Example of a fade transition:
  /// buildTransition: (animation, _, child) {
  ///    return FadeTransition(opacity: animation, child: child);
  /// }
  ///
  /// If this is null, the default transition is the one of the [VRouter]
  /// If the one of the [VRouter] is also null, the default transition is
  /// the one of a [MaterialPage]
  final Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? buildTransition;

  @override
  final bool fullscreenDialog;

  VMaterialPage({
    required this.key,
    required this.child,
    this.name,
    this.buildTransition,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.fullscreenDialog = false,
  }) : super(key: key, child: child, fullscreenDialog: fullscreenDialog);

  @override
  Route<T> createRoute(BuildContext context) {
    // If any transition was given, use it
    if (buildTransition != null) {
      return VPageRoute<T>(
        page: this,
        customTransition: (_, Animation<double> animation,
                Animation<double> secondaryAnimation, Widget child) =>
            buildTransition!(
          animation,
          secondaryAnimation,
          child,
        ),
        transitionDuration: transitionDuration,
        reverseTransitionDuration: reverseTransitionDuration,
      );
    } else if (RootVRouterData.of(context).defaultPageBuildTransition != null) {
      // Else try to use the router transition
      return VPageRoute<T>(
        page: this,
        customTransition: (_, Animation<double> animation,
                Animation<double> secondaryAnimation, Widget child) =>
            RootVRouterData.of(context).defaultPageBuildTransition!(
          animation,
          secondaryAnimation,
          child,
        ),
        transitionDuration:
            RootVRouterData.of(context).defaultPageTransitionDuration,
        reverseTransitionDuration:
            RootVRouterData.of(context).defaultPageReverseTransitionDuration,
      );
    }

    // Default is parent animation (ie MaterialPageRoute animation)
    return super.createRoute(context);
  }
}
