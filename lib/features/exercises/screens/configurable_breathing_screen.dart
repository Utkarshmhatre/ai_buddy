import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';

/// Enum defining available breathing exercise types
enum BreathingExerciseType {
  box(
    'Box Breathing',
    'A 4-4-4-4 pattern that promotes calm and focus',
    '📦',
    [4, 4, 4, 4], // inhale, hold, exhale, hold
    ['Breathe In', 'Hold', 'Breathe Out', 'Hold'],
    AppColors.primary,
  ),
  fourSevenEight(
    '4-7-8 Breathing',
    'Calms your nervous system and reduces anxiety',
    '🌬️',
    [4, 7, 8, 0], // inhale, hold, exhale, no second hold
    ['Breathe In', 'Hold', 'Breathe Out', ''],
    AppColors.secondary,
  ),
  deepBelly(
    'Deep Belly Breathing',
    'Activates your parasympathetic nervous system',
    '🫁',
    [5, 2, 7, 2], // slow deep inhale, brief hold, long exhale, brief pause
    ['Breathe Deep', 'Hold', 'Release Slowly', 'Pause'],
    AppColors.calmTint,
  ),
  energizing(
    'Energizing Breath',
    'Quick breathing to increase energy and alertness',
    '⚡',
    [2, 1, 2, 0], // quick inhale, brief hold, quick exhale
    ['Quick In', 'Hold', 'Quick Out', ''],
    AppColors.encouragementTint,
  );

  final String title;
  final String description;
  final String emoji;
  final List<int> phaseDurations; // in seconds: [inhale, hold1, exhale, hold2]
  final List<String> phaseLabels;
  final Color accentColor;

  const BreathingExerciseType(
    this.title,
    this.description,
    this.emoji,
    this.phaseDurations,
    this.phaseLabels,
    this.accentColor,
  );

  int get cycleDuration => phaseDurations.reduce((a, b) => a + b);
}

/// Configurable breathing exercise screen supporting multiple exercise types
class ConfigurableBreathingScreen extends StatefulWidget {
  final BreathingExerciseType exerciseType;

  const ConfigurableBreathingScreen({
    super.key,
    required this.exerciseType,
  });

  @override
  State<ConfigurableBreathingScreen> createState() =>
      _ConfigurableBreathingScreenState();
}

