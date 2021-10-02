import 'package:flutter/material.dart';
import 'package:vrouter/vrouter.dart';

import 'vanchor.dart';

/// The default widget which will be displayed on hovering
/// on [VAnchor]
///
/// It will display a text representing the current
/// url and where the hash has been replaced by the
/// current one
///
/// The text background color and color will adapt
/// depending on [Theme.brightness]
///
///
/// The usage of this object can be overridden using
/// [VAnchor.hoveringOverlay]
class HoveringOverlay extends StatefulWidget {
  /// The alignment of this widget in the page
  ///
  ///
  /// This will only be used to decide which angle
  /// should be rounded and NOT to place the widget
  final Alignment alignment;

  /// The hash to which to navigate on tap
  final String hash;

  const HoveringOverlay({
    Key? key,
    required this.alignment,
    required this.hash,
  }) : super(key: key);

  @override
  State<HoveringOverlay> createState() => _HoveringOverlayState();
}

class _HoveringOverlayState extends State<HoveringOverlay> {
  /// The target url which will be displayed in this widget, calculated
  /// in [didChangeDependencies]
  late String targetUrl;

  /// The border radius of this widget, calculated in [initState]
  /// and [didUpdateWidget]
  late final _borderRadius;

  /// The current theme of the application, calculated
  /// in [didChangeDependencies]
  late bool isDarkMode;

  @override
  void initState() {
    super.initState();

    _borderRadius = _getBorderRadiusFromAlignment(widget.alignment);
  }

  @override
  void didUpdateWidget(covariant HoveringOverlay oldWidget) {
    // If the alignment changed, update _borderRadius
    // We only compare the string because it represent the alignment
    // rather than the instance
    if (oldWidget.alignment.toString() != widget.alignment.toString()) {
      _borderRadius = _getBorderRadiusFromAlignment(widget.alignment);
    }

    super.didUpdateWidget(oldWidget);
  }

  @override
  void didChangeDependencies() {
    // Update the target url
    final uri = Uri.parse(context.vRouter.url);
    targetUrl = '${uri.removeFragment().toString()}#${widget.hash}';

    // Update the theme
    var brightness = Theme.of(context).brightness;
    isDarkMode = brightness == Brightness.dark;

    super.didChangeDependencies();
  }

  /// Returns the border radius based on the given alignment
  static _getBorderRadiusFromAlignment(Alignment alignment) {
    return BorderRadius.only(
      topRight: alignment == Alignment.bottomLeft
          ? Radius.circular(4.0)
          : Radius.zero,
      topLeft: alignment == Alignment.bottomRight
          ? Radius.circular(4.0)
          : Radius.zero,
      bottomRight:
          alignment == Alignment.topLeft ? Radius.circular(4.0) : Radius.zero,
      bottomLeft:
          alignment == Alignment.topRight ? Radius.circular(4.0) : Radius.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isDarkMode ? Color(0xFF2D2D2D) : Color(0xFFEEEEEE),
      borderRadius: _borderRadius,
      elevation: 1,
      child: Container(
        padding: EdgeInsets.all(4.0),
        child: Text(
          targetUrl,
          style: TextStyle(
              color: isDarkMode ? Color(0xFFEEEEEE) : Color(0xFF2D2D2D)),
        ),
      ),
    );
  }
}
