import 'package:Homebase/screens/explorer.dart';
import 'package:Homebase/widgets/gameOfLife.dart';
import 'package:Homebase/widgets/menu.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

import '../entities/human.dart';
import '../main.dart';

class Landing extends StatefulWidget {
  Landing({super.key});
  bool loading = false;
  @override
  State<Landing> createState() => _LandingState();
}

class _LandingState extends State<Landing> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleCodeEntered(String value) async {
    if (value == "a1") {
      setState(() {
        widget.loading = true;
      });
      Human().landing = false;
      await persist();

      // Use `mounted` to ensure the widget is still in the tree
      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Explorer()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        children: [
          Opacity(opacity: 0.04, child: GameOfLife()),
          Center(
            child: SizedBox(
              width: 600,
              child: widget.loading
                  ? SizedBox(
                      height: 100,
                      width: 100,
                      child: CircularProgressIndicator(
                        color: Color.fromARGB(255, 110, 110, 110),
                        strokeWidth: 4,
                      ),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _opacityAnimation.value,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: MediaQuery(
                                  data: MediaQueryData(textScaleFactor: 2.0),
                                  child: Logo(),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 80),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _opacityAnimation.value,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Text(
                                  "Decentralized Governance ",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 25),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 20),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _opacityAnimation.value,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: Text(
                                  "for Humans and Machines",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 18),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 250),
                        AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            return Opacity(
                              opacity: _opacityAnimation.value,
                              child: Transform.scale(
                                scale: _scaleAnimation.value,
                                child: SizedBox(
                                  width: 200,
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: "Got a code?",
                                    ),
                                    onChanged: _handleCodeEntered,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        SizedBox(height: 100),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
