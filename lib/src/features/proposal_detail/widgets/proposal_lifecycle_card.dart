// lib/src/features/proposal_detail/widgets/proposal_lifecycle_card.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:werule/src/features/proposal_detail/widgets/proposal_status_widget.dart';
import 'package:werule/src/models/proposal.dart';
import 'package:werule/src/providers/proposal_detail_provider.dart';

class ProposalLifecycleCard extends StatefulWidget {
  const ProposalLifecycleCard({super.key});

  @override
  State<ProposalLifecycleCard> createState() => _ProposalLifecycleCardState();
}

class _ProposalLifecycleCardState extends State<ProposalLifecycleCard> {
  bool _isInitialized = false;
  List<MapEntry<ProposalStatus, DateTime>> _entries = [];
  int _visibleItemCount = 0;
  Timer? _animationTimer;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final provider = context.read<ProposalDetailProvider>();
    final newEntries = _getSortedData(provider);

    if (!_isInitialized && newEntries.isNotEmpty) {
      _isInitialized = true;
      _entries = newEntries;
      _startAnimation();
    }
    else if (_isInitialized && newEntries.length > _entries.length) {
      _animationTimer?.cancel();
      setState(() {
        _entries = newEntries;
        _visibleItemCount = _entries.length;
      });
    }
  }

  List<MapEntry<ProposalStatus, DateTime>> _getSortedData(ProposalDetailProvider provider) {
    return provider.fullTimeline.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
  }

  void _startAnimation() {
    _animationTimer?.cancel();
    _animationTimer = Timer.periodic(const Duration(milliseconds: 110), (timer) {
      if (_visibleItemCount < _entries.length) {
        if (mounted) {
          setState(() {
            _visibleItemCount++;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _animationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<ProposalDetailProvider>();

    return Card(
      color: const Color(0xff2c2c2c),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 32.0),
        child: ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _visibleItemCount,
          itemBuilder: (context, index) {
            final entry = _entries[index];
            final status = entry.key;
            final date = entry.value;

            // THE FIX: Animate both opacity and a vertical slide-in for a more noticeable effect.
            return TweenAnimationBuilder<double>(
              key: ValueKey(entry.key),
              tween: Tween(begin: 0.0, end: 1.0),
              // A slightly longer duration for a smoother feel.
              duration: const Duration(milliseconds: 250),
              builder: (context, value, child) {
                return Transform.translate(
                  // Starts 15 pixels below its final position and slides up.
                  offset: Offset(0, 15 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28.0, vertical: 9.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ProposalStatusWidget(status: status),
                    Text(
                      DateFormat.yMMMd().add_jm().format(date),
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}