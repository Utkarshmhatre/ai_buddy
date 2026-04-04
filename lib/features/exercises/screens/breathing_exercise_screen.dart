import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai/enhanced_gemini_service.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/exercise_bloc.dart';
import '../bloc/exercise_event_state.dart';

/// 4-7-8 Breathing exercise screen with animated guidance
class BreathingExerciseScreen extends StatefulWidget {
  const BreathingExerciseScreen({super.key});

  @override
  State<BreathingExerciseScreen> createState() => _BreathingExerciseScreenState();
}

class _BreathingExerciseScreenState extends State<BreathingExerciseScreen>
    with SingleTickerProviderStateMixin {
  // Exercise state
  bool _isActive = false;
  int _currentCycle = 0;
  final int _totalCycles = 4;
  
  // Breathing phases
  BreathingPhase _currentPhase = BreathingPhase.ready;
  int _phaseSeconds = 0;
  
  // AI narration
  ExerciseNarration? _aiNarration;
  bool _loadingNarration = true;
  
  // Animation
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _breathAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
    
    // Load AI narration
    _loadAINarration();
  }

  Future<void> _loadAINarration() async {
    try {
      final exerciseBloc = context.read<ExerciseBloc>();
      exerciseBloc.add(const LoadExerciseNarration(exerciseType: 'breathing'));
      
      // Listen for narration state
      await for (final state in exerciseBloc.stream) {
        if (state is ExerciseReady) {
          if (mounted) {
            setState(() {
              _aiNarration = state.narration;
              _loadingNarration = false;
            });
          }
          break;
        } else if (state is ExerciseError) {
          if (mounted) {
            setState(() => _loadingNarration = false);
          }
          break;
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingNarration = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _breathController.dispose();
    super.dispose();
  }

  void _startExercise() {
    setState(() {
      _isActive = true;
      _currentCycle = 1;
      _currentPhase = BreathingPhase.inhale;
      _phaseSeconds = 4;
    });
    
    _breathController.forward();
    HapticFeedback.mediumImpact();
    
    _timer = Timer.periodic(const Duration(seconds: 1), _tick);
  }

  void _tick(Timer timer) {
    setState(() {
      _phaseSeconds--;
      
      if (_phaseSeconds <= 0) {
        _transitionToNextPhase();
      }
    });
  }

  void _transitionToNextPhase() {
    HapticFeedback.lightImpact();
    
    switch (_currentPhase) {
      case BreathingPhase.inhale:
        setState(() {
          _currentPhase = BreathingPhase.hold;
          _phaseSeconds = 7;
        });
        break;
        
      case BreathingPhase.hold:
        setState(() {
          _currentPhase = BreathingPhase.exhale;
          _phaseSeconds = 8;
        });
        _breathController.reverse();
        break;
        
      case BreathingPhase.exhale:
        if (_currentCycle < _totalCycles) {
          setState(() {
            _currentCycle++;
            _currentPhase = BreathingPhase.inhale;
            _phaseSeconds = 4;
          });
          _breathController.forward();
        } else {
          _completeExercise();
        }
        break;
        
      case BreathingPhase.ready:
      case BreathingPhase.complete:
        break;
    }
  }

  void _completeExercise() {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    
    setState(() {
      _isActive = false;
      _currentPhase = BreathingPhase.complete;
    });
  }

  void _reset() {
    _timer?.cancel();
    _breathController.reset();
    
    setState(() {
      _isActive = false;
      _currentCycle = 0;
      _currentPhase = BreathingPhase.ready;
      _phaseSeconds = 0;
    });
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
        title: const Text('Breathing Exercise'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Info section
              _buildInfoCard(theme),
              
              const Spacer(),
              
              // Breathing circle
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
    // Use AI narration if available, otherwise fallback to default
    final title = _aiNarration?.title ?? '4-7-8 Breathing';
    final description = _aiNarration?.introduction ?? 
        'Calms your nervous system and reduces anxiety';
    final hasAI = _aiNarration != null;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text('🌬️', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (hasAI) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.auto_awesome, size: 12, color: AppColors.primary),
                                const SizedBox(width: 2),
                                Text(
                                  'AI',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_loadingNarration) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Personalizing your experience...',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildBreathingCircle(ThemeData theme) {
    return AnimatedBuilder(
      animation: _breathAnimation,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer glow
            Container(
              width: 240 * _breathAnimation.value,
              height: 240 * _breathAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: _currentPhase.color.withValues(alpha: 0.3),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ),
            
            // Main circle
            Container(
              width: 200 * _breathAnimation.value,
              height: 200 * _breathAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    _currentPhase.color.withValues(alpha: 0.6),
                    _currentPhase.color.withValues(alpha: 0.3),
                  ],
                ),
                border: Border.all(
                  color: _currentPhase.color,
                  width: 3,
                ),
              ),
            ),
            
            // Inner content
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentPhase.instruction,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _currentPhase.color,
                  ),
                ),
                if (_isActive) ...[
                  const SizedBox(height: 8),
                  Text(
                    '$_phaseSeconds',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
                if (_currentPhase == BreathingPhase.complete) ...[
                  const SizedBox(height: 8),
                  Text(
                    '🎉',
                    style: TextStyle(fontSize: 40),
                  ).animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 500.ms,
                    curve: Curves.elasticOut,
                  ),
                ],
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildControls(ThemeData theme) {
    return Column(
      children: [
        // Progress indicator
        if (_isActive) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_totalCycles, (index) {
              final isCompleted = index < _currentCycle - 1;
              final isCurrent = index == _currentCycle - 1;
              
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isCurrent ? 24 : 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isCompleted || isCurrent
                      ? AppColors.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            'Cycle $_currentCycle of $_totalCycles',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
        ],
        
        // Action buttons
        if (_currentPhase == BreathingPhase.ready)
          SizedBox(
            width: double.infinity,
            height: 56,
            child: FilledButton.icon(
              onPressed: _startExercise,
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Exercise'),
            ),
          )
        else if (_currentPhase == BreathingPhase.complete)
          Column(
            children: [
              Text(
                _aiNarration?.closing ?? 'Great job! You completed the exercise.',
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
          ).animate().fadeIn(duration: 400.ms)
        else
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
}

/// Breathing phases for 4-7-8 technique
enum BreathingPhase {
  ready('Get Ready', AppColors.secondary),
  inhale('Breathe In', AppColors.primary),
  hold('Hold', AppColors.primaryAlt),
  exhale('Breathe Out', AppColors.secondary),
  complete('Complete!', AppColors.success);

  final String instruction;
  final Color color;
  const BreathingPhase(this.instruction, this.color);
}
