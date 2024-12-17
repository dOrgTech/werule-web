import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:lottie/lottie.dart';

class WaitingOnChain extends StatelessWidget {
  String hash = "";
  WaitingOnChain({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 500,
        height: 500,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Transaction pending...",
              style: TextStyle(fontSize: 26),
            ),
            SizedBox(height: 20),
            SizedBox(height: 50),
            SizedBox(
              height: 250,
              width: 250,
              child: Lottie.asset("assets/d4.json"),
            )
          ],
        ),
      ),
    );
  }
}
