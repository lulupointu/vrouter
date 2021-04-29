## \[1.1.1+4\] - 29/04/2021.

* \[**NEW**\]: Add `fullscreenDialog` option to `VWidget` and `VWidgetBase`

## \[1.1.1+3\] - 29/04/2021.

* \[**FIX**\]: `onPop` and `onSystemPop` are now called when needed, even if deeply nested

## \[1.1.1+2\] - 28/04/2021.

* \[**FIX**\]: Remove `scrollBehavior` from `CupertinoVRouter`

## \[1.1.1+1\] - 28/04/2021.

* \[**FIX**\]: Make `VRouteInformationParser` and `VBackButtonDispatcher` visible

## \[1.1.1\] - 27/04/2021.

* \[**BREAKING**\]: `onPop` and `onSystemPop` are not called ONLY when the `VRouteElement` are popped (not as long as they are in the route)
* \[**BREAKING**\]: `pageBuilder` now gives you a `name` parameter that you can give to your `Page`. Change `(key, child) => YourPage(key, child)` to `(key, child, name) => YourPage(key, child, name)`
* \[**FIX**\]: `VWidgetGuard` is now disposed properly when it is no longer in the route
* \[**FIX**\]: `VWidgetGuard.beforeUpdate` is now called properly
* \[**NEW**\]: Support for extending `VRouteElementBuilder` to create custom `VRouteElement`
* \[**NEW**\]: `VPath` which only constrains the path, without the need to given a widget or a page
* \[**NEW**\]: `VPageBase` which is the same as `VPage` without the argument relative to the path
* \[**NEW**\]: `VWidgetBase` which is the same as `VWidget` without the argument relative to the path
* \[**NEW**\]: `VNesterBase` which is the same as `VNester` without the argument relative to the path
* \[**NEW**\]: `VNesterPageBase` which is the same as `VNesterPage` without the argument relative to the path
* \[**NEW**\]: `MaterialApp.router` `CupertinoApp.router` or `WidgetApp.router` can now be used using `VRouterDelegate`, `VRouteInformationParser` and `VBackButtonDispatcher`
* \[**NEW**\]: `navigatorObservers` can now be passed to `VRouter` and will be passed to every `Navigator`
* Refactor to use the new `VRouteElementBuilder`
* Removed dependency on SimpleUrlHandler

## \[1.1.0+22\] - 20/04/2021.

* Remove prints

## \[1.1.0+21\] - 17/04/2021.

* \[**NEW**\]: `pop` and `pushNamed` now return errors when needed

## \[1.1.0+20\] - 09/04/2021.

* \[**BREAKING**\]: Changing `pop` and `systemPop` default behaviour to include previous path parameters

## \[1.1.0+19\] - 09/04/2021.

* \[**FIX**\]: `VRouter.of` error when called from `VRouter.builder`

## \[1.1.0+18\] - 09/04/2021.

* \[**FIX**\]: stackedRoute in VNested which did not built VNester widget

## \[1.1.0+17\] - 09/04/2021.

* \[**FIX**\]: vRedirector use in onPop and onSystemPop which was only stopping the redirection

## \[1.1.0+16\] - 06/04/2021.

* \[**FIX**\]: last onPop on MacOS, Linux and Windows

## \[1.1.0+15\] - 01/04/2021.

* \[**FIX**\]: initialUrl breaking deep-linking

## \[1.1.0+14\] - 01/04/2021.

* \[**FIX**\]: default pop onto path parameters
* Add more migration doc

## \[1.1.0+13\] - 30/03/2021.

* \[**FIX**\]: default Page key value

## \[1.1.0+12\] - 30/03/2021.

* \[**FIX**\]: pop forming path when parent path end with '/'

## \[1.1.0+11\] - 30/03/2021.

* \[**NEW**\]: Provide customizable key argument for VRouteElement with `widget` argument

## \[1.1.0+10\] - 30/03/2021.

* Solve pop issue when calling setState before popping

