import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:go_router/go_router.dart';
import '../screens/dao.dart';

import '../entities/org.dart';
import '../utils/reusable.dart';

class DAOCard extends StatelessWidget {
  DAOCard({super.key, required this.org});
  Org org;
  @override
  Widget build(BuildContext context) {
    return Container(
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
                        height: 40,
                        width: 40,
                        child: FutureBuilder<Uint8List>(
                          future: generateAvatarAsync(hashString(org
                              .address!)), // Make your generateAvatar function return Future<Uint8List>
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                width: 40.0,
                                height: 40.0,
                                color: Colors.grey,
                              );
                            } else if (snapshot.hasData) {
                              print("generating");
                              return Image.memory(snapshot.data!);
                            } else {
                              return Container(
                                width: 40.0,
                                height: 40.0,
                                color: const Color.fromARGB(
                                    255, 116, 116, 116), // Error color
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
                      // Container(
                      //   width: 40,
                      //   height: 20,
                      //   decoration: BoxDecoration(
                      //     color: Color.fromARGB(255, 80, 109, 96),
                      //     borderRadius: BorderRadius.circular(8),
                      //   ),
                      //   child: Center(
                      //       child: Text("V.3",
                      //           style: TextStyle(
                      //               color: Color.fromARGB(255, 185, 253, 206),
                      //               fontWeight: FontWeight.bold,
                      //               fontSize: 15))),
                      // ),
                      SizedBox(height: 21),
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
                      Text(org.name.length > 20 ? shorte(org.name) : org.name,
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
                                        : org.description!.substring(0, 140) +
                                            "...",
                                    style: TextStyle(fontSize: 13)))),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

shorte(input) {
  return input.substring(0, 20) + "...";
}
