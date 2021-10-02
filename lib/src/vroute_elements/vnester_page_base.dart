import 'package:flutter/widgets.dart';
import 'package:vrouter/src/core/navigator_extension.dart';
import 'package:vrouter/src/core/vpop_data.dart';
import 'package:vrouter/src/helpers/empty_page.dart';
import 'package:vrouter/src/helpers/vrouter_helper.dart';
import 'package:vrouter/src/vroute_elements/void_vguard.dart';
import 'package:vrouter/src/vroute_elements/void_vpop_handler.dart';
import 'package:vrouter/src/vroute_elements/vroute_element_with_name.dart';
import 'package:vrouter/src/vrouter_core.dart';
import 'package:vrouter/src/vrouter_widgets.dart';

/// A [VRouteElement] similar to [VNester] but which allows you to specify your own page
/// thanks to [pageBuilder]
class VNesterPageBase extends VRouteElement
    with VoidVGuard, VoidVPopHandler, VRouteElementWithName {
  /// A list of [VRouteElement] which widget will be accessible in [widgetBuilder]
  final List<VRouteElement> nestedRoutes;

  /// The list of possible routes to stack on top of this [VRouteElement]
  final List<VRouteElement> stackedRoutes;

  /// A function which creates the [VRouteElement._rootVRouter] associated to this [VRouteElement]
  ///
  /// [child] will be the [VRouteElement._rootVRouter] of the matched [VRouteElement] in
  /// [nestedRoutes]
  final Widget Function(Widget child) widgetBuilder;

  /// A LocalKey that will be given to the page which contains the given [_rootVRouter]
  ///
  /// This key mostly controls the page animation. If a page remains the same but the key is changes,
  /// the page gets animated
  /// The key is by default the value of the current [path] (or [aliases]) with
  /// the path parameters replaced
  ///
  /// Do provide a constant [key] if you don't want this page to animate even if [path] or
  /// [aliases] path parameters change
  final LocalKey? key;

  /// A name for the route which will allow you to easily navigate to it
  /// using [VRouter.of(context).pushNamed]
  ///
  /// Note that [name] should be unique w.r.t every [VRouteElement]
  final String? name;

  /// Function which returns a page that will wrap [widget]
  ///   - key and name should be given to your [Page]
  ///   - child should be placed as the last child in [Route]
  final Page Function(
      LocalKey key, Widget child, String? name, VRouterData state) pageBuilder;

  /// A key for the nested navigator
  /// It is created automatically
  ///
  /// Using this is useful if you create two different [VNesterPageBase] that should
  /// actually be the same. This happens if you use two different [VRouteElementBuilder]
  /// to represent two different routes which should share a common [VNesterPageBase]
  late final GlobalKey<NavigatorState> navigatorKey;

  VNesterPageBase({
    required this.nestedRoutes,
    required this.widgetBuilder,
    required this.pageBuilder,
    this.stackedRoutes = const [],
    this.key,
    this.name,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : assert(nestedRoutes.isNotEmpty,
            'The nestedRoutes of a VNester should not be empty, otherwise it can\'t nest') {
    this.navigatorKey = navigatorKey ??
        GlobalKey<NavigatorState>(
          debugLabel: '$runtimeType of name $name and key $key navigatorKey',
        );
  }

  /// Provides a [state] from which to access [VRouter] data in [widgetBuilder]
  VNesterPageBase.builder({
    required List<VRouteElement> nestedRoutes,
    required Widget Function(
            BuildContext context, VRouterData state, Widget child)
        widgetBuilder,
    required Page Function(LocalKey key, Widget child, String? name)
        pageBuilder,
    List<VRouteElement> stackedRoutes = const [],
    LocalKey? key,
    String? name,
    GlobalKey<NavigatorState>? navigatorKey,
  }) : this(
          nestedRoutes: nestedRoutes,
          widgetBuilder: (child) => VRouterDataBuilder(
            builder: (context, state) => widgetBuilder(context, state, child),
          ),
          pageBuilder: (key, child, name, _) => pageBuilder(key, child, name),
          stackedRoutes: stackedRoutes,
          key: key,
          name: name,
          navigatorKey: navigatorKey,
        );

  /// A hero controller for the navigator
  /// It is created automatically
  final HeroController heroController = HeroController();

  @override
  VRoute? buildRoute(
    VPathRequestData vPathRequestData, {
    required VPathMatch parentVPathMatch,
    required bool parentCanPop,
  }) {
    // Set localPath to null since a VNesterPageBase marks a limit between localPaths
    VPathMatch newVPathMatch = (parentVPathMatch is ValidVPathMatch)
        ? ValidVPathMatch(
            remainingPath: parentVPathMatch.remainingPath,
            pathParameters: parentVPathMatch.pathParameters,
            localPath: null,
            names: parentVPathMatch.names + [if (name != null) name!],
          )
        : InvalidVPathMatch(
            localPath: null,
            names: parentVPathMatch.names + [if (name != null) name!],
          );

    // Try to find valid VRoute from nestedRoutes
    VRoute? nestedRouteVRoute;
    for (var vRouteElement in nestedRoutes) {
      nestedRouteVRoute = vRouteElement.buildRoute(
        vPathRequestData,
        parentVPathMatch: newVPathMatch,
        parentCanPop: parentCanPop,
      );
      if (nestedRouteVRoute != null) {
        break;
      }
    }

    // If no child route match, this is not a match
    if (nestedRouteVRoute == null) {
      return null;
    }

    // Else also try to match stackedRoutes
    VRoute? stackedRouteVRoute;
    for (var vRouteElement in stackedRoutes) {
      stackedRouteVRoute = vRouteElement.buildRoute(
        vPathRequestData,
        parentVPathMatch: newVPathMatch,
        parentCanPop: true,
      );
      if (stackedRouteVRoute != null) {
        break;
      }
    }

    final vRouteElementNode = VRouteElementNode(
      this,
      localPath: null,
      nestedVRouteElementNode: nestedRouteVRoute.vRouteElementNode,
      stackedVRouteElementNode: stackedRouteVRoute?.vRouteElementNode,
    );

    final pathParameters = {
      ...nestedRouteVRoute.pathParameters,
      ...stackedRouteVRoute?.pathParameters ?? {},
    };

    final names = <String>[
      ...nestedRouteVRoute.names,
      ...stackedRouteVRoute?.names ?? [],
    ].toSet().toList();

    return VRoute(
      vRouteElementNode: vRouteElementNode,
      pages: [
        pageBuilder(
          key ?? ValueKey(parentVPathMatch.localPath),
          Builder(
            builder: (context) => LocalVRouterData(
              child: NotificationListener<VWidgetGuardMessage>(
                // This listen to [VWidgetGuardNotification] which is a notification
                // that a [VWidgetGuard] sends when it is created
                // When this happens, we store the VWidgetGuard and its context
                // This will be used to call its afterUpdate and beforeLeave in particular.
                onNotification: (VWidgetGuardMessage vWidgetGuardMessage) {
                  // VWidgetGuardMessageRoot(
                  //   vWidgetGuardState: vWidgetGuardMessage.vWidgetGuardState,
                  //   localContext: vWidgetGuardMessage.localContext,
                  //   associatedVRouteElement: this,
                  // ).dispatch(vPathRequestData.rootVRouterContext);

                  return false;
                },
                child: widgetBuilder(
                  Builder(
                    builder: (BuildContext context) {
                      return VRouterHelper(
                        pages: <Page>[if (parentCanPop) EmptyPage()] +
                            (nestedRouteVRoute!.pages.isNotEmpty
                                ? nestedRouteVRoute.pages
                                : [EmptyPage()]),
                        navigatorKey: navigatorKey,
                        observers: <NavigatorObserver>[
                          VNestedObserverReporter(
                            navigatorObserversToReportTo:
                                vPathRequestData.navigatorObserversToReportTo,
                          ),
                          heroController
                        ],
                        backButtonDispatcher: ChildBackButtonDispatcher(
                          Router.of(context).backButtonDispatcher!,
                        )..takePriority(),
                        onPopPage: (route, data) {
                          // Try to pop a Nav1 page, if successful return false
                          if (!(route.settings is Page)) {
                            route.didPop(data);
                            return true;
                          }

                          // Else use [VRouterDelegate.pop]
                          late final vPopData;
                          if (data is VPopData) {
                            vPopData = data;
                          } else {
                            vPopData = VPopData(
                              elementToPop: nestedRouteVRoute!.vRouteElementNode
                                  .getVRouteElementToPop(),
                              pathParameters: pathParameters,
                              queryParameters: {},
                              hash: '', // Pop to no hash be default
                              newHistoryState: {},
                            );
                          }

                          RootVRouterData.of(context).popFromElement(
                            vPopData.elementToPop,
                            pathParameters: vPopData.pathParameters,
                            queryParameters: vPopData.newHistoryState,
                            newHistoryState: vPopData.newHistoryState,
                          );
                          return false;
                        },
                        onSystemPopPage: () async {
                          // Try to pop a Nav1 page, if successful return true
                          if (navigatorKey.currentState!.isLastRouteNav1) {
                            navigatorKey.currentState!.pop();
                            return true; // We handled it
                          }

                          // Return false because we handle it in VRouter
                          return false;
                        },
                      );
                    },
                  ),
                ),
              ),
              vRouteElementNode: vRouteElementNode,
              url: vPathRequestData.url,
              previousUrl: vPathRequestData.previousUrl,
              historyState: vPathRequestData.historyState,
              pathParameters: pathParameters,
              queryParameters: vPathRequestData.queryParameters,
              context: context,
            ),
          ),
          name ?? parentVPathMatch.localPath,
          VRouterDataImpl(
            previousUrl: vPathRequestData.previousUrl,
            url: vPathRequestData.url,
            pathParameters: pathParameters,
            queryParameters: vPathRequestData.queryParameters,
            historyState: vPathRequestData.historyState,
            names: names,
          ),
        ),
        ...stackedRouteVRoute?.pages ?? [],
      ],
      pathParameters: pathParameters,
      vRouteElements: <VRouteElement>[this] +
          nestedRouteVRoute.vRouteElements +
          (stackedRouteVRoute?.vRouteElements ?? []),
      names: names,
    );
  }

  GetPathFromNameResult getPathFromName(
    String nameToMatch, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
    required Map<String, String> remainingPathParameters,
  }) {
    final childNameResults = <GetPathFromNameResult>[];

    // Check if any nestedRoute matches the name
    for (var vRouteElement in nestedRoutes) {
      childNameResults.add(
        vRouteElement.getPathFromName(
          nameToMatch,
          pathParameters: pathParameters,
          parentPathResult: parentPathResult,
          remainingPathParameters: remainingPathParameters,
        ),
      );
      if (childNameResults.last is ValidNameResult) {
        return childNameResults.last;
      }
    }

    // Check if any subroute matches the name
    for (var vRouteElement in stackedRoutes) {
      childNameResults.add(
        vRouteElement.getPathFromName(
          nameToMatch,
          pathParameters: pathParameters,
          parentPathResult: parentPathResult,
          remainingPathParameters: remainingPathParameters,
        ),
      );
      if (childNameResults.last is ValidNameResult) {
        return childNameResults.last;
      }
    }

    // If no subroute or stackedRoute matches the name, try to match this name
    if (name == nameToMatch) {
      // If path or any alias is valid considering the given path parameters, return this
      if (parentPathResult is ValidParentPathResult) {
        if (parentPathResult.path == null) {
          // If this path is null, we add a NullPathErrorNameResult
          childNameResults.add(NullPathErrorNameResult(name: nameToMatch));
        } else {
          if (remainingPathParameters.isNotEmpty) {
            // If there are path parameters remaining, wee add a PathParamsErrorsNameResult
            childNameResults.add(
              PathParamsErrorsNameResult(
                name: nameToMatch,
                values: [
                  OverlyPathParamsError(
                    pathParams: pathParameters.keys.toList(),
                    expectedPathParams:
                        parentPathResult.pathParameters.keys.toList(),
                  ),
                ],
              ),
            );
          } else {
            // Else the result is valid
            return ValidNameResult(path: parentPathResult.path!);
          }
        }
      } else {
        assert(parentPathResult is PathParamsErrorNewParentPath);
        childNameResults.add(
          PathParamsErrorsNameResult(
            name: nameToMatch,
            values: [
              MissingPathParamsError(
                pathParams: pathParameters.keys.toList(),
                missingPathParams:
                    (parentPathResult as PathParamsErrorNewParentPath)
                        .pathParameters,
              ),
            ],
          ),
        );
      }
    }

    // If we don't have any valid result

    // If some stackedRoute returned PathParamsPopError, aggregate them
    final pathParamsNameErrors = PathParamsErrorsNameResult(
      name: nameToMatch,
      values: childNameResults.fold<List<PathParamsError>>(
        <PathParamsError>[],
        (previousValue, element) {
          return previousValue +
              ((element is PathParamsErrorsNameResult) ? element.values : []);
        },
      ),
    );

    // If there was any PathParamsPopError, we have some pathParamsPopErrors.values
    // and therefore should return this
    if (pathParamsNameErrors.values.isNotEmpty) {
      return pathParamsNameErrors;
    }

    // Else try to find a NullPathError
    if (childNameResults.indexWhere(
            (childNameResult) => childNameResult is NullPathErrorNameResult) !=
        -1) {
      return NullPathErrorNameResult(name: nameToMatch);
    }

    // Else return a NotFoundError
    return NotFoundErrorNameResult(name: nameToMatch);
  }

  VPopResult getPathFromPop(
    VRouteElement elementToPop, {
    required Map<String, String> pathParameters,
    required GetNewParentPathResult parentPathResult,
  }) {
    // If vRouteElement is this, then this is the element to pop so we return null
    if (elementToPop == this) {
      return PoppingPopResult(poppedVRouteElements: [this]);
    }

    // Try to pop from the nestedRoutes
    for (var vRouteElement in nestedRoutes) {
      VPopResult childPopResult = vRouteElement.getPathFromPop(
        elementToPop,
        pathParameters: pathParameters,
        parentPathResult: parentPathResult,
      );
      if (!(childPopResult is NotFoundPopResult)) {
        // If the VRouteElement to pop has been found

        // If NOT PoppingPopResult, return the PathParamsPopErrors or the ValidPopResult as is
        if (!(childPopResult is PoppingPopResult)) {
          return childPopResult;
        }

        // If nestedRoute returned PoppingPopResult, we should pop too
        // Add ourselves to the poppedVRouteElements in a PoppingPopResult
        return PoppingPopResult(
          poppedVRouteElements: childPopResult.poppedVRouteElements + [this],
        );
      }
    }

    // Try to pop from the subRoutes
    for (var vRouteElement in stackedRoutes) {
      VPopResult childPopResult = vRouteElement.getPathFromPop(
        elementToPop,
        pathParameters: pathParameters,
        parentPathResult: parentPathResult,
      );
      if (!(childPopResult is NotFoundPopResult)) {
        // If the VRouteElement to pop has been found

        // If NOT PoppingPopResult, return the PathParamsPopErrors or the ValidPopResult as is
        if (!(childPopResult is PoppingPopResult)) {
          // If it is ValidPopResult, add this name to the list of names if this has a name
          if (childPopResult is ValidPopResult) {
            return ValidPopResult(
              path: childPopResult.path,
              poppedVRouteElements: childPopResult.poppedVRouteElements,
              names:
                  (name != null ? [name!] : <String>[]) + childPopResult.names,
            );
          }

          return childPopResult;
        }

        // We should NOT pop with the VRouteElement to pop

        final poppedVRouteElements =
            childPopResult.poppedVRouteElements + [this];

        // Check whether the parentPathResult is valid or not
        if (parentPathResult is ValidParentPathResult) {
          // If parentPathResult is valid, return a ValidPopResult with the right path
          return ValidPopResult(
            path: parentPathResult.path,
            poppedVRouteElements: poppedVRouteElements,
            names: name != null ? [name!] : [],
          );
        }

        // Else return a PathParamsPopErrors by specifying what prevented parentPathResult from
        // being valid
        assert(parentPathResult is PathParamsErrorNewParentPath);
        return PathParamsPopErrors(
          poppedVRouteElements: poppedVRouteElements,
          values: [
            MissingPathParamsError(
              pathParams: pathParameters.keys.toList(),
              missingPathParams:
                  (parentPathResult as PathParamsErrorNewParentPath)
                      .pathParameters,
            ),
          ],
        );
      }
    }

    // If none of the stackedRoutes popped and this did not pop, return a NotValidPopResult
    // This should never reach RootVRouter
    return NotFoundPopResult();
  }

  @override
  void afterLeave(BuildContext context, String? from, String to) {
    // Pop any navigator 1 route before navigating (dialog, modal sheet, ...)
    navigatorKey.currentState?.popUntil((route) => route.settings is Page);
  }
}

/// The only goal of this observer is to push information up the root [VNavigatorObserver]
class VNestedObserverReporter extends NavigatorObserver {
  final List<NavigatorObserver> _navigatorObserversToReportTo;

  VNestedObserverReporter(
      {required List<NavigatorObserver> navigatorObserversToReportTo})
      : _navigatorObserversToReportTo = navigatorObserversToReportTo;

  @override
  void didPop(Route route, Route? previousRoute) {
    _navigatorObserversToReportTo.forEach(
      (element) => element.didPop(route, previousRoute),
    );
  }

  @override
  void didPush(Route route, Route? previousRoute) {
    _navigatorObserversToReportTo.forEach(
      (element) => element.didPush(route, previousRoute),
    );
  }

  @override
  void didRemove(Route route, Route? previousRoute) {
    _navigatorObserversToReportTo.forEach(
      (element) => element.didRemove(route, previousRoute),
    );
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    _navigatorObserversToReportTo.forEach(
      (element) => element.didReplace(
        newRoute: newRoute,
        oldRoute: oldRoute,
      ),
    );
  }

  @override
  void didStartUserGesture(Route route, Route? previousRoute) {
    _navigatorObserversToReportTo.forEach(
      (element) => element.didStartUserGesture(route, previousRoute),
    );
  }

  @override
  void didStopUserGesture() {
    _navigatorObserversToReportTo.forEach(
      (element) => element.didStopUserGesture(),
    );
  }
}