## \[1.1.0+9\] - 29/03/2021.

* Remove prints

## \[1.1.0+8\] - 29/03/2021.

* \[**FIX**\]: url sync in edge case redirection situations

## \[1.1.0+7\] - 29/03/2021.

* Code formatting using dartfmt

## \[1.1.0+6\] - 29/03/2021.

* \[**BREAKING**\]: Adding LocalKey to VPage.buildPage, helping animations

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

* Add description to packages classes, example of class uses can now be found there
* \[**DEPRECIATED**\]: VRouteData should not be used anymore, use VRouterData to access the current route data
* \[**DEPRECIATED**\]: VRouterData should not be used to get the navigation methods (push, ...), use VRouter instead
* \[**NEW**\]: Use VRouterData to access route information (url, path params, ...)
* \[**NEW**\]: Use VRouter to access navigation methods (push, ...)
* \[**NEW**\]: Use context.VRouter instead of VRouter.of(context)
* \[**NEW**\]: Use context.VRouterData instead of VRouterData.of(context)
* \[**NEW**\]: Use context.VRouteElementData instead of VRouteElementData.of(context)
* \[**NEW**\]: You can now set a initial url using VRouter.initialUrl and the InitialUrl class
* \[**BREAKING**\]: Navigation control methods inside VRouteElement (beforeLeave, beforeEnter, ...) are now called even if the VRouteElement is not the last element of the route
* \[**NEW**\]: VRouteElements now have beforeUpdate method called when the route changes but it remains in the route
* \[**NEW**\]: widgetBuilder (from VChild and VStack) have a new attribute which gives you access to the current vChild in its stackedRoutes if any

See the migration guide at the end of the README to migrate!

## \[1.0.0-nullsafety.11\] - 27/02/2021.

* \[**NEW**\]: Enable access to VRouterState to enable navigation without context

## \[1.0.0-nullsafety.10+1\] - 24/02/2021.

* Update README

## \[1.0.0-nullsafety.10\] - 23/02/2021.

* Change import to display web badge on pub.dev

## \[1.0.0-nullsafety.9\] - 23/02/2021.

* \[**NEW**\]: Enable CupertinoPage when on IOS (https://github.com/lulupointu/vrouter/issues/3)

## \[1.0.0-nullsafety.8\] - 23/02/2021.

* Fix Map type error (https://github.com/lulupointu/vrouter/issues/4)

## \[1.0.0-nullsafety.7\] - 21/02/2021.

* Path parameters given in pushNamed are now encoded
* \[**NEW**\]: pushNamed will now also search in aliases and pick the right path depending on the given pathParameters

## \[1.0.0-nullsafety.6+1\] - 20/02/2021.

* Minor correction in the default pop event

## \[1.0.0-nullsafety.6\] - 20/02/2021.

* \[**NEW**\]: give a vRedirector when handling pop events
* \[**Breaking change**\]: pop events don't have (context, from to). See VRedirector for the new argument

## \[1.0.0-nullsafety.5+1\] - 19/02/2021.

* Correcting CHANGELOG

## \[1.0.0-nullsafety.5\] - 19/02/2021.

* \[**NEW**\]: widgetBuilder to VChild and VStack

## \[1.0.0-nullsafety.4\] - 18/02/2021.

* \[**NEW**\]: add vRouteData in beforeLeave and beforeEnter
* \[**FIX**\]: error when replacing path parameters in pushNamed
* \[**FIX**\]: error with pushReplace on the web

## \[1.0.0-nullsafety.3\] - 16/02/2021.

* Fix error when pushing a url which does not start with '/'

## \[1.0.0-nullsafety.2\] - 16/02/2021.

* Formatting with dartfmt
* Remove unnecessary statements

## \[1.0.0-nullsafety.1\] - 16/02/2021.

* Remove unnecessary statements
* Add package description in pubspec.yaml

## \[1.0.0-nullsafety.0\] - 16/02/2021.

* Initial nullsafe release

