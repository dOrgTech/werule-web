import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../debates/models/debate.dart';
import '../debates/models/argument.dart';
import 'full_debate_map.dart';

/// DebateHeader with:
///  - 1/3 left column, 2/3 map panel (max 200px tall).
///  - A large 2000x2000 canvas for the debate tree,
///  - Auto-centering the subtree bounding box once after layout,
///  - A radial gradient background with a ~50px fade at the edges.
class DebateHeader extends StatefulWidget {
  final Debate debate;
  final Argument currentArgument;
  final Function(Argument) onArgumentSelected;

  const DebateHeader({
    Key? key,
    required this.debate,
    required this.currentArgument,
    required this.onArgumentSelected,
  }) : super(key: key);

  @override
  _DebateHeaderState createState() => _DebateHeaderState();
}

class _DebateHeaderState extends State<DebateHeader> {
  static const double headerHeight = 200;

  // Keys to measure the viewport and the content's bounding box
  final GlobalKey _viewportKey = GlobalKey();
  final GlobalKey _mapContentKey = GlobalKey();

  late TransformationController _transformationController;

  // So we only auto-center once, not repeatedly
  bool _hasAutoCentered = false;

  @override
  void initState() {
    super.initState();
    // Start with an identity transform (no offset).
    _transformationController = TransformationController(Matrix4.identity());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxHeight: headerHeight),
      child: Row(
        children: [
          // Left 1/3
          Expanded(
            flex: 1,
            child: _buildLeftColumn(),
          ),
          // Right 2/3
          Expanded(
            flex: 2,
            child: SizedBox(
              key: _viewportKey, // measure this panel's size
              height: headerHeight,
              child: Stack(
                children: [
                  // 1) Our fade-gradient background
                  Positioned.fill(
                    child: _FadeGradientBackground(),
                  ),

                  // 2) The InteractiveViewer in a large 2000x2000 space
                  Positioned.fill(
                    child: ClipRect(
                      child: InteractiveViewer(
                        transformationController: _transformationController,
                        constrained: false,
                        boundaryMargin: const EdgeInsets.all(0),
                        minScale: 0.05,
                        maxScale: 4.0,
                        onInteractionStart: (_) => _hasAutoCentered = true,
                        child: SizedBox(
                          width: 2000,
                          height: 2000,
                          // We'll put the entire subtree in the center
                          child: Center(
                            // The bounding box container with _mapContentKey
                            child: Container(
                              key: _mapContentKey,
                              child: _buildTreeRoot(
                                widget.debate.rootArgument,
                                widget.currentArgument,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Once the widget layout is done, measure the subtree and the viewport, then
  /// compute a translation so the subtree is centered in the viewport.
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _autoCenterMapIfNeeded());
  }

  void _autoCenterMapIfNeeded() {
    if (_hasAutoCentered) return; // Only once

    final viewportRenderBox =
        _viewportKey.currentContext?.findRenderObject() as RenderBox?;
    final contentRenderBox =
        _mapContentKey.currentContext?.findRenderObject() as RenderBox?;

    if (viewportRenderBox == null || contentRenderBox == null) return;

    final viewportSize = viewportRenderBox.size; // e.g. 600x200
    final contentSize = contentRenderBox.size; // subtree bounding box

    // The subtree is forcibly "centered" at (1000, 1000) in the 2000x2000 canvas,
    // so its bounding box center is effectively (1000, 1000).
    final contentCenterAbsolute = const Offset(1000, 1000);

    // The viewport center is half its width/height
    final centerOfViewport =
        Offset(viewportSize.width / 2, viewportSize.height / 2);

    // If the subtree is very large or smaller, we still just center the bounding box midpoint
    // in the viewport midpoint.
    final translation = centerOfViewport - contentCenterAbsolute;
    final matrix = Matrix4.identity()
      ..translate(translation.dx, translation.dy);

    // Optionally, if subtree is larger than viewport, we might want to scale down
    // so that the entire bounding box fits initially. That would be more advanced.
    // Here, we simply center, letting the user pan or zoom as needed.

    _transformationController.value = matrix;
    _hasAutoCentered = true;
  }

  /// The left 1/3 column: debate info and a button to open full map
  Widget _buildLeftColumn() {
    final debate = widget.debate;
    final currentArg = widget.currentArgument;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            debate.title,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
            softWrap: true,
          ),
          const SizedBox(height: 12),
          Text(
            'Score: ${debate.sentiment.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            'Depth: ${_calculateDepth(currentArg)}',
            style: Theme.of(context).textTheme.titleSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),

          // Button to open the FullDebateMapPopup
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => FullDebateMapPopup(
                  debate: debate,
                  onArgumentSelected: widget.onArgumentSelected,
                ),
              );
            },
            child: const Icon(Icons.map),
          ),
        ],
      ),
    );
  }

  /// The top-level node
  Widget _buildTreeRoot(Argument root, Argument selectedArg) {
    return _buildNode(root, selectedArg);
  }

  /// Recursively build each argument node
  Widget _buildNode(Argument arg, Argument selectedArg) {
    final isSelected = (arg == selectedArg);
    final boxColor = _getBoxColor(arg);
    final box = GestureDetector(
      onTap: () => widget.onArgumentSelected(arg),
      child: Container(
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: boxColor,
          border: isSelected
              ? Border.all(color: Color.fromARGB(255, 255, 239, 254), width: 2)
              : null,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: Text(
          arg.weight.toStringAsFixed(1),
          style: const TextStyle(fontSize: 12, color: Colors.black),
        ),
      ),
    );

    final children = [...arg.proArguments, ...arg.conArguments];
    if (children.isEmpty) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [box],
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        box,
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children.map((c) => _buildNode(c, selectedArg)).toList(),
        ),
      ],
    );
  }

  int _calculateDepth(Argument arg) {
    int depth = 0;
    Argument? node = arg;
    while (node?.parent != null) {
      depth++;
      node = node?.parent;
    }
    return depth;
  }

  Color _getBoxColor(Argument arg) {
    if (arg.score <= 0) {
      return Colors.grey.shade700;
    }
    if (arg.parent == null) {
      return arg.score > 0 ? Colors.green : Colors.red;
    }
    if (arg.parent!.proArguments.contains(arg)) {
      return Colors.green;
    }
    return Colors.red;
  }
}

/// A dark gradient background that fades ~50px from the edges
/// to transparent, using a radial gradient mask.
class _FadeGradientBackground extends StatelessWidget {
  const _FadeGradientBackground({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Underlying color gradient for the map (dark theme).
    final base = Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF202020),
            Color(0xFF2A2A2A),
          ],
        ),
      ),
    );

    // A radial mask that is fully opaque in the center,
    // and transitions to transparent ~50px from the edges.
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final minDim = math.min(w, h);

        const fadeDistance = 50.0;
        final half = minDim / 2;
        // fraction at which we start fading
        final fadeStart = ((half - fadeDistance) / half).clamp(0.0, 1.0);

        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) {
            return RadialGradient(
              center: Alignment.center,
              radius: 2.0, // cover entire area
              colors: [
                Colors.white,
                Colors.white,
                Colors.transparent,
              ],
              stops: [
                0.0,
                fadeStart, // fade begins
                1.0, // fully transparent at edges
              ],
            ).createShader(rect);
          },
          child: base,
        );
      },
    );
  }
}
