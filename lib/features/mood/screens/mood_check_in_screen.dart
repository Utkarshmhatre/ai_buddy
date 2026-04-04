import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/models/mood_entry.dart';
import '../bloc/mood_bloc.dart';
import '../bloc/mood_event.dart';

/// Full-screen mood check-in flow
class MoodCheckInScreen extends StatefulWidget {
  const MoodCheckInScreen({super.key});

  @override
  State<MoodCheckInScreen> createState() => _MoodCheckInScreenState();
}

class _MoodCheckInScreenState extends State<MoodCheckInScreen> {
  int _currentStep = 0;
  MoodCategory? _selectedMood;
  MoodIntensity _intensity = MoodIntensity.neutral;
  final _notesController = TextEditingController();
  final List<String> _selectedTriggers = [];

  final _triggers = [
    ('💼', 'Work'),
    ('👥', 'Social'),
    ('😴', 'Sleep'),
    ('🏃', 'Exercise'),
    ('🍽️', 'Food'),
    ('💰', 'Money'),
    ('❤️', 'Relationship'),
    ('🏠', 'Home'),
    ('🌦️', 'Weather'),
    ('📱', 'News'),
    ('🎯', 'Goals'),
    ('🤷', 'Unknown'),
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      HapticFeedback.lightImpact();
      setState(() => _currentStep++);
    } else {
      _saveMoodEntry();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.pop();
    }
  }

  void _saveMoodEntry() {
    if (_selectedMood == null) return;
    
    // Save via BLoC
    context.read<MoodBloc>().add(LogMood(
      category: _selectedMood!,
      intensity: _intensity,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      triggers: _selectedTriggers.isNotEmpty ? List.from(_selectedTriggers) : null,
    ));
    
    HapticFeedback.mediumImpact();
    
    // Show success and close
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Text(_selectedMood!.emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            const Text('Mood logged! Keep it up 💪'),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with progress
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _previousStep,
                    icon: Icon(
                      _currentStep == 0 
                          ? Icons.close_rounded 
                          : Icons.arrow_back_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _ProgressIndicator(
                      currentStep: _currentStep,
                      totalSteps: 3,
                    ),
                  ),
                  const SizedBox(width: 12),
                  SizedBox(width: 48), // Balance the close button
                ],
              ),
            ),
            
            // Content
            Expanded(
              child: AnimatedSwitcher(
                duration: 300.ms,
                child: _buildCurrentStep(),
              ),
            ),
            
            // Bottom button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  onPressed: _canProceed() ? _nextStep : null,
                  child: Text(
                    _currentStep == 2 ? 'Save Check-In' : 'Continue',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedMood != null;
      case 1:
        return true; // Intensity always has a value
      case 2:
        return true; // Notes are optional
      default:
        return false;
    }
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _MoodSelectionStep(
          key: const ValueKey('mood'),
          selectedMood: _selectedMood,
          onMoodSelected: (mood) {
            HapticFeedback.selectionClick();
            setState(() => _selectedMood = mood);
          },
        );
      case 1:
        return _IntensityStep(
          key: const ValueKey('intensity'),
          mood: _selectedMood!,
          intensity: _intensity,
          onIntensityChanged: (intensity) {
            setState(() => _intensity = intensity);
          },
        );
      case 2:
        return _NotesStep(
          key: const ValueKey('notes'),
          mood: _selectedMood!,
          controller: _notesController,
          selectedTriggers: _selectedTriggers,
          triggers: _triggers,
          onTriggerToggled: (trigger) {
            setState(() {
              if (_selectedTriggers.contains(trigger)) {
                _selectedTriggers.remove(trigger);
              } else {
                _selectedTriggers.add(trigger);
              }
            });
          },
        );
      default:
        return const SizedBox();
    }
  }
}

