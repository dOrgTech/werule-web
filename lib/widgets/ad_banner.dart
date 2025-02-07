import 'package:Homebase/widgets/memearrow.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PlaylistWidget extends StatefulWidget {
  final Map<String, int> playlist;

  const PlaylistWidget({
    Key? key,
    required this.playlist,
  }) : super(key: key);

  @override
  State<PlaylistWidget> createState() => _PlaylistWidgetState();
}

class _PlaylistWidgetState extends State<PlaylistWidget> {
  late final List<MapEntry<String, int>> _items;
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Add the default component to the playlist
    _items = [MapEntry('default', 6000), ...widget.playlist.entries];
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: _items[_currentIndex].value), () {
      setState(() {
        _currentIndex = (_currentIndex + 1) % _items.length;
      });
      _startTimer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = _items[_currentIndex];

    return Center(
      child: currentItem.key == 'default'
          ? const MemeArrowWidget()
          : TextButton(
              onHover: null,
              onPressed: () {},
              style: ButtonStyle(
                elevation: MaterialStateProperty.all(0),
              ),
              child: Image.network(
                currentItem.key,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  size: 48,
                ),
              ),
            ),
    );
  }
}
