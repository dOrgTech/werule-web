import 'dart:math';

import 'package:Homebase/screens/creator/creator_widgets.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';


/// A large fixed-size 1200×250 widget with comedic lines from edges
/// to a central square-cornered button, using strict 90° segments.
class MemeArrowWidget extends StatefulWidget {
  const MemeArrowWidget({super.key});

  @override
  State<MemeArrowWidget> createState() => _MemeArrowWidgetState();
}

class _MemeArrowWidgetState extends State<MemeArrowWidget>
    with SingleTickerProviderStateMixin {
  // Our container
  static const double containerW = 1200;
  static const double containerH = 250;

  // The button in the center, 100×40, no rounded corners
  static const double buttonW = 100;
  static const double buttonH = 40;

  late AnimationController _controller;
  late Animation<double> _anim;

  // We'll generate 15 comedic lines
  static const int lineCount = 15;

  // All line data
  late List<ArrowLine> _lines;

  final _rand = Random();

  @override
  void initState() {
    super.initState();

    _lines = List.generate(lineCount, (index) => _createLine());

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _anim = Tween<double>(begin: 0, end: 1).animate(_controller);

    _controller.forward();
  }

  /// Creates one comedic arrow line, guaranteed to be 90° segments only.
  ArrowLine _createLine() {
    // We'll store a list of points. We'll connect them in order with 90° turns.
    final segments = <Offset>[];

    // 1) random edge start
    final start = _randomEdgePoint();
    // 2) move 10 px inward
    final inward = _moveInward(start);

    segments.add(inward);

    // 3) up to 3 random corners
    final cornerCount = _rand.nextInt(3) + 1;
    Offset current = inward;

    for (int i = 0; i < cornerCount; i++) {
      // We pick horizontal or vertical
      bool horizontal = _rand.nextBool();
      double distance = horizontal
          ? _rand.nextDouble() * (containerW / 2)
          : _rand.nextDouble() * (containerH / 2);
      final sign = _rand.nextBool() ? 1.0 : -1.0;

      Offset next;
      if (horizontal) {
        next = Offset(current.dx + sign * distance, current.dy);
      } else {
        next = Offset(current.dx, current.dy + sign * distance);
      }

      // clamp
      next = Offset(
        next.dx.clamp(0.0, containerW),
        next.dy.clamp(0.0, containerH),
      );
      segments.add(next);
      current = next;
    }

    // 4) final approach: random side of button 20 px away
    // forcing strictly horizontal or vertical approach
    final forced = _randomButtonSide(current);
    final finalPoint = forced.offset;
    final arrowDir = forced.arrowDirection;

    // We'll connect current to finalPoint with 2 steps:
    //  - step1: line up horizontally or vertically
    //  - step2: approach final x or y
    // This ensures a 90° corner, no diagonal.
    if (current.dx != finalPoint.dx && current.dy != finalPoint.dy) {
      // We'll do either horizontal-first or vertical-first, random
      if (_rand.nextBool()) {
        // horizontal first
        final mid = Offset(finalPoint.dx, current.dy);
        segments.add(mid);
        segments.add(finalPoint);
      } else {
        // vertical first
        final mid = Offset(current.dx, finalPoint.dy);
        segments.add(mid);
        segments.add(finalPoint);
      }
    } else {
      // If we happen to already align in x or y, just one segment
      segments.add(finalPoint);
    }

    // random thickness 2..7
    final thickness = 2.0 + _rand.nextDouble() * 5.0;

    // Build final line data
    return ArrowLine(
      segments: segments,
      arrowDirection: arrowDir,
      thickness: thickness,
    );
  }

  /// Picks a random side of the button bounding box 20 px away,
  /// returns offset + arrow direction (up/down/left/right).
  _ButtonSideResult _randomButtonSide(Offset current) {
    // The button bounding box
    const bxLeft = (containerW - buttonW) / 2;
    const bxTop = (containerH - buttonH) / 2;
    const r = Rect.fromLTWH(bxLeft, bxTop, buttonW, buttonH);

    final side = _rand.nextInt(4);
    switch (side) {
      case 0:
        // top => arrow points down
        final x = _rand.nextDouble() * r.width + r.left;
        return _ButtonSideResult(
          Offset(x, r.top - 20),
          ArrowDirection.down,
        );
      case 1:
        // right => arrow points left
        final y = _rand.nextDouble() * r.height + r.top;
        return _ButtonSideResult(
          Offset(r.right + 20, y),
          ArrowDirection.left,
        );
      case 2:
        // bottom => arrow points up
        final x2 = _rand.nextDouble() * r.width + r.left;
        return _ButtonSideResult(
          Offset(x2, r.bottom + 20),
          ArrowDirection.up,
        );
      default:
        // left => arrow points right
        final y3 = _rand.nextDouble() * r.height + r.top;
        return _ButtonSideResult(
          Offset(r.left - 20, y3),
          ArrowDirection.right,
        );
    }
  }

  /// Returns an Offset on the container boundary (top, right, bottom, left).
  Offset _randomEdgePoint() {
    final edge = _rand.nextInt(4);
    switch (edge) {
      case 0: // top
        return Offset(_rand.nextDouble() * containerW, 0);
      case 1: // right
        return Offset(containerW, _rand.nextDouble() * containerH);
      case 2: // bottom
        return Offset(_rand.nextDouble() * containerW, containerH);
      default: // left
        return Offset(0, _rand.nextDouble() * containerH);
    }
  }

  /// Moves the point 10 px inward from the container edges.
  Offset _moveInward(Offset start) {
    double x = start.dx;
    double y = start.dy;
    if (y == 0) y += 10;
    if (y == containerH) y -= 10;
    if (x == 0) x += 10;
    if (x == containerW) x -= 10;
    return Offset(x, y);
  }

  @override
  Widget build(BuildContext context) {
    // Force a fixed size so there's no scaling distortion
    return SizedBox(
      width: containerW,
      height: containerH,
      child: Stack(
        children: [
          // Painted lines
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) => CustomPaint(
              size: const Size(containerW, containerH),
              painter: _LinePainter(_lines, _anim.value),
            ),
          ),
          // Square-cornered button in the center
          AnimatedBuilder(
            animation: _anim,
            builder: (_, __) {
              final opacity = (_anim.value >= 1.0) ? 1.0 : 0.4;
              return Opacity(
                opacity: opacity,
                child: Align(
                  alignment: Alignment.center,
                  child: TextButton(
                    onPressed: () {},
                    child: Container(
                      margin: const EdgeInsets.all(6),
                      color: Theme.of(context).canvasColor.withOpacity(0.9),
                      width: 300,
                      height: 70,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Transform.scale(scale: 0.6, child: const FlashingIcon()),
                          const SizedBox(width: 17),
                          AnimatedContainer(
                              duration: const Duration(milliseconds: 489),
                              child: AnimatedTextKit(
                                onTap: () {},
                                isRepeatingAnimation: false,
                                repeatForever: false,
                                animatedTexts: [
                                  ColorizeAnimatedText('Upgrade to Full DAO',
                                      textStyle: const TextStyle(
                                          fontSize: 16,
                                          color: Color.fromARGB(
                                              255, 178, 178, 178)),
                                      textDirection: TextDirection.ltr,
                                      speed: const Duration(milliseconds: 700),
                                      colors: [
                                        const Color.fromARGB(
                                            255, 219, 219, 219),
                                        const Color.fromARGB(
                                            255, 251, 251, 251),
                                        const Color.fromARGB(
                                            255, 255, 180, 110),
                                        Colors.yellow,
                                        const Color.fromARGB(
                                            255, 255, 169, 163),
                                        const Color.fromARGB(
                                            255, 255, 243, 139),
                                        Colors.amber,
                                        const Color(0xff343434)
                                      ]),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Describes one comedic arrow line:
/// - A list of offsets describing each corner
/// - The arrow direction at the final approach
/// - The thickness of the line
class ArrowLine {
  final List<Offset> segments;
  final ArrowDirection arrowDirection;
  final double thickness;

  ArrowLine({
    required this.segments,
    required this.arrowDirection,
    required this.thickness,
  });

  /// The total length of the segments
  double get totalLength {
    double length = 0;
    for (int i = 0; i < segments.length - 1; i++) {
      length += _dist(segments[i], segments[i + 1]);
    }
    return length;
  }

  /// distance between two points (should be purely horizontal or vertical)
  double _dist(Offset a, Offset b) {
    final dx = (b.dx - a.dx).abs();
    final dy = (b.dy - a.dy).abs();
    return dx + dy; // or sqrt(dx^2+dy^2) but we know one of dx/dy is zero
  }
}

/// Which direction the arrow points.
enum ArrowDirection { up, down, left, right }

/// Return of random final approach
class _ButtonSideResult {
  final Offset offset;
  final ArrowDirection arrowDirection;
  _ButtonSideResult(this.offset, this.arrowDirection);
}

/// Paints each line segment-by-segment so we never see any diagonal partial cuts.
class _LinePainter extends CustomPainter {
  final List<ArrowLine> lines;
  final double progress; // 0..1

  _LinePainter(this.lines, this.progress);

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    // 1) find max length
    double maxLen = 0;
    for (final line in lines) {
      final len = line.totalLength;
      if (len > maxLen) maxLen = len;
    }

    // 2) each line
    for (final line in lines) {
      final len = line.totalLength;
      // fraction of this line to draw
      double scaledDist = progress * (maxLen / len);
      if (scaledDist > 1.0) scaledDist = 1.0;

      final distToDraw = scaledDist * len;
      final paint = Paint()
        ..color = const Color.fromARGB(255, 161, 215, 219).withOpacity(0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = line.thickness
        ..strokeCap = StrokeCap.square
        ..strokeJoin = StrokeJoin.miter;

      double remaining = distToDraw;
      Offset? currentStart = line.segments.first;
      Offset? finalPos;

      // draw each segment fully or partially
      for (int i = 0; i < line.segments.length - 1; i++) {
        final s = line.segments[i];
        final e = line.segments[i + 1];
        final segLen = (e - s).distance; // might be dx+dy if purely HV
        if (remaining <= 0) {
          break;
        }
        if (remaining >= segLen) {
          // full segment
          _drawSegment(canvas, s, e, paint);
          remaining -= segLen;
          finalPos = e;
        } else {
          // partial
          // because it's HV, we can just offset one coordinate
          if ((e.dx - s.dx).abs() < 0.001) {
            // vertical
            final sign = (e.dy > s.dy) ? 1.0 : -1.0;
            final partial = Offset(s.dx, s.dy + sign * remaining);
            _drawSegment(canvas, s, partial, paint);
            finalPos = partial;
          } else {
            // horizontal
            final sign = (e.dx > s.dx) ? 1.0 : -1.0;
            final partial = Offset(s.dx + sign * remaining, s.dy);
            _drawSegment(canvas, s, partial, paint);
            finalPos = partial;
          }
          remaining = 0;
        }
      }

      // if fully drawn, draw arrowhead
      if (scaledDist >= 1.0 && finalPos != null) {
        _drawArrowhead(canvas, finalPos, line);
      }
    }
  }

  /// Draw one line from [start] to [end].
  void _drawSegment(Canvas canvas, Offset start, Offset end, Paint paint) {
    final path = Path()..moveTo(start.dx, start.dy);
    path.lineTo(end.dx, end.dy);
    canvas.drawPath(path, paint);
  }

  /// Arrow size = thickness * 2, oriented by [line.arrowDirection].
  void _drawArrowhead(Canvas canvas, Offset tip, ArrowLine line) {
    final arrowPaint = Paint()
      ..color = const Color.fromARGB(255, 161, 215, 219).withOpacity(0.05)
      ..style = PaintingStyle.fill;

    final arrowSize = line.thickness * 2;
    final path = Path();
    switch (line.arrowDirection) {
      case ArrowDirection.up:
        path.moveTo(tip.dx, tip.dy);
        path.lineTo(tip.dx - arrowSize, tip.dy + arrowSize);
        path.lineTo(tip.dx + arrowSize, tip.dy + arrowSize);
        break;
      case ArrowDirection.down:
        path.moveTo(tip.dx, tip.dy);
        path.lineTo(tip.dx - arrowSize, tip.dy - arrowSize);
        path.lineTo(tip.dx + arrowSize, tip.dy - arrowSize);
        break;
      case ArrowDirection.left:
        path.moveTo(tip.dx, tip.dy);
        path.lineTo(tip.dx + arrowSize, tip.dy - arrowSize);
        path.lineTo(tip.dx + arrowSize, tip.dy + arrowSize);
        break;
      case ArrowDirection.right:
        path.moveTo(tip.dx, tip.dy);
        path.lineTo(tip.dx - arrowSize, tip.dy - arrowSize);
        path.lineTo(tip.dx - arrowSize, tip.dy + arrowSize);
        break;
    }
    path.close();
    canvas.drawPath(path, arrowPaint);
  }

  @override
  bool shouldRepaint(_LinePainter oldDelegate) => true;
}