class _ConfigurableBreathingScreenState
    extends State<ConfigurableBreathingScreen>
    with SingleTickerProviderStateMixin {
  // Exercise state
  bool _isActive = false;
  bool _isPaused = false;
  int _currentCycle = 0;
  int _totalCycles = 4;
  int _currentPhaseIndex = 0;
  int _phaseSeconds = 0;
  
  // Settings
  bool _showSettings = true;
  bool _enableHaptics = true;
  
  // Animation
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  Timer? _timer;

  BreathingExerciseType get _type => widget.exerciseType;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: Duration(seconds: _type.phaseDurations[0]),
    );
    _breathAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _showSettings = false;
      _isActive = true;
      _isPaused = false;
      _currentCycle = 1;
      _currentPhaseIndex = 0;
      _phaseSeconds = _type.phaseDurations[0];
    });

    _startPhaseAnimation();
    if (_enableHaptics) HapticFeedback.mediumImpact();
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _startPhaseAnimation() {
    final duration = Duration(seconds: _type.phaseDurations[_currentPhaseIndex]);
    _breathController.duration = duration;

    // Inhale phases expand, exhale phases contract
    if (_currentPhaseIndex == 0) {
      _breathController.forward(from: 0);
    } else if (_currentPhaseIndex == 2) {
      _breathController.reverse(from: 1);
    }
    // Hold phases keep animation position
  }

  void _tick(Timer timer) {
    if (_isPaused) return;

    setState(() {
      _phaseSeconds--;

      if (_phaseSeconds <= 0) {
        _transitionToNextPhase();
      }
    });
  }

  void _transitionToNextPhase() {
    if (_enableHaptics) HapticFeedback.lightImpact();

    // Find next non-zero phase
    int nextPhase = _currentPhaseIndex + 1;
    while (nextPhase < 4 && _type.phaseDurations[nextPhase] == 0) {
      nextPhase++;
    }

    if (nextPhase >= 4) {
      // Cycle complete
      if (_currentCycle < _totalCycles) {
        setState(() {
          _currentCycle++;
          _currentPhaseIndex = 0;
          _phaseSeconds = _type.phaseDurations[0];
        });
        _startPhaseAnimation();
      } else {
        _completeExercise();
      }
    } else {
      setState(() {
        _currentPhaseIndex = nextPhase;
        _phaseSeconds = _type.phaseDurations[nextPhase];
      });
      _startPhaseAnimation();
    }
  }

  void _pauseExercise() {
    setState(() => _isPaused = true);
    _breathController.stop();
  }

  void _resumeExercise() {
    setState(() => _isPaused = false);
    if (_currentPhaseIndex == 0) {
      _breathController.forward();
    } else if (_currentPhaseIndex == 2) {
      _breathController.reverse();
    }
  }

  void _completeExercise() {
    _timer?.cancel();
    if (_enableHaptics) HapticFeedback.heavyImpact();

    setState(() {
      _isActive = false;
    });
  }

  void _reset() {
    _timer?.cancel();
    _breathController.reset();

    setState(() {
      _isActive = false;
      _isPaused = false;
      _currentCycle = 0;
      _currentPhaseIndex = 0;
      _phaseSeconds = 0;
      _showSettings = true;
    });
  }

  String get _currentPhaseLabel {
    if (_currentPhaseIndex < _type.phaseLabels.length) {
      return _type.phaseLabels[_currentPhaseIndex];
    }
    return '';
  }

  Color get _currentPhaseColor {
    switch (_currentPhaseIndex) {
      case 0:
        return AppColors.primary; // Inhale
      case 1:
        return AppColors.primaryAlt; // Hold
      case 2:
        return AppColors.secondary; // Exhale
      case 3:
        return AppColors.primaryAlt; // Hold
      default:
        return _type.accentColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(_type.title),
        actions: [
          if (_isActive && !_isPaused)
            IconButton(
              icon: const Icon(Icons.pause_rounded),
              onPressed: _pauseExercise,
            )
          else if (_isActive && _isPaused)
            IconButton(
              icon: const Icon(Icons.play_arrow_rounded),
              onPressed: _resumeExercise,
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Info card
              _buildInfoCard(theme),
              
              if (_showSettings) ...[
                const SizedBox(height: 24),
                _buildSettingsCard(theme),
              ],

              const Spacer(),

              // Breathing visualization
              _buildBreathingCircle(theme),

              const Spacer(),

              // Controls
              _buildControls(theme),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _type.accentColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _type.accentColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(_type.emoji, style: const TextStyle(fontSize: 24)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _type.title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _type.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          
          // Cycles selector
          Row(
            children: [
              Icon(
                Icons.loop_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Number of Cycles')),
              SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 3, label: Text('3')),
                  ButtonSegment(value: 4, label: Text('4')),
                  ButtonSegment(value: 6, label: Text('6')),
                  ButtonSegment(value: 8, label: Text('8')),
                ],
                selected: {_totalCycles},
                onSelectionChanged: (Set<int> selected) {
                  setState(() => _totalCycles = selected.first);
                },
                style: ButtonStyle(
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Haptics toggle
          Row(
            children: [
              Icon(
                Icons.vibration_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Expanded(child: Text('Haptic Feedback')),
              Switch(
                value: _enableHaptics,
                onChanged: (v) => setState(() => _enableHaptics = v),
              ),
            ],
          ),
          
          // Total duration display
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Total duration: ~${(_type.cycleDuration * _totalCycles / 60).toStringAsFixed(1)} minutes',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreathingCircle(ThemeData theme) {
    if (!_isActive && _currentCycle == 0) {
      // Ready state
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _type.accentColor.withOpacity(0.2),
          border: Border.all(
            color: _type.accentColor.withOpacity(0.5),
            width: 3,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _type.emoji,
                style: const TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                'Ready',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: _type.accentColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms);
    }

    if (!_isActive && _currentCycle > 0) {
      // Complete state
      return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.success.withOpacity(0.2),
          border: Border.all(
            color: AppColors.success.withOpacity(0.5),
            width: 3,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '✓',
                style: TextStyle(fontSize: 48),
              ),
              const SizedBox(height: 8),
              Text(
                'Complete!',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ).animate().scale(duration: 300.ms);
    }

    // Active state with animation
    return AnimatedBuilder(
      animation: _breathAnimation,
      builder: (context, child) {
        final size = 120 + (_breathAnimation.value * 80);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                _currentPhaseColor.withOpacity(0.8),
                _currentPhaseColor.withOpacity(0.3),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: _currentPhaseColor.withOpacity(0.4),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$_phaseSeconds',
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentPhaseLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControls(ThemeData theme) {
    if (!_isActive && _currentCycle == 0) {
      // Start button
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _startExercise,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Exercise'),
              style: FilledButton.styleFrom(
                backgroundColor: _type.accentColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Cycle indicator
          Text(
            'Cycle pattern: ${_buildPatternText()}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      );
    }

    if (!_isActive && _currentCycle > 0) {
      // Complete state
      return Column(
        children: [
          Text(
            'Great job! You completed $_totalCycles cycles.',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _reset,
                  child: const Text('Do Again'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: () => context.pop(),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ).animate().fadeIn(duration: 400.ms);
    }

    // Active state
    return Column(
      children: [
        // Progress indicator
        LinearProgressIndicator(
          value: _currentCycle / _totalCycles,
          backgroundColor: theme.colorScheme.surfaceContainerHighest,
          valueColor: AlwaysStoppedAnimation(_type.accentColor),
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 8),
        Text(
          'Cycle $_currentCycle of $_totalCycles',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: _reset,
            child: const Text('Stop Exercise'),
          ),
        ),
      ],
    );
  }

  String _buildPatternText() {
    final parts = <String>[];
    final durations = _type.phaseDurations;
    final labels = _type.phaseLabels;

    for (int i = 0; i < 4; i++) {
      if (durations[i] > 0 && labels[i].isNotEmpty) {
        parts.add('${durations[i]}s ${labels[i].toLowerCase()}');
      }
    }
    return parts.join(' → ');
  }
}

/// Breathing exercises selection sheet
class BreathingExercisesSheet extends StatelessWidget {
  const BreathingExercisesSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Breathing Exercises',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose an exercise to help you relax and focus',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Exercise list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: BreathingExerciseType.values.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final type = BreathingExerciseType.values[index];
                return _ExerciseCard(
                  type: type,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConfigurableBreathingScreen(
                          exerciseType: type,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ExerciseCard extends StatelessWidget {
  final BreathingExerciseType type;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: type.accentColor.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: type.accentColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: type.accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    type.emoji,
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatPattern(type),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: type.accentColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: type.accentColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPattern(BreathingExerciseType type) {
    final durations = type.phaseDurations.where((d) => d > 0).toList();
    return 'Pattern: ${durations.join('-')}';
  }
}
