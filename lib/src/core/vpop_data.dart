import 'package:vrouter/src/core/vroute_element.dart';

class VPopData {
  VRouteElement elementToPop;
  Map<String, String> pathParameters;
  Map<String, String> queryParameters;
  Map<String, String> newHistoryState;

  VPopData({
    required this.elementToPop,
    required this.pathParameters,
    required this.queryParameters,
    required this.newHistoryState,
  });

  @override
  String toString() {
    return '${this.runtimeType}(\n'
        ' itemToPop: $elementToPop,\n'
        ' pathParameters: $pathParameters,\n'
        ' queryParameters: $queryParameters,\n'
        ' newHistoryState: $newHistoryState,\n'
        ')';
  }
}
