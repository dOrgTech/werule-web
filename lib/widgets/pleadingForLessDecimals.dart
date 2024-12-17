import 'package:flutter/material.dart';

class AnimatedMemeWidget extends StatefulWidget {
  final List<String> texts = [
    "MY",
    "BROTHER",
    "IN",
    "CHRIST",
    "You'll never need more than 6 decimal places."
  ];

  AnimatedMemeWidget({Key? key}) : super(key: key);

  @override
  State<AnimatedMemeWidget> createState() => _AnimatedMemeWidgetState();
}

class _AnimatedMemeWidgetState extends State<AnimatedMemeWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  int _currentIndex = 0;
  late final Image _christImage;
  bool _isImageLoaded = false;

  @override
  void initState() {
    super.initState();

    // Preload the image
    _christImage = Image.network("https://i.ibb.co/M1gQRt4/brother.png");
    _christImage.image.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (info, _) {
          setState(() {
            _isImageLoaded = true;
          });
        },
      ),
    );

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_currentIndex < widget.texts.length - 1) {
            Future.delayed(const Duration(milliseconds: 250), () {
              if (mounted) {
                setState(() {
                  _currentIndex++;
                });
                _controller.forward(from: 0.0);
              }
            });
          }
        }
      });

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 300, // Set a specific width for the widget
        child: Stack(
          alignment: Alignment.center,
          children: widget.texts.asMap().entries.map((entry) {
            final index = entry.key;
            final text = entry.value;

            return AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                final isVisible = index == _currentIndex;
                final opacity = isVisible ? _fadeAnimation.value : 0.0;
                final scale = isVisible ? _scaleAnimation.value : 0.9;

                if (index == 3) {
                  return _buildChristWithImage(isVisible, opacity, scale);
                } else if (index == 4) {
                  return _buildFinalState(isVisible, opacity, scale, text);
                }

                return Opacity(
                  opacity: opacity,
                  child: Transform.scale(
                    scale: scale,
                    child: Text(
                      text,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildChristWithImage(bool isVisible, double opacity, double scale) {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isImageLoaded)
              SizedBox(
                height: 150,
                child: _christImage,
              )
            else
              const SizedBox(
                height: 150,
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 16),
            const Text(
              "CHRIST",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalState(
      bool isVisible, double opacity, double scale, String text) {
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("My brother in", style: TextStyle(fontSize: 20)),
            const SizedBox(height: 14),
            if (_isImageLoaded)
              SizedBox(
                height: 150,
                child: _christImage,
              )
            else
              const SizedBox(
                height: 150,
                child: CircularProgressIndicator(),
              ),
            const SizedBox(height: 16),
            const Text(
              "CHRIST",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            const Text("Please realize,"),
            const SizedBox(height: 30),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20, // Slightly smaller font
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
