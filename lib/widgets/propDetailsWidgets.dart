import 'package:Homebase/widgets/fundProject.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:async';
import 'dart:math';
import 'package:image/image.dart' as img;

import '../entities/proposal.dart';

class TokenTransfer {
  
  final String amount;
  final String token;
  final String address;
  final String explorerUrl;
  final String hash;
   bool done=false;

  TokenTransfer(this.amount, 
  this.token, this.address, this.explorerUrl, this.hash, this.done);


}

class TokenTransferListWidget extends StatelessWidget {
   Proposal p;

  List<TokenTransfer> tokenTransfers=[];

   TokenTransferListWidget({
    required this.p,
   });

  @override
  Widget build(BuildContext context) {
    for (Txaction t in p.transactions) {
      print("found a transaction here");
      tokenTransfers.add(TokenTransfer(
        t.value,
        "XTZ",
        t.recipient,
        "explorerURL",
        "fashsaodisahodi",
        false
      ));
    };
    return ListView.builder(
      itemCount: tokenTransfers.length,
      itemBuilder: (context, index) {
        final transfer = tokenTransfers[index];
        return SizedBox(
          height: 60,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Amount and Token Symbol
                Text(
                  '${transfer.amount} ${transfer.token}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),
        
                // Arrow indicating "to"
                Icon(Icons.arrow_forward, size: 20),
        
                const SizedBox(width: 8),
        
                // Avatar image generated from address hash
                FutureBuilder<Uint8List>(
                  future: generateAvatarAsync(transfer.hash),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(),
                      ); // Placeholder while loading
                    } else if (snapshot.hasData) {
                      return Image.memory(
                        snapshot.data!,
                        width: 40,
                        height: 40,
                      ); // Render the generated avatar
                    } else {
                      return SizedBox(
                        width: 40,
                        height: 40,
                      ); // Placeholder if there's an error
                    }
                  },
                ),
                SizedBox(width: 16),
        
                // Address
                Expanded(
                  child: Text(
                    transfer.address,
                    style: TextStyle(fontSize: 14),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
        
                // View on Block Explorer link
                // GestureDetector(
                //   onTap: () {
                //     // Handle opening the block explorer link
                //     // You can use url_launcher package to open URLs
                //   },
                //   child: Text(
                //     'View on Block Explorer',
                //     style: TextStyle(
                //       color: Colors.green,
                //       fontSize: 14,
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Uint8List> generateAvatarAsync(String hash, {int size = 40, int pixelSize = 5}) async {
    final random = Random(hash.hashCode);
    final image = img.Image(size, size);
    final colorPalette = List.generate(5, (_) => img.getColor(random.nextInt(256), random.nextInt(256), random.nextInt(256)));
    for (var x = 0; x < size ~/ 2; x += pixelSize) {
      for (var y = 0; y < size; y += pixelSize) {
        final color = colorPalette[random.nextInt(colorPalette.length)];
        img.fillRect(image, x, y, x + pixelSize, y + pixelSize, color);
        img.fillRect(image, size - x - pixelSize, y, size - x, y + pixelSize, color);
      }
    }

    final pngBytes = img.encodePng(image);
    return Future.value(Uint8List.fromList(pngBytes));
  }
}
