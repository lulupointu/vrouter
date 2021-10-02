import 'vrouter_data.dart';
import 'vrouter_navigator.dart';

/// Describes a class which contains all the useful data
/// of VRouter
abstract class VRouterSailor implements VRouterNavigator, VRouterData {}

/// Same as [VRouterSailor] except that [VRouter] has been
/// initialized so we are sure to have a url
abstract class InitializedVRouterSailor implements VRouterSailor {
  @override
  String get url;

  @override
  String get path => Uri.parse(url).path;

  @override
  String get hash => Uri.decodeComponent(Uri.parse(url).fragment);

  @override
  String? get previousPath =>
      previousUrl != null ? Uri.parse(previousUrl!).path : null;
}
