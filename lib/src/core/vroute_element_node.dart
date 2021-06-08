import 'package:vrouter/src/core/vroute_element.dart';
import 'package:vrouter/src/vrouter_vroute_elements.dart';

/// [VRouteElementNode] is used to represent the current route configuration as a tree
class VRouteElementNode {
  /// The [VRouteElementNode] containing the [VRouteElement] which is the current nested route
  /// to be valid, if any
  ///
  /// The is used be all types of [VNestedPage]
  final VRouteElementNode? nestedVRouteElementNode;

  /// The [VRouteElementNode] containing the [VRouteElement] which is the current stacked routes
  /// to be valid, if any
  final VRouteElementNode? stackedVRouteElementNode;

  /// The [VRouteElement] attached to this node
  final VRouteElement vRouteElement;

  /// The path of the [VRouteElement] attached to this node
  /// If the path has path parameters, they should be replaced
  final String? localPath;

  VRouteElementNode(
    this.vRouteElement, {
    required this.localPath,
    this.nestedVRouteElementNode,
    this.stackedVRouteElementNode,
  });

  /// Finding the element to pop for a [VRouteElementNode] means finding which one is at the
  /// end of the chain of stackedVRouteElementNode (if none then this should be popped)
  VRouteElement getVRouteElementToPop() {
    if (stackedVRouteElementNode != null) {
      return stackedVRouteElementNode!.getVRouteElementToPop();
    }
    return vRouteElement;
  }

  /// Finding the element to pop for a [VRouteElementNode] means finding which one is at the
  /// end of the chain of stackedVRouteElementNode (if none then this should be popped)
  VRouteElement getVRouteElementToSystemPop() {
    if (stackedVRouteElementNode != null) {
      return stackedVRouteElementNode!.getVRouteElementToSystemPop();
    }
    if (nestedVRouteElementNode != null) {
      return nestedVRouteElementNode!.getVRouteElementToSystemPop();
    }
    return vRouteElement;
  }

  /// Get the [VRouteElementNode] associated to the given [VRouteElement]
  /// returns null if the [VRouteElement] is not his nor in the stackedRoutes or the subroutes
  VRouteElementNode? getVRouteElementNodeFromVRouteElement(
      VRouteElement vRouteElement) {
    if (vRouteElement == this.vRouteElement) return this;
    if (stackedVRouteElementNode != null) {
      final vRouteElementNode = stackedVRouteElementNode!
          .getVRouteElementNodeFromVRouteElement(vRouteElement);
      if (vRouteElementNode != null) return vRouteElementNode;
    }
    if (nestedVRouteElementNode != null) {
      final vRouteElementNode = nestedVRouteElementNode!
          .getVRouteElementNodeFromVRouteElement(vRouteElement);
      if (vRouteElementNode != null) return vRouteElementNode;
    }
    return null;
  }

  /// Get a flatten list of the [VRouteElement] from this + all those contained in
  /// stackedRoutes and subRoutes.
  List<VRouteElement> getVRouteElements() {
    return [vRouteElement] +
        (stackedVRouteElementNode?.getVRouteElements() ?? []) +
        (nestedVRouteElementNode?.getVRouteElements() ?? []);
  }

  /// This function will search this node and the nested and sub nodes to try to find the node
  /// that hosts [vRouteElement]
  VRouteElementNode? getChildVRouteElementNode({
    required VRouteElement vRouteElement,
  }) {
    // If this VRouteElementNode contains the given VRouteElement, return this
    if (vRouteElement == this.vRouteElement) {
      return this;
    }

    // Search if the VRouteElementNode containing the VRouteElement is in the nestedVRouteElementNode
    if (nestedVRouteElementNode != null) {
      VRouteElementNode? vRouteElementNode = nestedVRouteElementNode!
          .getChildVRouteElementNode(vRouteElement: vRouteElement);
      if (vRouteElementNode != null) {
        return vRouteElementNode;
      }
    }

    // Search if the VRouteElementNode containing the VRouteElement is in the stackedVRouteElementNode
    if (stackedVRouteElementNode != null) {
      VRouteElementNode? vRouteElementNode = stackedVRouteElementNode!
          .getChildVRouteElementNode(vRouteElement: vRouteElement);
      if (vRouteElementNode != null) {
        return vRouteElementNode;
      }
    }

    // If the VRouteElement was not find anywhere, return null
    return null;
  }

  /// Gets the name from this [VRouteElementNode] and all the ones bellow
  List<String> getNames() {
    final List<String> stackedNames = stackedVRouteElementNode != null
        ? stackedVRouteElementNode!.getNames()
        : [];
    final List<String> nestedNames = nestedVRouteElementNode != null
        ? nestedVRouteElementNode!.getNames()
        : [];
    final String? name = (vRouteElement is VRouteElementWithName)
        ? (vRouteElement as VRouteElementWithName).name
        : null;

    assert(
      !stackedNames.contains(name),
      'name should be unique but $name is used more than ones',
    );
    assert(
      !nestedNames.contains(name),
      'name should be unique but $name is used more than ones',
    );
    for (var nestedName in nestedNames)
      assert(
        !stackedNames.contains(nestedName),
        'name should be unique but $nestedName is used more than ones',
      );

    return stackedNames + nestedNames + ((name != null) ? [name] : []);
  }
}

// WIP: don't look :)
// abstract class VRouteElementNodeBase {
//   VRouteElement get vRouteElement;
//
//   String? getPathFromPop();
//
//   String? getPathFromSystemPop();
//
//   List<String> getNames();
// }
//
// class VRouteElementLeaf extends VRouteElementNodeBase {
//   @override
//   VRouteElement vRouteElement;
//
//   VRouteElementLeaf({required this.vRouteElement});
//
//   @override
//   List<String> getNames() => [];
//
//   @override
//   String? getPathFromPop() => null;
//
//   @override
//   String? getPathFromSystemPop() => null;
// }
//
// class SingleChildVRouteElementNode extends VRouteElementNodeBase {
//   VRouteElementNode child;
//
//   @override
//   VRouteElement vRouteElement;
//
//   SingleChildVRouteElementNode({required this.vRouteElement, required this.child});
//
//   @override
//   List<String> getNames() {
//     final List<String> childNames = child.getNames();
//
//     final String? vRouteElementName = (vRouteElement is VRouteElementWithName)
//         ? (vRouteElement as VRouteElementWithName).name
//         : null;
//
//     assert(
//       !childNames.contains(vRouteElementName),
//       'name should be unique but $vRouteElementName is used more than ones',
//     );
//
//     return childNames + (vRouteElementName != null ? [vRouteElementName] : []);
//   }
//
//   @override
//   String? getPathFromPop() {
//
//   }
//
//   @override
//   String? getPathFromSystemPop() {
//     // TODO: implement getPathFromSystemPop
//     throw UnimplementedError();
//   }
// }
//
// class MultiChildVRouteElementNode extends VRouteElementNodeBase {
//   List<VRouteElementNode> children;
// }
