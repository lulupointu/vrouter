import 'package:flutter/widgets.dart';
import 'package:vrouter/src/helpers/vpage/vcupertino_page.dart';
import 'package:vrouter/src/helpers/vpage/vmaterial_page.dart';
import 'package:vrouter/src/wrappers/platform/platform.dart';

/// A page to put in [Navigator] pages
///
/// This is a normal page except that it allows for
/// custom transitions easily.
@Deprecated(
    '\nNaming changed to VDefaultPage.\nPlease use VDefaultPage instead of VBasePage')
typedef VBasePage<T> = VDefaultPage<T>;

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
      Platform.isIOS
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
            );
}
