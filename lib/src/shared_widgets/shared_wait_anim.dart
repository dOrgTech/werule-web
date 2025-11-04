import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';



class AwaitingConfirmation extends StatelessWidget {
  const AwaitingConfirmation({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
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
            const SizedBox(height: 20),
            const SizedBox(height: 50),
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