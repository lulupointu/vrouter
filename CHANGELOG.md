## Emojis codes
- 🛠️ : **FIX** A bug has been fixed
- ✨ : **NEW** New features have been added. Those are non breaking.
- 🚨 : **BREAKING** Some class/attribute/method changed and will break your code. Read comment to know how to migrate.
- 🔁 : **DEPRECIATED** Some class/attribute/method is depreciated. Read the documentation to know how to migrate.


## \[1.2.0+21\] - 02/02/2022.
- ✨ : Add `useInheritedMediaQuery` to `VRouter`, `WidgetsVRouter` and `CupertinoVRouter` (thanks @Mitsuroseba !)


## \[1.2.0+20\] - 02/02/2022.
- ✨ : `VRouteRedirector.parse` can now be used for complex redirections

## \[1.2.0+19\] - 02/02/2022.
- 🛠️ : Fix a bug where logs broke hot reload, thanks @doldremus (Fixes https://github.com/lulupointu/vrouter/issues/169)

## \[1.2.0+18\] - 19/01/2022.
- 🛠️ : Don't add the `hash` if it is empty in `toNamed`

## \[1.2.0+17\] - 15/01/2022.
- 🛠️ : Don't add the `hash` if it is empty

## \[1.2.0+16\] - 15/01/2022.
- 🛠️ : Hash passed directly to `VRedirector.to` `path` will be taken into account
- 🛠️ : Specify `to` `isReplacement` type

## \[1.2.0+15\] - 02/10/2021.
- 🛠️ : The exception 'Tried to get applicationInstanceId but it has not been set' should no longer appear (Fixes https://github.com/lulupointu/vrouter/issues/163 and https://github.com/lulupointu/vrouter/issues/168)

## \[1.2.0+14\] - 02/10/2021.
- ✨️ : A hash (or fragment) can now be set as part of the url
- ✨ : VAnchor allows you to easily create anchor which change the current hash and scroll to the widget when clicked
- 🛠️ : Small refactoring

## \[1.2.0+13\] - 20/09/2021.
- 🛠️ : Dynamically moving VNester.child around the widget tree could cause popping issues

## \[1.2.0+12\] - 06/09/2021.
- 🛠️ : Fix VWidgetGuard.onSystemPop in Nav1 pushed routes

## \[1.2.0+11\] - 04/08/2021.
- 🛠️ : Not putting VNester.widgetBuilder child in the widget tree is now possible

## \[1.2.0+10\] - 04/08/2021.
- 🛠️ : Redirection on the web now waits for the browser to update before redirecting

## \[1.2.0+9\] - 30/07/2021.
- ✨ : New .builder (VWidget.builder and VNester.builder) constructors gives easy access to VRouter data
- ✨ : Wildcard support
- Remove dependency of path_to_regexp

## \[1.2.0+8\] - 29/07/2021.
- 🛠️ : Update README from `push` to `to` API

## \[1.2.0+7\] - 29/07/2021.
- 🛠️ : `VRedirector.toNamed` was not passing the `pathParameters` along, cause any such navigation to fail

## \[1.2.0+6\] - 25/07/2021.
- 🛠️ : Fix bug when changing `VNester` instances while pages had been pushed (https://github.com/lulupointu/vrouter/issues/116)
- 🛠️ : The page transition animation is no longer shown on app start

## \[1.2.0+5\] - 09/07/2021.
- 🛠️ : `to` with path parameters in `path` is now properly handled (This also caused issue when using the url bar with path parameters). Fixes https://github.com/lulupointu/vrouter/issues/113

## \[1.2.0+4\] - 07/07/2021.
- 🛠️ : `toExternal` no longer yield an unexpected null value

## \[1.2.0+3\] - 06/07/2021.
- 🛠️ : Fix deep-linking on android cold start

## \[1.2.0+2\] - 05/07/2021.
- ✨ : Remove dependency on the `js` package

## \[1.2.0+1\] - 05/07/2021.
- 🛠️ : dartfmt formatted

## \[1.2.0\] - 05/07/2021.
- 🚨 : `VRedirector.to` was renamed `VRedirector.toUrl`
- 🔁 : `VRedirector.from` was renamed `VRedirector.fromUrl`
- 🔁 : `push` should NOT be used anymore. DO use `to` instead.
- 🔁 : `pushReplacement` should NOT be used anymore. DO use `to(..., isReplacement: true)` instead.
- 🔁 : `pushNamed` should NOT be used anymore. DO use `toNamed` instead.
- 🔁 : `pushReplacementNamed` should NOT be used anymore. DO use `toNamed(..., isReplacement: true)` instead.
- 🔁 : `pushSegments` should NOT be used anymore. DO use `toSegments` instead.
- 🔁 : `pushExternal` should NOT be used anymore. DO use `toExternal` instead.
- 🔁 : `replaceHistoryState` should NOT be used anymore. DO use `to(..., historyState: newHistoryState, isReplacement: true)` instead.
- ✨ : The new `toX` have even more and better documentation than their `pushX` counterpart
- ✨ : vrouter.dev has been updated for the new `toX` API
- 🚨 : `VRouterData` was renamed `VRouterDataNavigator` (this should not impact anyone)
- 🚨 : `VLocation` was renamed `VUrlHistory` (this should not impact anyone)
- ✨ : `historyBack()` goes back from 1 in the history
- ✨ : `historyForward()` goes forward to 1 in the history
- ✨ : `historyGo(int delta)` goes to i (positive or negative) from the history
- ✨ : `historyCanBack()` check whether going back from 1 in the history is possible
- ✨ : `historyCanForward()` check whether going forward to 1 in the history is possible
- ✨ : `historyCanGo(int delta)` check whether going to i (positive or negative) from the history is possible
- ✨ : vrouter.dev has documentation and example on the new `history` API
- ✨ : VRouter now has logs! `VRouter.logs` can be change to change which logs to show (`VLogs.none`, `VLogs.info` or `VLogs.warning`)
- ✨ : vrouter.dev has a new example on `stackedRoutes`
- 🛠️ : Mobile deep-linking should now work

## \[1.1.4+17\] - 19/06/2021.
- 🛠️ : Changing `VRouter.navigatorKey` won't produce any flashes anymore (Fixes: https://github.com/lulupointu/vrouter/issues/89)

## \[1.1.4+16\] - 19/06/2021.
- 🛠️ : Having a base path for a webapp is now supported. Don't forget to do https://flutter.dev/docs/development/ui/navigation/url-strategies#hosting-a-flutter-app-at-a-non-root-location (not VRouter specific). (Should fix https://github.com/lulupointu/vrouter/issues/101)
- 🛠️ : Making pageTransitionDuration use consistent

## \[1.1.4+15\] - 15/06/2021.
- 🛠️ : Delaying pop errors so that `VPopHandler` can redirect or stop the pop before the error
- 🛠️ : Computing the route on the first frame instead of delaying it

## \[1.1.4+14\] - 12/06/2021.
- 🛠️ : Moving the use of a `context` outside of a callback

## \[1.1.4+13\] - 10/06/2021.
- 🛠️ : Moving the use of a `context` outside of `addPostFrameCallback` to avoid error (yes again)

## \[1.1.4+12\] - 10/06/2021.
- 🛠️ : Moving the use of a `context` outside of `addPostFrameCallback` to avoid error
- ✨ : Improving the warning message if using several packages which all try to setup the url strategy

## \[1.1.4+11\] - 08/06/2021.
- 🛠️ : Showing then hiding `VNester.widgetBuilder` `child` no longer causes an error

## \[1.1.4+10\] - 07/06/2021.
* 🛠️ : Not using `VNester.widgetBuilder` `child` no longer causes an error
* ✨ : `VRouter.of(context).names` can now be used to get every names present in the current routes stack

## \[1.1.4+9\] - 04/06/2021.

* 🛠️ : `initialUrl` now works on the web again (Again ?!)
* 🛠️ : `navigatorKey` now works (Fixes https://github.com/lulupointu/vrouter/issues/82)

## \[1.1.4+8\] - 04/06/2021.

* 🛠️ : `initialUrl` now works on the web again

## \[1.1.4+7\] - 03/06/2021.

* 🔁 : `appRouterKey` should not be used anymore. If you need to update `routes` use `navigatorKey` instead
* 🛠️ : Correcting expression to catch unknown path in `UnknownUrlVError`
* ✨ : `navigatorKey` can now be specified manually

## \[1.1.4+6\] - 02/06/2021.

* 🛠️ : Correct `VRoute` to `VWidget` in `UnknownUrlVError` (thanks evandrmb)
* 🛠️ : Deep-linking is no longer broken
* 🛠️ : Solved issues which might have erased when the url was modified manually (1. Broken browser navigation control, 2. Bad path restoration after hot restart)

## \[1.1.4+5\] - 02/06/2021.

* ✨ : The `path` can now be accessed with `VRouter.of(context).path`

## \[1.1.4+4\] - 31/05/2021.

* 🛠️ : Renaming `VRouterScopeDuplicateException` to `_VRouterScopeDuplicateError` since this is an error
* 🛠️ : Postponing some initialization until `build`. This should fix issues with easy_localization package (https://github.com/lulupointu/vrouter/issues/60)

## \[1.1.4+3\] - 27/05/2021.

* 🛠️ : Replace a remaining `VStacked` by `VWidget` in README

## \[1.1.4+2\] - 27/05/2021.

* 🛠️ : Remove duplicate `queryParameters` in pop and systemPop

## \[1.1.4+1\] - 26/05/2021.

* 🚨 : `VRouterScope` now holds a `vRouterMode` attribute and `VRouterDelegate` does not
* 🛠️ : On the web, the url is stable on hot restart

## \[1.1.4\] - 26/05/2021.

* 🚨 : `VRouterScope` should now be put at the top of the widget tree. If you are using `...App.router`, you must insert `VRouterScope` on top of `...App.router`.
* 🛠️ : VRouter does not use the singleton which was introduced in `1.1.3+2` anymore
* ✨ : Use `appRouterKey` or change `...App.key` to recompute the `routes`, see the documentation for more details

## \[1.1.3+2\] - 25/05/2021.

* 🛠️ : VRouter can now be used with different keys without losing url state

## \[1.1.3+1\] - 25/05/2021.

* 🛠️ : Fix null error on web

## \[1.1.3\] - 24/05/2021.

* 🛠️ : Navigator observers will no longer throw error with VNester
* 🛠️ : `WidgetsBinding.instance` is replaced with `WidgetsFlutterBinding.ensureInitialized()` to avoid null errors (Closes https://github.com/lulupointu/vrouter/issues/67)
* ✨ : `Navigator.push` pages are now popped when using android back button (Closes https://github.com/lulupointu/vrouter/issues/63)
* ✨ : `Navigator.push` pages are now popped when using browser back button (Closes https://github.com/lulupointu/vrouter/issues/63)

## \[1.1.2+5\] - 16/05/2021.

* 🛠️ : Exporting helpers (such as VMaterialApp)
* 🛠️ : Update discord invite link to not expire

## \[1.1.2+4\] - 13/05/2021.

* 🛠️ : Import typo prevented web compilation

## \[1.1.2+3\] - 12/05/2021.

* 🛠️ : Refactor to re-enable IDEs autocompletion

## \[1.1.2+2\] - 07/05/2021.
Refactor to re-enable
* 🛠️ : `pathParameters` are now all passed to `VNester.subroutes`
* 🛠️ : `AppBar` now displays a `BackButton` in `nestedRoutes` if it can pop

## \[1.1.2+1\] - 07/05/2021.

* 🛠️ : Fix pushSegments: it was missing a '/' at the start of the url given to push

## \[1.1.2\] - 07/05/2021.

* ✨ : Adding pushSegments which encodes the different part of the url for you

## \[1.1.1+9\] - 03/05/2021.

* 🛠️ : pub.dev like count shield was not disposed properly on package updates

## \[1.1.1+8\] - 03/05/2021.

* 🛠️ : `VWidgetGuard` was not disposed properly
* ✨ : Redesigned README: more readable and added `VRouteElementBuilder` info

## \[1.1.1+7\] - 30/04/2021.

* 🛠️ : `pathParameters` will be passed properly in `VNester`
* 🛠️ : A edge in `onPop` of `VNesterPageBase` has been solved

## \[1.1.1+6\] - 29/04/2021.

* 🛠️ : `onSystemPop` will now pop by also looking in nestedRoutes
* ✨ : `VNester` now supports `navigatorKey`, see the documentation for more details

## \[1.1.1+5\] - 29/04/2021.

* 🔁 : Please use `VDefaultPage` instead of `VBasePage`

## \[1.1.1+4\] - 29/04/2021.

* ✨ : Add `fullscreenDialog` option to `VWidget` and `VWidgetBase`

## \[1.1.1+3\] - 29/04/2021.

* 🛠️ : `onPop` and `onSystemPop` are now called when needed, even if deeply nested

## \[1.1.1+2\] - 28/04/2021.

* 🛠️ : Remove `scrollBehavior` from `CupertinoVRouter`

## \[1.1.1+1\] - 28/04/2021.

* 🛠️ : Make `VRouteInformationParser` and `VBackButtonDispatcher` visible

## \[1.1.1\] - 27/04/2021.

* 🚨 : `onPop` and `onSystemPop` are not called ONLY when the `VRouteElement` are popped (not as long as they are in the route)
* 🚨 : `pageBuilder` now gives you a `name` parameter that you can give to your `Page`. Change `(key, child) => YourPage(key, child)` to `(key, child, name) => YourPage(key, child, name)`
* 🛠️ : `VWidgetGuard` is now disposed properly when it is no longer in the route
* 🛠️ : `VWidgetGuard.beforeUpdate` is now called properly
* ✨ : Support for extending `VRouteElementBuilder` to create custom `VRouteElement`
* ✨ : `VPath` which only constrains the path, without the need to given a widget or a page
* ✨ : `VPageBase` which is the same as `VPage` without the argument relative to the path
* ✨ : `VWidgetBase` which is the same as `VWidget` without the argument relative to the path
* ✨ : `VNesterBase` which is the same as `VNester` without the argument relative to the path
* ✨ : `VNesterPageBase` which is the same as `VNesterPage` without the argument relative to the path
* ✨ : `MaterialApp.router` `CupertinoApp.router` or `WidgetApp.router` can now be used using `VRouterDelegate`, `VRouteInformationParser` and `VBackButtonDispatcher`
* ✨ : `navigatorObservers` can now be passed to `VRouter` and will be passed to every `Navigator`
* Refactor to use the new `VRouteElementBuilder`
* Removed dependency on SimpleUrlHandler

## \[1.1.0+22\] - 20/04/2021.

* Remove prints

## \[1.1.0+21\] - 17/04/2021.

* ✨ : `pop` and `pushNamed` now return errors when needed

## \[1.1.0+20\] - 09/04/2021.

* 🚨 : Changing `pop` and `systemPop` default behaviour to include previous path parameters

## \[1.1.0+19\] - 09/04/2021.

* 🛠️ : `VRouter.of` error when called from `VRouter.builder`

## \[1.1.0+18\] - 09/04/2021.

* 🛠️ : stackedRoute in VNested which did not built VNester widget

## \[1.1.0+17\] - 09/04/2021.

* 🛠️ : vRedirector use in onPop and onSystemPop which was only stopping the redirection

## \[1.1.0+16\] - 06/04/2021.

* 🛠️ : last onPop on MacOS, Linux and Windows

## \[1.1.0+15\] - 01/04/2021.

* 🛠️ : initialUrl breaking deep-linking

## \[1.1.0+14\] - 01/04/2021.

* 🛠️ : default pop onto path parameters
* Add more migration doc

## \[1.1.0+13\] - 30/03/2021.

* 🛠️ : default Page key value

## \[1.1.0+12\] - 30/03/2021.

* 🛠️ : pop forming path when parent path end with '/'

## \[1.1.0+11\] - 30/03/2021.

* ✨ : Provide customizable key argument for VRouteElement with `widget` argument

## \[1.1.0+10\] - 30/03/2021.

* Solve pop issue when calling setState before popping

## \[1.1.0+9\] - 29/03/2021.

* Remove prints

## \[1.1.0+8\] - 29/03/2021.

* 🛠️ : url sync in edge case redirection situations

## \[1.1.0+7\] - 29/03/2021.

* Code formatting using dartfmt

## \[1.1.0+6\] - 29/03/2021.

* 🚨 : Adding LocalKey to VPage.buildPage, helping animations

## \[1.1.0+5\] - 28/03/2021.

* Code formatting using dartfmt

## \[1.1.0+4\] - 28/03/2021.

* Change import to support desktop yet again

## \[1.1.0+3\] - 28/03/2021.

* Update readme

## \[1.1.0+2\] - 28/03/2021.

* Change import to support desktop

## \[1.1.0+1\] - 28/03/2021.

* Change dependency constraints for null safety

## \[1.1.0\] - 28/03/2021.

* 🚨 : VRouteData should not be used anymore, use VRouterData to access the current route data
* 🚨 : VRouterData should not be used to get the navigation methods (push, ...), use VRouter instead
* 🚨 : Navigation control methods inside VRouteElement (beforeLeave, beforeEnter, ...) are now called even if the VRouteElement is not the last element of the route
* ✨ : New description in classes comment, example of class uses can now be found there
* ✨ : Use VRouterData to access route information (url, path params, ...)
* ✨ : Use VRouter to access navigation methods (push, ...)
* ✨ : Use context.VRouter instead of VRouter.of(context)
* ✨ : Use context.VRouterData instead of VRouterData.of(context)
* ✨ : Use context.VRouteElementData instead of VRouteElementData.of(context)
* ✨ : You can now set a initial url using VRouter.initialUrl and the InitialUrl class
* ✨ : VRouteElements now have beforeUpdate method called when the route changes but it remains in the route
* ✨ : widgetBuilder (from VChild and VStack) have a new attribute which gives you access to the current vChild in its stackedRoutes if any

See the migration guide at the end of the README to migrate!

## \[1.0.0-nullsafety.11\] - 27/02/2021.

* ✨ : Enable access to VRouterState to enable navigation without context

## \[1.0.0-nullsafety.10+1\] - 24/02/2021.

* Update README

## \[1.0.0-nullsafety.10\] - 23/02/2021.

* Change import to display web badge on pub.dev

## \[1.0.0-nullsafety.9\] - 23/02/2021.

* ✨ : Enable CupertinoPage when on IOS (https://github.com/lulupointu/vrouter/issues/3)

## \[1.0.0-nullsafety.8\] - 23/02/2021.

* 🛠️ : Map type error (https://github.com/lulupointu/vrouter/issues/4)

## \[1.0.0-nullsafety.7\] - 21/02/2021.

* Path parameters given in pushNamed are now encoded
* ✨ : pushNamed will now also search in aliases and pick the right path depending on the given pathParameters

## \[1.0.0-nullsafety.6+1\] - 20/02/2021.

* Minor correction in the default pop event

## \[1.0.0-nullsafety.6\] - 20/02/2021.

* ✨ : give a vRedirector when handling pop events
* 🚨 : pop events don't have (context, from to). See VRedirector for the new argument

## \[1.0.0-nullsafety.5+1\] - 19/02/2021.

* Correcting CHANGELOG

## \[1.0.0-nullsafety.5\] - 19/02/2021.

* ✨ : widgetBuilder to VChild and VStack

## \[1.0.0-nullsafety.4\] - 18/02/2021.

* ✨ : add vRouteData in beforeLeave and beforeEnter
* 🛠️ : error when replacing path parameters in pushNamed
* 🛠️ : error with pushReplace on the web

## \[1.0.0-nullsafety.3\] - 16/02/2021.

* 🛠️ :Fix error when pushing a url which does not start with '/'

## \[1.0.0-nullsafety.2\] - 16/02/2021.

* Formatting with dartfmt
* Remove unnecessary statements

## \[1.0.0-nullsafety.1\] - 16/02/2021.

* Remove unnecessary statements
* Add package description in pubspec.yaml

## \[1.0.0-nullsafety.0\] - 16/02/2021.

* Initial nullsafe release

