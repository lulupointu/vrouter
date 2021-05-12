import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:vrouter/src/core/root_vrouter_data.dart';
import 'package:vrouter/src/vrouter_core.dart';
import 'package:vrouter/src/wrappers/platform/platform.dart';

/// A page to put in [Navigator] pages
///
/// This is a normal page except that it allows for
/// custom transitions easily.
@Deprecated(
    '\nNaming changed to VDefaultPage.\nPlease use VDefaultPage instead of VBasePage')
abstract class VBasePage<T> extends Page<T> {
  /// The child of this page
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

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  VBasePage({
    required this.key,
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.name,
    this.buildTransition,
    this.transitionDuration,
    this.reverseTransitionDuration,
  }) : super(key: key);

  factory VBasePage.fromPlatform({
    required LocalKey key,
    required Widget child,
    String? name,
    Widget Function(Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child)?
        buildTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    bool fullscreenDialog = false,
  }) =>
      (!Platform.isWeb && Platform.isIOS)
          ? VCupertinoPage(
              key: key,
              child: child,
              name: name,
              buildTransition: buildTransition,
              transitionDuration: transitionDuration,
              reverseTransitionDuration: reverseTransitionDuration,
              fullscreenDialog: fullscreenDialog,
            )
          : VMaterialPage(
              key: key,
              child: child,
              name: name,
              buildTransition: buildTransition,
              transitionDuration: transitionDuration,
              reverseTransitionDuration: reverseTransitionDuration,
              fullscreenDialog: fullscreenDialog,
            ) as VBasePage<T>;
}

/// A page to put in [Navigator] pages
///
/// This is a normal page except that it allows for
/// custom transitions easily.
abstract class VDefaultPage<T> extends Page<T> {
  /// The child of this page
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

  /// {@macro flutter.widgets.ModalRoute.maintainState}
  final bool maintainState;

  /// {@macro flutter.widgets.PageRoute.fullscreenDialog}
  final bool fullscreenDialog;

  VDefaultPage({
    required this.key,
    required this.child,
    this.maintainState = true,
    this.fullscreenDialog = false,
    this.name,
    this.buildTransition,
    this.transitionDuration,
    this.reverseTransitionDuration,
  }) : super(key: key);

  factory VDefaultPage.fromPlatform({
    required LocalKey key,
    required Widget child,
    String? name,
    Widget Function(Animation<double> animation,
            Animation<double> secondaryAnimation, Widget child)?
        buildTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
    bool fullscreenDialog = false,
  }) =>
      (!Platform.isWeb && Platform.isIOS)
          ? VCupertinoPage<T>(
              key: key,
              child: child,
              name: name,
              buildTransition: buildTransition,
              transitionDuration: transitionDuration,
              reverseTransitionDuration: reverseTransitionDuration,
              fullscreenDialog: fullscreenDialog,
            )
          : VMaterialPage<T>(
              key: key,
              child: child,
              name: name,
              buildTransition: buildTransition,
              transitionDuration: transitionDuration,
              reverseTransitionDuration: reverseTransitionDuration,
              fullscreenDialog: fullscreenDialog,
            ) as VDefaultPage<T>;
}

/// A page to put in [Navigator] pages
///
/// This is a normal material page except that it allows for
/// custom transitions easily.
class VMaterialPage<T> extends MaterialPage<T>
    implements VBasePage<T>, VDefaultPage<T> {
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
    } else if (RootVRouterData.of(context).defaultPageBuildTransition !=
        null) {
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

/// A page to put in [Navigator] pages
///
/// This is a normal cupertino page except that it allows for
/// custom transitions easily.
class VCupertinoPage<T> extends CupertinoPage<T>
    implements VBasePage<T>, VDefaultPage<T> {
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

  VCupertinoPage({
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
    } else if (RootVRouterData.of(context).defaultPageBuildTransition !=
        null) {
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

/// Helper to create a PageRoute which displays the desired animation
class VPageRoute<T> extends PageRoute<T> {
  @override
  final Duration transitionDuration;
  @override
  final Duration reverseTransitionDuration;
  final Widget Function(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) customTransition;

  VPageRoute({
    required VBasePage<T> page,
    required this.customTransition,
    Duration? transitionDuration,
    Duration? reverseTransitionDuration,
  })  : transitionDuration = transitionDuration ?? Duration(milliseconds: 300),
        reverseTransitionDuration = reverseTransitionDuration ??
            (transitionDuration ?? Duration(milliseconds: 300)),
        super(settings: page) {
    assert(opaque);
  }

  VBasePage<T> get _page => settings as VBasePage<T>;

  @override
  bool get maintainState => _page.maintainState;

  @override
  bool get fullscreenDialog => _page.fullscreenDialog;

  @override
  String get debugLabel => '${super.debugLabel}(${_page.name})';

  @override
  Color get barrierColor => Colors.transparent;

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
