import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/services/emotion_state_service.dart';

/// Shows the latest AI emotion as a single pinned aura GIF.
class PinnedAuraIndicator extends StatefulWidget {
  const PinnedAuraIndicator({super.key});

  @override
  State<PinnedAuraIndicator> createState() => _PinnedAuraIndicatorState();
}

class _PinnedAuraIndicatorState extends State<PinnedAuraIndicator> {
  String _emotion = EmotionStateService.defaultEmotion;
  double _intensity = EmotionStateService.defaultIntensity;
  StreamSubscription<({String emotion, double intensity})>? _subscription;

  @override
  void initState() {
    super.initState();
    _loadInitialState();
    _subscription = EmotionStateService.instance.watch().listen((state) {
      if (!mounted) {
        return;
      }

      setState(() {
        _emotion = state.emotion;
        _intensity = state.intensity;
      });
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialState() async {
    final emotion = await EmotionStateService.instance.currentEmotion();
    final intensity = await EmotionStateService.instance.currentIntensity();

    if (!mounted) {
      return;
    }

    setState(() {
      _emotion = emotion;
      _intensity = intensity;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final intensityLevel = _intensityLevel(_intensity);

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: _buildAuraGif(
                  emotion: _emotion,
                  intensityLevel: intensityLevel,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Feeling ${_emotion.replaceAll('_', ' ')}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.82,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuraGif({
    required String emotion,
    required String intensityLevel,
  }) {
    final prefixedPath = 'assets/gifs/$emotion/${emotion}_$intensityLevel.gif';
    final fallbackPath = 'assets/gifs/$emotion/$intensityLevel.gif';

    return Image.asset(
      prefixedPath,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Image.asset(
          fallbackPath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const ColoredBox(
              color: Color(0x11000000),
              child: Center(
                child: Icon(Icons.favorite, color: Color(0xFF5A5A5A), size: 28),
              ),
            );
          },
        );
      },
    );
  }

  String _intensityLevel(double intensity) {
    if (intensity < 0.4) {
      return 'low';
    }

    if (intensity < 0.7) {
      return 'medium';
    }

    return 'high';
  }
}
