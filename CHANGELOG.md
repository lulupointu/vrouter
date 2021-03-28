## \[1.1.0+1\] - 03/03/2021.

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

* Add widgetBuilder to VChild and VStack

## \[1.0.0-nullsafety.4\] - 18/02/2021.

* \[**NEW**\]: add vRouteData in beforeLeave and beforeEnter
* Fix error when replacing path parameters in pushNamed
* Fix error with pushReplace on the web

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

