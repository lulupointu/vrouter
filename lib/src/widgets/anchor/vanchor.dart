import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:vrouter/vrouter.dart';

import 'hovering_overlay.dart';

/// The equivalent of a web anchor
///
///
/// Be default:
///   - Clicking on this anchor will add its
///   ^ [hash] at the end of the url (replacing the current one
///   ^ if any)
///   - If the [hash] appears in the url, it will try to scroll
///   ^ to make this widget visible
///
/// On the web:
///   - This will also display an overlay on the bottom
///   ^ right indicating the target url
///   - The mouse will change to a hover clickable cursor
class VAnchor extends StatefulWidget {
  /// The hash associated with the anchor
  final String hash;

  /// Whether the newly created url should replace the
  /// previous one or create a new url entry
  ///
  ///
  /// If null, it will replace the url only if the hash
  /// is the same as the current one
  final bool? replaceUrlOnTap;

  /// Whether this anchor should be active
  ///
  /// If false:
  ///   - tapping it will have no effect
  ///   - the mouse won't change on hovering
  ///   - if the [hash] appears in the url, this won't try
  ///   ^ to scroll to make this widget visible
  ///
  ///
  /// Defaults to true
  final bool active;

  /// Describes where the widget should be positioned after applying
  /// scroll animation.
  ///
  /// If `alignment` is 0.0, the child must be positioned as close to the
  /// leading edge of the viewport as possible.
  /// If `alignment` is 1.0, the child must be positioned as close to the
  /// trailing edge of the viewport as possible.
  /// If `alignment` is 0.5, the child must be positioned as close to the
  /// center of the viewport as possible.
  ///
  ///
  /// This is only used if [alignmentPolicy] is
  /// [ScrollPositionAlignmentPolicy.explicit]
  final double alignment = 0.0;

  /// How long the animation to make this widget visible
  /// will last
  ///
  ///
  /// Defaults to [Duration.zero]
  final Duration duration;

  /// The curve applied to the animation when animating
  /// this widget into view
  ///
  ///
  /// Defaults to [Curves.ease]
  final Curve curve;

  /// See [ScrollPositionAlignmentPolicy] to learn how the widget
  /// is aligned
  ///
  /// Defaults to [ScrollPositionAlignmentPolicy.explicit] (i.e. use
  /// [alignment])
  final ScrollPositionAlignmentPolicy alignmentPolicy;

  /// The child of this widget
  final Widget child;

  /// The alignment of the hovering overlay
  ///
  ///
  /// Defaults to [Alignment.bottomLeft]
  final Alignment hoveringOverlayAlignment;

  /// A widget to replace the overlay that will be
  /// display on hovering
  ///
  ///
  /// The defaults widget shown is [HoveringOverlay]
  final Widget? hoveringOverlay;

  const VAnchor({
    Key? key,
    required this.hash,
    required this.child,
    this.replaceUrlOnTap,
    this.active = true,
    this.duration = Duration.zero,
    this.curve = Curves.ease,
    this.alignmentPolicy = ScrollPositionAlignmentPolicy.explicit,
    this.hoveringOverlayAlignment = Alignment.bottomLeft,
    this.hoveringOverlay,
  }) : super(key: key);

  @override
  _VLinkState createState() => _VLinkState();
}

class _VLinkState extends State<VAnchor> {
  /// An overlay entry holding the hovering overlay
  /// if it is displayed
  OverlayEntry? hoveringOverlay;

  @override
  void didChangeDependencies() {
    // Needed to use WidgetsBinding.instance and support both Flutter 3.0 and
    // Flutter <3
    T? _ambiguate<T>(T? value) => value;

    // If the hash matches, scroll to this element
    if (widget.active && VRouter.of(context).hash == widget.hash) {
      _ambiguate(WidgetsBinding.instance)!.addPostFrameCallback((timeStamp) {
        Scrollable.ensureVisible(
          context,
          alignment: widget.alignment,
          duration: widget.duration,
          curve: widget.curve,
          alignmentPolicy: widget.alignmentPolicy,
        );
      });
    }

    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _maybeRemoveHoveringOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: widget.active ? SystemMouseCursors.click : MouseCursor.defer,
      onEnter: (_) => _maybeAddHoveringOverlay(),
      onExit: (_) => _maybeRemoveHoveringOverlay(),
      child: GestureDetector(
        onTap: widget.active
            ? () {
                final _vRouter = context.vRouter;
                _vRouter.to(
                  _vRouter.path,
                  queryParameters: _vRouter.queryParameters,
                  hash: widget.hash,
                  historyState: _vRouter.historyState,
                  isReplacement:
                      widget.replaceUrlOnTap ?? (_vRouter.hash == widget.hash),
                );
              }
            : null,
        child: widget.child,
      ),
    );
  }

  /// Adds the hovering overlay if it is not shown
  void _maybeAddHoveringOverlay() {
    // If the overlay is already displayed, do nothing
    if (hoveringOverlay != null) {
      return;
    }

    hoveringOverlay = OverlayEntry(
      builder: (_) => Align(
        alignment: widget.hoveringOverlayAlignment,
        child: HoveringOverlay(
          alignment: widget.hoveringOverlayAlignment,
          hash: widget.hash,
        ),
      ),
    );
    Navigator.of(context, rootNavigator: true)
        .overlay!
        .insert(hoveringOverlay!);
  }

  /// Removes the hovering overlay if it is shown
  void _maybeRemoveHoveringOverlay() {
    // If the overlay is not displayed, do nothing
    if (hoveringOverlay == null) {
      return;
    }

    hoveringOverlay!.remove();
    hoveringOverlay = null;
  }
}
