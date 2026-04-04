import 'package:equatable/equatable.dart';

import '../../../core/ai/enhanced_gemini_service.dart';

/// Events for ExerciseBloc
abstract class ExerciseEvent extends Equatable {
  const ExerciseEvent();
  
  @override
  List<Object?> get props => [];
}

/// Load AI narration for an exercise
class LoadExerciseNarration extends ExerciseEvent {
  final String exerciseType;
  final String? userMood;
  
  const LoadExerciseNarration({
    required this.exerciseType,
    this.userMood,
  });
  
  @override
  List<Object?> get props => [exerciseType, userMood];
}

/// Start the exercise
class StartExercise extends ExerciseEvent {
  const StartExercise();
}

/// Advance to next step
class NextExerciseStep extends ExerciseEvent {
  const NextExerciseStep();
}

/// Complete exercise
class CompleteExercise extends ExerciseEvent {
  const CompleteExercise();
}

/// Reset exercise
class ResetExercise extends ExerciseEvent {
  const ResetExercise();
}

/// States for ExerciseBloc
abstract class ExerciseState extends Equatable {
  const ExerciseState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state
class ExerciseInitial extends ExerciseState {
  const ExerciseInitial();
}

/// Loading AI narration
class ExerciseLoadingNarration extends ExerciseState {
  const ExerciseLoadingNarration();
}

/// Exercise ready to start
class ExerciseReady extends ExerciseState {
  final ExerciseNarration narration;
  
  const ExerciseReady({required this.narration});
  
  @override
  List<Object?> get props => [narration];
}

/// Exercise in progress
class ExerciseInProgress extends ExerciseState {
  final ExerciseNarration narration;
  final int currentStepIndex;
  final ExerciseStep currentStep;
  final bool isLastStep;
  
  const ExerciseInProgress({
    required this.narration,
    required this.currentStepIndex,
    required this.currentStep,
    required this.isLastStep,
  });
  
  @override
  List<Object?> get props => [narration, currentStepIndex, currentStep, isLastStep];
}

/// Exercise completed
class ExerciseCompleted extends ExerciseState {
  final ExerciseNarration narration;
  final String completionMessage;
  
  const ExerciseCompleted({
    required this.narration,
    required this.completionMessage,
  });
  
  @override
  List<Object?> get props => [narration, completionMessage];
}

/// Error state
class ExerciseError extends ExerciseState {
  final String message;
  
  const ExerciseError({required this.message});
  
  @override
  List<Object?> get props => [message];
}
