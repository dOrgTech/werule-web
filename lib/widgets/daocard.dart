import 'dart:math';
import 'dart:typed_data';
import 'package:Homebase/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../entities/org.dart';
import '../utils/reusable.dart';

class DAOCard extends StatelessWidget {
  DAOCard({super.key, required this.org});
  Org org;
  @override
  Widget build(BuildContext context) {
    print("DAOCard build for org: ${org.name} (Address: ${org.address}), org.wrapped: ${org.wrapped}"); // ADDED LOG
    var random = Random();
    var chance = random.nextDouble();
    Widget copilas = org.debatesOnly == false
        ? ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: 
                  [
                  Color.fromARGB(255, 205, 176, 96), 
                  Color.fromARGB(255, 206, 206, 206), 
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: const Icon(
              Icons.security,
              size: 25,
            ),
          )
        : ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                colors: [
                  Color.fromARGB(255, 156, 214, 229), // Dominant color
                  Color.fromARGB(255, 206, 206, 206), // Gradient to white
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child:
                Image.network("assets/img/debate_tree_icon.png", height: 29));
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(7),
            color: Colors.grey.shade600.withOpacity(0.45),
          ),
          child: TextButton(
            style: ButtonStyle(
              overlayColor: WidgetStateProperty.all<Color>(
                  Theme.of(context).indicatorColor.withOpacity(0.1)),
              backgroundColor: WidgetStateProperty.all<Color>(
                  Theme.of(context).canvasColor.withOpacity(0.1)),
              elevation: WidgetStateProperty.all(0.6),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7.0),
                ),
              ),
            ),
            onPressed: () {
              context.go("/${org.address!}");
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14.0),
              child: SizedBox(
                width: 350,
                height: 145,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4),
                      child: Column(
                        children: [
                          SizedBox(
                            height: 32,
                            width: 32,
                            child: FutureBuilder<Uint8List>(
                              future:
                                  generateAvatarAsync(hashString(org.address!)),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Container(
                                    width: 32.0,
                                    height: 32.0,
                                    color: Colors.grey,
                                  );
                                } else if (snapshot.hasData) {
                                  return Image.memory(snapshot.data!);
                                } else {
                                  return Container(
                                    width: 32.0,
                                    height: 32.0,
                                    color: const Color.fromARGB(
                                        255, 116, 116, 116),
                                  );
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 3, bottom: 5.0),
                            child: Text(org.symbol!,
                                style: TextStyle(
                                    color: Theme.of(context).indicatorColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20)),
                          ),
                          const SizedBox(height: 25),
                          Text(org.holders.toString(),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          const Text(
                            "Members",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.w100, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 8.0),
                      child: Column(
                        children: [
                          Text(
                              org.name.length > 20
                                  ? shorte(org.name)
                                  : org.name,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: org.name.length < 18 ? 19 : 16)),
                          Padding(
                            padding: const EdgeInsets.only(top: 18.0, left: 12),
                            child: SizedBox(
                                width: 240,
                                child: Center(
                                    child: Text(
                                        org.description!.length < 140
                                            ? org.description!
                                            : "${org.description!
                                                    .substring(0, 140)}...",
                                        style: const TextStyle(fontSize: 13)))),
                   ),
                          const Spacer(),
                          Text(getShortAddress(org.address!),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context).indicatorColor))
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: 6,
          right: 8,
          child: Opacity(opacity: 0.38, child: copilas),
        ),
        // If org.wrapped is a non-null and non-empty string, show the token icon.
        // Otherwise, show an empty SizedBox (effectively nothing).
        (org.wrapped != null && org.wrapped!.isNotEmpty)
            ? 
            const Positioned(
                bottom: 9,
                right: 8,
                child: Opacity(opacity: 0.38, child: Icon(Icons.token)),
              )
            : const SizedBox.shrink(),
           
      ],
    );
  }
}

shorte(input) {
  return input.substring(0, 20) + "...";
}
