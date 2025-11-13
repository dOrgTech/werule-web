// lib/src/features/dao_creator/screens/screen1_dao_type.dart
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
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

  Widget _buildFeatureItem(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_outline,
              color: Theme.of(context).indicatorColor.withOpacity(0.8),
              size: 16),
          const SizedBox(width: 12),
          Expanded(
              child: Text(text,
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(fontSize: 15, height: 1.4))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const TextStyle meniu =
        TextStyle(fontSize: 24, color: Color.fromARGB(255, 178, 178, 178));

    const colorizeColors = [
      Color.fromARGB(255, 219, 219, 219),
      Color.fromARGB(255, 251, 251, 251),
      Color.fromARGB(255, 255, 180, 110),
      Colors.yellow,
      Color.fromARGB(255, 255, 169, 163),
      Color.fromARGB(255, 255, 243, 139),
      Colors.amber,
      Color(0xff343434)
    ];

    final titleTextStyle = meniu.copyWith(height: 1.2);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text('Choose your operational framework',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 26),
            const SizedBox(
                width: 510,
                child: Text(
                    "Start with a foundational template. The Standard DAO is perfect for governance and treasury management. The Economy DAO extends this with powerful tools for on-chain project execution and dispute resolution.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 14,
                        color: Color.fromARGB(255, 194, 194, 194)))),
            const SizedBox(height: 21),
            LayoutBuilder(
              builder: (context, constraints) {
                bool isNarrow =
                    constraints.maxWidth < 750; // threshold for stacking

                return Flex(
                  direction: isNarrow ? Axis.vertical : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 340,
                      height: 400,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStateProperty.all(
                              const Color.fromARGB(
                                  40, 36, 36, 36), // custom hover highlight
                            ),
                            shape: WidgetStateProperty.all(
                              const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.zero, // no rounded corners
                              ),
                            ),
                          ),
                          onPressed: () {
                            provider.daoType = 'Standard DAO';
                            provider.nextStep();
                          },
                          child: Container(
                            margin: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 134, 134, 134)),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 22),
                                const FlashingIcon(),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 70,
                                  child: Center(
                                    child: AnimatedTextKit(
                                      onTap: () {},
                                      isRepeatingAnimation: false,
                                      repeatForever: false,
                                      animatedTexts: [
                                        ColorizeAnimatedText(
                                            'Standard\nJurisdiction',
                                            textAlign: TextAlign.center,
                                            textStyle: titleTextStyle,
                                            speed: const Duration(
                                                milliseconds: 700),
                                            colors: colorizeColors),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildFeatureItem(
                                          context, 'Secure Treasury'),
                                      _buildFeatureItem(
                                          context, 'Passive Income'),
                                      _buildFeatureItem(
                                          context, 'Paid Representation'),
                                      _buildFeatureItem(
                                          context, 'DAO Inheritance'),
                                    ],
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
                      height: 400,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: TextButton(
                          style: ButtonStyle(
                            overlayColor: WidgetStateProperty.all(
                              const Color.fromARGB(
                                  40, 36, 36, 36), // Corrected hover color
                            ),
                            shape: WidgetStateProperty.all(
                              const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.zero, // no rounded corners
                              ),
                            ),
                          ),
                          onPressed: () {
                            provider.daoType = 'Economy DAO';
                            provider.nextStep();
                          },
                          child: Container(
                            margin: const EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color:
                                      const Color.fromARGB(255, 134, 134, 134)),
                            ),
                            child: Column(
                              children: [
                                const SizedBox(height: 22),
                                const Icon(Icons.monetization_on,
                                    size: 44, color: Colors.white),
                                const SizedBox(height: 14),
                                SizedBox(
                                  height: 70,
                                  child: Center(
                                    child: AnimatedTextKit(
                                      onTap: () {},
                                      isRepeatingAnimation: false,
                                      repeatForever: false,
                                      animatedTexts: [
                                        ColorizeAnimatedText(
                                            'Trustless\nEconomy',
                                            textAlign: TextAlign.center,
                                            textStyle: titleTextStyle,
                                            speed: const Duration(
                                                milliseconds: 700),
                                            colors: colorizeColors),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      _buildFeatureItem(
                                          context, 'Secure Treasury'),
                                      _buildFeatureItem(
                                          context, 'Passive Income'),
                                      _buildFeatureItem(
                                          context, 'Paid Representation'),
                                      _buildFeatureItem(
                                          context, 'Economic Layer'),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16)
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 14,
                  color: Color.fromARGB(255, 194, 194, 194),
                ),
                children: [
                  const TextSpan(
                      text: 'Learn more about the organizational framework '),
                  TextSpan(
                    text: 'here',
                    style: TextStyle(
                      color: Theme.of(context).indicatorColor,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launchUrl(Uri.parse('https://example.com'));
                      },
                  ),
                  const TextSpan(text: '.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// lib/src/features/dao_creator/screens/screen1_dao_type.dart