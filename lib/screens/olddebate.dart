// import 'dart:math' as math;
// import 'package:flutter/material.dart';
// import '../debates/models/debate.dart';
// import '../debates/models/argument.dart';
// import 'full_debate_map.dart';

// /// A DebateHeader that:
// ///  - has a max height of ~200px,
// ///  - splits horizontally 1/3 (left) vs 2/3 (right),
// ///  - the map is clipped so it does not overflow beyond its allocated space,
// ///  - a dark gradient background for the map, with a 50px fade at the edges,
// ///  - left column is padded, center-aligned, with vertical spacing,
// ///  - the map is behind the column (stack z-order), so the column is always on top.
// class DebateHeader extends StatefulWidget {
//   final Debate debate;
//   final Argument currentArgument;
//   final Function(Argument) onArgumentSelected;

//   const DebateHeader({
//     Key? key,
//     required this.debate,
//     required this.currentArgument,
//     required this.onArgumentSelected,
//   }) : super(key: key);

//   @override
//   _DebateHeaderState createState() => _DebateHeaderState();
// }

// class _DebateHeaderState extends State<DebateHeader> {
//   late TransformationController _transformationController;

//   @override
//   void initState() {
//     super.initState();
//     _transformationController = TransformationController();
//   }

//   @override
//   void dispose() {
//     _transformationController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     // The entire header is capped at 200px tall
//     const double headerHeight = 200;

//     return Container(
//       constraints: const BoxConstraints(maxHeight: headerHeight),
//       child: Row(
//         children: [
//           // Left 1/3
//           Expanded(
//             flex: 1,
//             child: Container(
//               // A solid background so the map can't show through
//               color: Theme.of(context).scaffoldBackgroundColor,
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: _buildLeftColumn(),
//             ),
//           ),
//           // Right 2/3: We'll embed a Stack so we can place the map behind
//           // everything else if we need. We'll keep it simple: the entire
//           // area is used by the map "viewport".
//           Expanded(
//             flex: 2,
//             child: SizedBox(
//               width: double.infinity,
//               height: headerHeight,
//               child: _buildMapArea(headerHeight),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   /// The left column: debate title, score, depth, map button.
//   /// Center-aligned, padded, with vertical spacing.
//   Widget _buildLeftColumn() {
//     final debate = widget.debate;
//     final currentArg = widget.currentArgument;

//     return Column(
//       mainAxisAlignment: MainAxisAlignment.center, // center vertically
//       crossAxisAlignment: CrossAxisAlignment.center, // center horizontally
//       children: [
//         // Title: multiline, no ellipses
//         Text(
//           debate.title,
//           style: Theme.of(context).textTheme.headline6,
//           softWrap: true,
//           overflow: TextOverflow.visible,
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 12),

//         // Score
//         Text(
//           'Score: ${debate.sentiment.toStringAsFixed(2)}',
//           style: Theme.of(context).textTheme.subtitle1,
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 6),

//         // Depth
//         Text(
//           'Depth: ${_calculateDepth(currentArg)}',
//           style: Theme.of(context).textTheme.subtitle2,
//           textAlign: TextAlign.center,
//         ),
//         const SizedBox(height: 18),

//         // Map button (icon only)
//         TextButton(
//           onPressed: () {
//             showDialog(
//               context: context,
//               builder: (_) => FullDebateMapPopup(
//                 debate: debate,
//                 onArgumentSelected: widget.onArgumentSelected,
//               ),
//             );
//           },
//           child: const Icon(Icons.map),
//         ),
//       ],
//     );
//   }

//   /// The "map area": a stack-limited region that we won't let overflow
//   /// beyond its bounds, with a dark gradient + 50px fade around edges.
//   Widget _buildMapArea(double headerHeight) {
//     return LayoutBuilder(
//       builder: (ctx, constraints) {
//         final w = constraints.maxWidth;
//         final h = constraints.maxHeight;

//         // We'll clip to the allocated area so the map cannot visually overflow.
//         return ClipRect(
//           child: Stack(
//             children: [
//               // 1) The dark gradient background with a 50px fade at edges
//               Positioned.fill(child: _FadeGradientBackground()),

