import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:vrouter/src/helpers/vrouter_delegate_helper.dart';

/// This is a helper to create a router in which we nest
/// a [VRouterDelegateHelper]
class VRouterHelper extends StatelessWidget {
  /// The pages that will be displayed in the [VRouterDelegateHelper]
  /// Navigator
  final List<Page> pages;

  /// The key of the [VRouterDelegateHelper] navigator
  final GlobalKey<NavigatorState>? navigatorKey;

  /// The observers of the [VRouterDelegateHelper] navigator
  final List<NavigatorObserver>? observers;

  /// The [BackButtonDispatcher] of the router
  final BackButtonDispatcher? backButtonDispatcher;

  /// The function that will be called when [Navigator.pop]
  /// is called in a page contained in this router
  final bool Function(Route<dynamic>, dynamic)? onPopPage;

  /// The function that will be called when a system pop
  /// (hardware back button in android) is called in a page
  /// contained in this router
  final Future<bool> Function()? onSystemPopPage;

  const VRouterHelper({
    Key? key,
    required this.pages,
    this.navigatorKey,
    this.observers,
    this.backButtonDispatcher,
    this.onPopPage,
    this.onSystemPopPage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Router(
      backButtonDispatcher: backButtonDispatcher,
      routerDelegate: VRouterDelegateHelper(
        pages: pages,
        navigatorKey: navigatorKey,
        observers: observers,
        onPopPage: onPopPage,
        onSystemPopPage: onSystemPopPage,
      ),
    );
  }
}
