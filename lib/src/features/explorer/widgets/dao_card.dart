// lib/src/features/explorer/widgets/dao_card.dart

import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/utils/reusable.dart';
import 'dart:math'; // For the clamp function

class DAOCard extends StatefulWidget {
  const DAOCard({super.key, required this.org});
  final Org org;

  @override
  State<DAOCard> createState() => _DAOCardState();
}

class _DAOCardState extends State<DAOCard> {
  Uint8List? _avatarBytes;

  @override
  void initState() {
    super.initState();
    _generateAndCacheAvatar();
  }

  void _generateAndCacheAvatar() async {
    final bytes = await generateAvatarAsync(hashString(widget.org.address), size: 200, pixelSize: 25);
    if (mounted) {
      setState(() {
        _avatarBytes = bytes;
      });
    }
  }

  double _getFontSizeForDescription(String description) {
    const double maxFontSize = 16.0;
    const double minFontSize = 12.0;
    const int upperLengthThreshold = 40;
    const int lowerLengthThreshold = 120;

    final length = description.length;

    if (length <= upperLengthThreshold) {
      return maxFontSize;
    }
    if (length >= lowerLengthThreshold) {
      return minFontSize;
    }

    final range = lowerLengthThreshold - upperLengthThreshold;
    final progress = (length - upperLengthThreshold) / range;
    return maxFontSize - (maxFontSize - minFontSize) * progress;
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (_avatarBytes != null)
            Opacity(
              opacity: 0.05,
              child: Image.memory(
                _avatarBytes!,
                fit: BoxFit.cover,
              ),
            ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color.fromARGB(255, 58, 58, 58).withOpacity(0.35),
                  const Color.fromARGB(197, 39, 39, 39).withOpacity(0.55),
                ],
              ),
            ),
          ),
          if (_avatarBytes == null) placeholder,
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                      shadows: [Shadow(blurRadius: 2, color: Colors.black54)],
                    ),
                    children: <TextSpan>[
                      TextSpan(text: '${widget.org.name} '),
                      TextSpan(
                        text: '\$${widget.org.symbol}',
                        style: TextStyle(
                          color: Theme.of(context).indicatorColor.withOpacity(0.9),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      widget.org.description,
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: _getFontSizeForDescription(widget.org.description),
                        color: Colors.grey[200],
                        shadows: const [Shadow(blurRadius: 1, color: Colors.black87)],
                      ),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
          _buildTopRightIcon(),
          // --- MODIFIED: The old positioned widgets are replaced by a single info row ---
          _buildBottomInfoRow(context),
          if (widget.org.underlyingToken != null && widget.org.underlyingToken!.isNotEmpty)
            const Positioned(
              bottom: 10,
              right: 10,
              child: Opacity(opacity: 0.6, child: Icon(Icons.token, size: 20)),
            ),
        ],
      ),
    );
  }

  // --- NEW: This widget creates the bottom row for the date and address ---
  Widget _buildBottomInfoRow(BuildContext context) {
    // Format the DateTime object into "MM/YYYY"
    final month = widget.org.creationDate.month.toString().padLeft(2, '0');
    final year = widget.org.creationDate.year.toString();
    final formattedDate = 'Since $month/$year';

    return Positioned(
      bottom: 10,
      left: 16,
      right: 16, // Padding for the whole row
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left side: Creation Date
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[400],
            ),
          ),
          // Right side: Shortened Address
          Text(
            getShortAddress(widget.org.address),
            style: TextStyle(
              fontSize: 12,
              fontFamily: 'CascadiaCode',
              color: Theme.of(context).indicatorColor.withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  // --- REMOVED: The following two methods are no longer needed ---
  // _buildBottomAddress() has been removed.
  // _buildBottomLeftMembers() has been removed.

  Widget _buildTopRightIcon() {
    Widget typeIcon = widget.org.debatesOnly
        ? Image.asset("assets/img/debate_tree_icon.png", height: 29)
        : const Icon(Icons.security, size: 25);

    return Positioned(
      top: 10,
      right: 10,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return LinearGradient(
            colors: widget.org.debatesOnly
                ? [const Color.fromARGB(255, 156, 214, 229), const Color.fromARGB(255, 206, 206, 206)]
                : [const Color.fromARGB(255, 205, 176, 96), const Color.fromARGB(255, 206, 206, 206)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ).createShader(bounds);
        },
        blendMode: BlendMode.srcIn,
        child: Opacity(opacity: 0.5, child: typeIcon),
      ),
    );
  }
}