import 'package:flutter/material.dart';
import 'dart:math' as math;

/// A dark gradient background that fades to transparent over a ~50px border.
class _FadeGradientBackground extends StatelessWidget {
  const _FadeGradientBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // The underlying color gradient for the map (dark theme).
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

    // A radial or combined gradient approach to fade the edges ~50px.
    // We'll measure the widget size with LayoutBuilder, then create
    // a radial gradient that is fully opaque in center, and transparent
    // near edges 50px inwards.
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final minDim = math.min(w, h);

        // We'll define the radius as half the min dimension,
        // so it covers corners. Then the fade starts ~50px from the edge.
        // So we compute the fraction at which we move from opaque -> transparent.
        // e.g. if minDim/2 = 100, and fade is 50 => the fade ratio is 50/100 = 0.5
        const fadeDistance = 50.0;
        final half = minDim / 2;
        // the fraction of the radius at which to start fading
        // clamp to [0,1] in case half < fadeDistance
        double fadeStart = ((half - fadeDistance) / half).clamp(0.0, 1.0);

        return ShaderMask(
          blendMode: BlendMode.dstIn,
          shaderCallback: (rect) {
            return RadialGradient(
              center: Alignment.center,
              radius: 2.0, // covers entire box
              colors: const [
                Colors.white, // fully opaque
                Colors.white, // remain white from center -> fadeStart
                Colors.transparent, // fade to transparent after fadeStart -> 1
              ],
              stops: [
                0.0,
                fadeStart,
                1.0,
              ],
            ).createShader(rect);
          },
          child: base,
        );
      },
    );
  }
}
