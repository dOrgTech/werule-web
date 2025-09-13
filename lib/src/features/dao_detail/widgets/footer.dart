
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: MediaQuery.of(context).size.width,
          color: const Color.fromARGB(255, 25, 25, 25),
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 32),
          child: Center(
            child: Container(
              // width: 1200,
              constraints: const BoxConstraints(maxWidth: 1050),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'Terms',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'Privacy',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: () {},
                        child: const Text(
                          'Contact',
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const MediaQuery(
                          data: MediaQueryData(textScaler: TextScaler.linear(1.7)),
                          child: Logo()),
                      const SizedBox(height: 18),
                      Text(
                        '© ${DateTime.now().year}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {},
                            child: const Text(
                              'Powered by ',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: const Text(
                              'Tezos Commons',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text(
                            'Developed by ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white,
                            ),
                          ),
                          InkWell(
                            onTap: () {},
                            child: const Text(
                              'Eight Rice',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: InkWell(
        hoverColor: Colors.transparent,
        onTap:  () => context.go("/"),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic, // Ensures proper alignment
          children: [
            Text(
              'we',
              style: TextStyle(
                fontFamily: 'CascadiaCode',
                backgroundColor: Color.fromARGB(255, 192, 192, 192),
                fontSize: 28,
                color: Color.fromARGB(255, 22, 22, 22),
                fontWeight: FontWeight.w800,
              ),
            ),
            SizedBox(width: 2),
            Text(
              'R',
              style: TextStyle(
                fontFamily: 'CascadiaCode',
                backgroundColor: Color.fromARGB(255, 26, 26, 26),
                fontSize: 24, // Match the font size for consistency
                fontWeight: FontWeight.w100,
              ),
            ),
            Text(
              'ule',
              style: TextStyle(
                fontFamily: 'CascadiaCode',
                backgroundColor: Color.fromARGB(255, 26, 26, 26),
                fontSize: 28, // Match the font size for consistency
                fontWeight: FontWeight.w100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}