class _ProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const _ProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: List.generate(totalSteps, (index) {
        final isActive = index <= currentStep;
        return Expanded(
          child: Container(
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: isActive 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

class _MoodSelectionStep extends StatelessWidget {
  final MoodCategory? selectedMood;
  final ValueChanged<MoodCategory> onMoodSelected;

  const _MoodSelectionStep({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How are you feeling?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
          const SizedBox(height: 8),
          Text(
            'Select the emotion that best describes your current state.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          const SizedBox(height: 32),
          
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemCount: MoodCategory.values.length,
              itemBuilder: (context, index) {
                final mood = MoodCategory.values[index];
                final isSelected = mood == selectedMood;
                
                return _MoodCard(
                  mood: mood,
                  isSelected: isSelected,
                  onTap: () => onMoodSelected(mood),
                ).animate(delay: (50 * index).ms).fadeIn().scale(
                  begin: const Offset(0.8, 0.8),
                  duration: 300.ms,
                  curve: Curves.easeOutBack,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _MoodCard extends StatelessWidget {
  final MoodCategory mood;
  final bool isSelected;
  final VoidCallback onTap;

  const _MoodCard({
    required this.mood,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodColor = Color(mood.colors.first);
    
    return Material(
      color: isSelected 
          ? moodColor.withValues(alpha: 0.2) 
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected 
                  ? moodColor 
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                mood.emoji,
                style: TextStyle(fontSize: isSelected ? 36 : 32),
              ),
              const SizedBox(height: 8),
              Text(
                mood.label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? moodColor : null,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntensityStep extends StatelessWidget {
  final MoodCategory mood;
  final MoodIntensity intensity;
  final ValueChanged<MoodIntensity> onIntensityChanged;

  const _IntensityStep({
    super.key,
    required this.mood,
    required this.intensity,
    required this.onIntensityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final moodColor = Color(mood.colors.first);
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How intense is this feeling?',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(mood.emoji, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                'Feeling ${mood.label.toLowerCase()}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          
          const Spacer(),
          
          // Intensity display
          Center(
            child: Column(
              children: [
                Text(
                  mood.emoji,
                  style: TextStyle(fontSize: 64 + (intensity.value * 8)),
                ).animate(
                  onPlay: (c) => c.repeat(reverse: true),
                ).scale(
                  begin: const Offset(1, 1),
                  end: Offset(1 + (intensity.value * 0.05), 1 + (intensity.value * 0.05)),
                  duration: 1500.ms,
                ),
                const SizedBox(height: 16),
                Text(
                  intensity.label,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: moodColor,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          
          const Spacer(),
          
          // Slider
          Column(
            children: [
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: moodColor,
                  inactiveTrackColor: moodColor.withValues(alpha: 0.2),
                  thumbColor: moodColor,
                  overlayColor: moodColor.withValues(alpha: 0.2),
                  trackHeight: 8,
                ),
                child: Slider(
                  value: intensity.value.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  onChanged: (value) {
                    final newIntensity = MoodIntensity.values[value.toInt() - 1];
                    onIntensityChanged(newIntensity);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Subtle',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Intense',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _NotesStep extends StatelessWidget {
  final MoodCategory mood;
  final TextEditingController controller;
  final List<String> selectedTriggers;
  final List<(String, String)> triggers;
  final ValueChanged<String> onTriggerToggled;

  const _NotesStep({
    super.key,
    required this.mood,
    required this.controller,
    required this.selectedTriggers,
    required this.triggers,
    required this.onTriggerToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's contributing?",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.2),
          const SizedBox(height: 8),
          Text(
            'Select any factors or add notes (optional)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
          const SizedBox(height: 24),
          
          // Triggers grid
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: triggers.map((trigger) {
              final isSelected = selectedTriggers.contains(trigger.$2);
              return _TriggerChip(
                emoji: trigger.$1,
                label: trigger.$2,
                isSelected: isSelected,
                onTap: () => onTriggerToggled(trigger.$2),
              );
            }).toList(),
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          
          const SizedBox(height: 24),
          
          // Notes field
          TextField(
            controller: controller,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Anything else you'd like to note...",
              filled: true,
              fillColor: theme.colorScheme.surfaceContainerHighest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          
          const SizedBox(height: 100), // Space for keyboard
        ],
      ),
    );
  }
}

class _TriggerChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _TriggerChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Material(
      color: isSelected 
          ? theme.colorScheme.primaryContainer 
          : theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected 
                  ? theme.colorScheme.primary 
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: isSelected 
                      ? theme.colorScheme.onPrimaryContainer 
                      : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
