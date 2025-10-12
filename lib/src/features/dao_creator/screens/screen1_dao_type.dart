// lib/src/features/dao_creator/screens/screen1_dao_type.dart
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:werule/src/features/dao_creator/providers/dao_creator_provider.dart';

class FlashingIcon extends StatefulWidget {
  const FlashingIcon({super.key});
  @override
  _FlashingIconState createState() => _FlashingIconState();
}

class _FlashingIconState extends State<FlashingIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _colorAnimation = TweenSequence<Color?>(
      [
        TweenSequenceItem(
            tween: ColorTween(
                begin: Colors.white,
                end: const Color.fromARGB(255, 255, 180, 110)),
            weight: 600),
        TweenSequenceItem(
            tween: ColorTween(begin: Colors.yellow, end: Colors.white),
            weight: 600),
      ],
    ).animate(_controller);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _colorAnimation,
      builder: (context, child) {
        return Icon(Icons.security, size: 44, color: _colorAnimation.value);
      },
    );
  }
}

class Screen1DaoType extends StatelessWidget {
  final DaoCreatorProvider provider;

  const Screen1DaoType({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    const TextStyle meniu =
        TextStyle(fontSize: 24, color: Color.fromARGB(255, 178, 178, 178));
    
    // Use the theme's default text style to ensure font consistency.
    final defaultTextStyle = Theme.of(context).textTheme.bodyMedium ??
        const TextStyle(color: Color.fromARGB(255, 194, 194, 194));

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Will you be needing a treasury?',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 26),
            const SizedBox(
                width: 510,
                child: Text(
                    "For distributed management of collective assets, you will need to deploy a Full DAO. If you just want collective ideation and large-scale brainstorming, pick Debates.\n\nThe Full DAO includes the Tokenized Debates system.\n\nThe Debates instance can be upgraded to a Full DAO at a later time, should the fear subside.",
                    style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 194, 194, 194)))),
            const SizedBox(height: 21),
           LayoutBuilder(
  builder: (context, constraints) {
    bool isNarrow = constraints.maxWidth < 750; // threshold for stacking

    return Flex(
      direction: isNarrow ? Axis.vertical : Axis.horizontal,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 340,
          height: 310,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextButton(
                style: ButtonStyle(
    overlayColor: WidgetStateProperty.all(
      const Color.fromARGB(40, 36, 36, 36), // custom hover highlight
    ),
    shape: WidgetStateProperty.all(
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // no rounded corners
      ),
    ),
  ),
              onPressed: () {
                provider.daoType = 'On-chain';
                provider.nextStep();
              },
              child: Container(
                margin: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(
                      color: const Color.fromARGB(255, 134, 134, 134)),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 22),
                    const FlashingIcon(),
                    const SizedBox(height: 14),
                    SizedBox(
                        width: 150,
                        height: 30,
                        child: Center(
                            child: AnimatedContainer(
                                duration:
                                    const Duration(milliseconds: 489),
                                child: AnimatedTextKit(
                                  onTap: () {},
                                  isRepeatingAnimation: false,
                                  repeatForever: false,
                                  animatedTexts: [
                                    ColorizeAnimatedText('Full DAO',
                                        textStyle: meniu,
                                        textDirection: TextDirection.ltr,
                                        speed: const Duration(
                                            milliseconds: 700),
                                        colors: [
                                          const Color.fromARGB(
                                              255, 219, 219, 219),
                                          const Color.fromARGB(
                                              255, 251, 251, 251),
                                          const Color.fromARGB(
                                              255, 255, 180, 110),
                                          Colors.yellow,
                                          const Color.fromARGB(
                                              255, 255, 169, 163),
                                          const Color.fromARGB(
                                              255, 255, 243, 139),
                                          Colors.amber,
                                          const Color(0xff343434)
                                        ]),
                                  ],
                                )))),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        'All important operations are secured by the will of the members through voting.',
                        style: defaultTextStyle.copyWith(height: 1.3),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const Spacer(), // This pushes the next widget to the bottom
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Text(
                        'Executive and Declarative.',
                        textAlign: TextAlign.center,
                        style: defaultTextStyle.copyWith(
                            color: Theme.of(context).indicatorColor),
                      ),
                    ),
                    const SizedBox(height: 16)
                  ],
                ),
              ),
            ),
          ),
        ),
        SizedBox(
          width: 340,
          height: 310,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: TextButton(
                style: ButtonStyle(
    overlayColor: WidgetStateProperty.all(
      const Color.fromARGB(40, 255, 255, 255), // custom hover highlight
    ),
    shape: WidgetStateProperty.all(
      const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero, // no rounded corners
      ),
    ),
  ),
              onPressed: null,
              child: Tooltip(
                decoration: BoxDecoration(
                    color: Theme.of(context).canvasColor),
                message: "Soon...",
                textStyle: const TextStyle(
                  fontSize: 30,
                  color: Color.fromARGB(255, 216, 216, 216),
                ),
                child: Container(
                  margin: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: const Color.fromARGB(255, 134, 134, 134)),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 22),
                      const Icon(Icons.forum, size: 44, color: Colors.white),
                      const SizedBox(height: 14),
                      // Ensure title container has same height for alignment
                      SizedBox(
                        width: 150,
                        height: 30,
                        child: Center(
                          child: Text('Debates',
                              style: meniu.copyWith(fontSize: 23.5)),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'Tokenized collective debates with fractal topology.',
                          textAlign: TextAlign.center,
                          style: defaultTextStyle.copyWith(height: 1.3),
                        ),
                      ),
                      const Spacer(), // This pushes the next widget to the bottom
                      Padding(
                        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                        child: Text(
                          'Declarative only.',
                          textAlign: TextAlign.center,
                          style: defaultTextStyle.copyWith(
                              color: Theme.of(context).indicatorColor),
                        ),
                      ),
                      const SizedBox(height: 10)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  },
),

          ],
        ),
      ),
    );
  }
}