//               // 2) The InteractiveViewer for the debate map
//               // We let the child be unconstrained so it can expand.
//               Positioned.fill(
//                 child: InteractiveViewer(
//                   transformationController: _transformationController,
//                   constrained: false,
//                   boundaryMargin: const EdgeInsets.all(0),
//                   // Lower the minScale to something smaller than 0.1 (the previous default).
//                   // e.g. 0.05 means you can zoom out to half of what was previously allowed.
//                   minScale: 0.05,
//                   maxScale: 4.0,
//                   child: _buildTreeRoot(
//                     widget.debate.rootArgument,
//                     widget.currentArgument,
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   /// Builds a center-aligned tree for the root
//   Widget _buildTreeRoot(Argument root, Argument selectedArg) {
//     return Center(
//       child: _buildNode(root, selectedArg),
//     );
//   }

//   /// Recursively build each node. No scroll views, rely on pan/zoom.
//   Widget _buildNode(Argument arg, Argument selectedArg) {
//     final isSelected = (arg == selectedArg);
//     final boxColor = _getBoxColor(arg);

//     final box = GestureDetector(
//       onTap: () => widget.onArgumentSelected(arg),
//       child: Container(
//         margin: const EdgeInsets.all(6),
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           color: boxColor,
//           border: isSelected
//               ? Border.all(
//                   color: Color.fromARGB(255, 251, 140, 255), width: 1.5)
//               : null,
//           borderRadius: BorderRadius.circular(4.0),
//         ),
//         child: Text(
//           arg.weight.toStringAsFixed(1),
//           style: const TextStyle(fontSize: 12, color: Colors.black),
//         ),
//       ),
//     );

//     final children = [...arg.proArguments, ...arg.conArguments];
//     if (children.isEmpty) {
//       return Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [box],
//       );
//     }
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         box,
//         Row(
//           mainAxisSize: MainAxisSize.min,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children:
//               children.map((child) => _buildNode(child, selectedArg)).toList(),
//         ),
//       ],
//     );
//   }

//   int _calculateDepth(Argument arg) {
//     int depth = 0;
//     Argument? node = arg;
//     while (node?.parent != null) {
//       depth++;
//       node = node?.parent;
//     }
//     return depth;
//   }

//   Color _getBoxColor(Argument arg) {
//     if (arg.score <= 0) {
//       return Colors.grey.shade700;
//     }
//     if (arg.parent == null) {
//       return arg.score > 0 ? Colors.green : Colors.red;
//     }
//     if (arg.parent!.proArguments.contains(arg)) {
//       return Colors.green;
//     }
//     return Colors.red;
//   }
// }

// /// A dark gradient background that fades to transparent over a ~50px border.
// class _FadeGradientBackground extends StatelessWidget {
//   const _FadeGradientBackground({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // The underlying color gradient for the map (dark theme).
//     final base = Container(
//       decoration: const BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//           colors: [
//             Color(0xFF202020),
//             Color(0xFF2A2A2A),
//           ],
//         ),
//       ),
//     );

//     // A radial or combined gradient approach to fade the edges ~50px.
//     // We'll measure the widget size with LayoutBuilder, then create
//     // a radial gradient that is fully opaque in center, and transparent
//     // near edges 50px inwards.
//     return LayoutBuilder(
//       builder: (context, constraints) {
//         final w = constraints.maxWidth;
//         final h = constraints.maxHeight;
//         final minDim = math.min(w, h);

//         // We'll define the radius as half the min dimension,
//         // so it covers corners. Then the fade starts ~50px from the edge.
//         // So we compute the fraction at which we move from opaque -> transparent.
//         // e.g. if minDim/2 = 100, and fade is 50 => the fade ratio is 50/100 = 0.5
//         final fadeDistance = 50.0;
//         final half = minDim / 2;
//         // the fraction of the radius at which to start fading
//         // clamp to [0,1] in case half < fadeDistance
//         double fadeStart = ((half - fadeDistance) / half).clamp(0.0, 1.0);

//         return ShaderMask(
//           blendMode: BlendMode.dstIn,
//           shaderCallback: (rect) {
//             return RadialGradient(
//               center: Alignment.center,
//               radius: 2.0, // covers entire box
//               colors: [
//                 Colors.white, // fully opaque
//                 Colors.white, // remain white from center -> fadeStart
//                 Colors.transparent, // fade to transparent after fadeStart -> 1
//               ],
//               stops: [
//                 0.0,
//                 fadeStart,
//                 1.0,
//               ],
//             ).createShader(rect);
//           },
//           child: base,
//         );
//       },
//     );
//   }
// }
