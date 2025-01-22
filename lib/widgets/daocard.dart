import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:go_router/go_router.dart';
import '../screens/dao.dart';
import '../entities/org.dart';
import '../utils/reusable.dart';

class DAOCard extends StatelessWidget {
  DAOCard({super.key, required this.org});
  Org org;

  @override
  Widget build(BuildContext context) {
    var random = Random();

    // Generate a value with a roughly 70% chance of being "value1" and 30% chance of being "value2"
    var chance = random.nextDouble(); // Generates a value between 0.0 and 1.0
    Widget copilas = chance < 0.7
        ? ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                colors: [
                  Color.fromARGB(255, 205, 176, 96), // Dominant color
                  Color.fromARGB(255, 206, 206, 206), // Gradient to white
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds);
            },
            blendMode: BlendMode.srcIn,
            child: Icon(
              Icons.security,
              size: 25,
            ),
          )
        : ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
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
            color: Color.fromARGB(255, 73, 73, 73).withOpacity(0.6),
          ),
          child: TextButton(
            onPressed: () {
              context.go("/" + org.address!);
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
                          Container(
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
                          SizedBox(height: 25),
                          Text(org.holders.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20)),
                          Text(
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
                                            : org.description!
                                                    .substring(0, 140) +
                                                "...",
                                        style: TextStyle(fontSize: 13)))),
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
      ],
    );
  }
}

shorte(input) {
  return input.substring(0, 20) + "...";
}
