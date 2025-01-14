import 'dart:ui';
import 'dart:math';
import 'package:Homebase/utils/reusable.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import "package:flutter/material.dart";
import 'package:url_launcher/url_launcher.dart';

class NFT {
  String address;
  String? collectionName;
  int tokenId;
  NFT({required this.address, this.collectionName, required this.tokenId});
}

class Eneftee extends StatelessWidget {
  final NFT nft;

  Eneftee({super.key, required this.nft});

  @override
  Widget build(BuildContext context) {
    List<Color> colors = [
      Color.fromARGB(255, 41, 28, 28),
      Color.fromARGB(255, 37, 28, 41),
      Color.fromARGB(255, 32, 28, 41),
      Color.fromARGB(255, 28, 30, 41),
      Color.fromARGB(255, 28, 40, 41),
      Color.fromARGB(255, 30, 41, 28),
      Color.fromARGB(255, 30, 33, 23),
      Color.fromARGB(255, 41, 32, 28),
    ];
    String imageUrl =
        "https://media.istockphoto.com/id/1365200314/ro/fotografie/muzeul-virtual-crypto.jpg?s=1024x1024&w=is&k=20&c=Mh4TiCSM-r5H5YiLOAVv_53CI4G0V0GzlWjeqwmURNI=";
    Color color1 = colors[Random().nextInt(colors.length)];
    Color color2 = colors[Random().nextInt(colors.length)];

    return SizedBox(
      width: 360.0,
      height: 460.0,
      child: Card(
        color: color1,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color1, color2],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 4),
              GestureDetector(
                onTap: () async {
                  if (await canLaunch(imageUrl)) {
                    await launch(imageUrl);
                  } else {
                    throw 'Could not launch $imageUrl';
                  }
                },
                child: ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(10.0)),
                  child: Container(
                    width: 340.0,
                    height: 340.0,
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Center(
                        child: Icon(Icons.broken_image,
                            size: 50.0, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Address: ${getShortAddress(nft.address)}',
                      style: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Token ID: ${nft.tokenId}',
                      style: const TextStyle(
                        fontSize: 14.0,
                        color: Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 14),
                    Center(
                      child: ElevatedButton(
                          onPressed: () {},
                          child: SizedBox(
                            width: 116,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.outbond),
                                SizedBox(width: 8),
                                Text("Transfer")
                              ],
                            ),
                          )),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
