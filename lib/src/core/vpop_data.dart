import 'package:vrouter/src/core/vroute_element.dart';

class VPopData {
  final VRouteElement elementToPop;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final String? hash;
  final Map<String, String> newHistoryState;

  VPopData({
    required this.elementToPop,
    required this.pathParameters,
    required this.queryParameters,
    required this.hash,
    required this.newHistoryState,
  });

  @override
  String toString() {
    return '${this.runtimeType}(\n'
        ' itemToPop: $elementToPop,\n'
        ' pathParameters: $pathParameters,\n'
        ' queryParameters: $queryParameters,\n'
        ' hash: $hash,\n'
        ' newHistoryState: $newHistoryState,\n'
        ')';
  }
}
