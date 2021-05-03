part of '../main.dart';

/// [VRouteElement] is the base class for any object used in routes, stackedRoutes
/// or nestedRoutes
@immutable
abstract class VRouteElementBuilder extends VRouteElement
    with VRouteElementSingleSubRoute, VoidVPopHandler, VoidVGuard {}
