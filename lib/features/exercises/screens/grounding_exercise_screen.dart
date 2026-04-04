import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai/enhanced_gemini_service.dart';
import '../../../core/theme/app_colors.dart';
import '../bloc/exercise_bloc.dart';
import '../bloc/exercise_event_state.dart';

/// 5-4-3-2-1 Grounding exercise screen
class GroundingExerciseScreen extends StatefulWidget {
  const GroundingExerciseScreen({super.key});

  @override
  State<GroundingExerciseScreen> createState() => _GroundingExerciseScreenState();
}

class _GroundingExerciseScreenState extends State<GroundingExerciseScreen> {
  int _currentStep = 0;
  final List<List<String>> _userInputs = [[], [], [], [], []];
  final TextEditingController _inputController = TextEditingController();
  
  // AI narration
  ExerciseNarration? _aiNarration;
  bool _loadingNarration = true;

  final _steps = const [
    _GroundingStep(
      count: 5,
      sense: 'See',
      emoji: '👁️',
      instruction: 'Look around and name 5 things you can SEE',
      examples: 'A lamp, a tree outside, your phone, a book, a cup...',
      color: AppColors.primary,
    ),
    _GroundingStep(
      count: 4,
      sense: 'Touch',
      emoji: '✋',
      instruction: 'Notice 4 things you can TOUCH or FEEL',
      examples: 'The chair, your clothes, the floor, your breath...',
      color: AppColors.primaryAlt,
    ),
    _GroundingStep(
      count: 3,
      sense: 'Hear',
      emoji: '👂',
      instruction: 'Listen for 3 things you can HEAR',
      examples: 'Birds, traffic, your heartbeat, the AC...',
      color: AppColors.secondary,
    ),
    _GroundingStep(
      count: 2,
      sense: 'Smell',
      emoji: '👃',
      instruction: 'Notice 2 things you can SMELL',
      examples: 'Fresh air, coffee, your shampoo, food...',
      color: AppColors.warning,
    ),
    _GroundingStep(
      count: 1,
      sense: 'Taste',
      emoji: '👅',
      instruction: 'Name 1 thing you can TASTE',
      examples: 'Water, gum, toothpaste, your last meal...',
      color: AppColors.accent,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadAINarration();
  }

  Future<void> _loadAINarration() async {
    try {
      final exerciseBloc = context.read<ExerciseBloc>();
      exerciseBloc.add(const LoadExerciseNarration(exerciseType: 'grounding'));
      
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
    _inputController.dispose();
    super.dispose();
  }

  bool get _canProceed {
    return _userInputs[_currentStep].length >= _steps[_currentStep].count;
  }

  bool get _isComplete {
    return _currentStep >= _steps.length;
  }

  void _addItem() {
    final text = _inputController.text.trim();
    if (text.isEmpty) return;
    
    if (_userInputs[_currentStep].length < _steps[_currentStep].count) {
      setState(() {
        _userInputs[_currentStep].add(text);
        _inputController.clear();
      });
      HapticFeedback.lightImpact();
      
      // Auto-proceed when step is complete
      if (_canProceed) {
        Future.delayed(500.ms, () {
          if (mounted) _nextStep();
        });
      }
    }
  }

  void _removeItem(int index) {
    setState(() {
      _userInputs[_currentStep].removeAt(index);
    });
  }

  void _nextStep() {
    if (_currentStep < _steps.length - 1) {
      setState(() {
        _currentStep++;
      });
      HapticFeedback.mediumImpact();
    } else {
      setState(() {
        _currentStep = _steps.length; // Complete state
      });
      HapticFeedback.heavyImpact();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _reset() {
    setState(() {
      _currentStep = 0;
      for (var list in _userInputs) {
        list.clear();
      }
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
        title: const Text('Grounding Exercise'),
      ),
      body: SafeArea(
        child: _isComplete
            ? _buildCompletionView(theme)
            : _buildExerciseView(theme),
      ),
    );
  }

  Widget _buildExerciseView(ThemeData theme) {
    final step = _steps[_currentStep];
    final itemsNeeded = step.count - _userInputs[_currentStep].length;
    
    return Column(
      children: [
        // AI Introduction (only on first step)
        if (_currentStep == 0 && _aiNarration != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _aiNarration!.introduction,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          )
        else if (_currentStep == 0 && _loadingNarration)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  'Personalizing...',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        
        if (_currentStep == 0) const SizedBox(height: 12),
        
        // Progress indicator
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            children: List.generate(_steps.length, (index) {
              final isCompleted = index < _currentStep;
              final isCurrent = index == _currentStep;
              
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? _steps[index].color
                        : isCurrent
                            ? _steps[index].color.withValues(alpha: 0.5)
                            : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Step content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                // Step header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        step.color.withValues(alpha: 0.2),
                        step.color.withValues(alpha: 0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            step.emoji,
                            style: const TextStyle(fontSize: 40),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${step.count}',
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: step.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step.instruction,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.examples,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
                
                const SizedBox(height: 24),
                
                // Input field
                if (itemsNeeded > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _inputController,
                          decoration: InputDecoration(
                            hintText: 'Type something you can ${step.sense.toLowerCase()}...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                          ),
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addItem(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filled(
                        onPressed: _addItem,
                        icon: const Icon(Icons.add_rounded),
                        style: IconButton.styleFrom(
                          backgroundColor: step.color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$itemsNeeded more to go',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // User inputs
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _userInputs[_currentStep].asMap().entries.map((entry) {
                    return Chip(
                      label: Text(entry.value),
                      deleteIcon: const Icon(Icons.close, size: 18),
                      onDeleted: () => _removeItem(entry.key),
                      backgroundColor: step.color.withValues(alpha: 0.2),
                    ).animate().scale(
                      begin: const Offset(0.8, 0.8),
                      duration: 200.ms,
                      curve: Curves.easeOut,
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        
        // Navigation buttons
        Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              if (_currentStep > 0)
                IconButton.outlined(
                  onPressed: _previousStep,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              const Spacer(),
              if (_canProceed)
                FilledButton.icon(
                  onPressed: _nextStep,
                  icon: Icon(_currentStep < _steps.length - 1
                      ? Icons.arrow_forward_rounded
                      : Icons.check_rounded),
                  label: Text(_currentStep < _steps.length - 1
                      ? 'Next'
                      : 'Complete'),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCompletionView(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🎉',
            style: const TextStyle(fontSize: 64),
          ).animate().scale(
            begin: const Offset(0, 0),
            end: const Offset(1, 1),
            duration: 600.ms,
            curve: Curves.elasticOut,
          ),
          
          const SizedBox(height: 24),
          
          Text(
            'Well Done!',
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms),
          
          const SizedBox(height: 12),
          
          Text(
            _aiNarration?.closing ?? 'You completed the 5-4-3-2-1 grounding exercise.\nTake a moment to notice how you feel now.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms),
          
          const SizedBox(height: 32),
          
          // Summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What you noticed:',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                ...List.generate(_steps.length, (stepIndex) {
                  final step = _steps[stepIndex];
                  final items = _userInputs[stepIndex];
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(step.emoji),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            items.join(', '),
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.1),
          
          const Spacer(),
          
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
          ).animate().fadeIn(delay: 800.ms),
        ],
      ),
    );
  }
}

class _GroundingStep {
  final int count;
  final String sense;
  final String emoji;
  final String instruction;
  final String examples;
  final Color color;

  const _GroundingStep({
    required this.count,
    required this.sense,
    required this.emoji,
    required this.instruction,
    required this.examples,
    required this.color,
  });
}
