// lib/widgets/dao_card.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:werule/src/models/org.dart';
import 'package:werule/src/utils/reusable.dart';

class DAOCard extends StatelessWidget {
  const DAOCard({super.key, required this.org});
  final Org org;

  @override
  Widget build(BuildContext context) {
    Widget typeIcon = org.debatesOnly
        ? Image.asset("assets/img/debate_tree_icon.png", height: 29)
        : const Icon(Icons.security, size: 25);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            
            boxShadow: [BoxShadow(spreadRadius: 0.1, color: const Color.fromARGB(117, 77, 77, 77), offset:Offset.fromDirection(1))],
            borderRadius: BorderRadius.circular(2),
            
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 40,
                          width: 40,
                          child: FutureBuilder<Uint8List>(
                            future: generateAvatarAsync(hashString(org.address), size: 40, pixelSize: 5),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Image.memory(snapshot.data!);
                              }
                              return Container(width: 40.0, height: 40.0, color: Colors.grey.shade700);
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          org.symbol,
                          style: TextStyle(color: Theme.of(context).indicatorColor, fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        Text(org.holders.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                        const Text("Members", style: TextStyle(fontWeight: FontWeight.w300, fontSize: 13)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        org.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            org.description,
                            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      Center(
                        child: Text(
                          getShortAddress(org.address),
                          style: TextStyle(fontSize: 12, color: Theme.of(context).indicatorColor.withOpacity(0.8)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        // Top-right icon
        Positioned(
          top: 10,
          right: 10,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: org.debatesOnly
                    ? [const Color.fromARGB(255, 156, 214, 229), const Color.fromARGB(255, 206, 206, 206)]
                    : [const Color.fromARGB(255, 205, 176, 96), const Color.fromARGB(255, 206, 206, 206)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Opacity(opacity: 0.5, child: typeIcon),
          ),
        ),
        // Bottom-right icon (if applicable)
        if (org.underlyingToken != null && org.underlyingToken!.isNotEmpty)
          const Positioned(
            bottom: 10,
            right: 10,
            child: Opacity(opacity: 0.5, child: Icon(Icons.token)),
          )
        else
          const SizedBox.shrink(),
      ],
    );
  }
}
// lib/widgets/dao_card.dart