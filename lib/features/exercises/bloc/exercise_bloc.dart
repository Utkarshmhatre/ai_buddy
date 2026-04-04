import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/ai/enhanced_gemini_service.dart';
import 'exercise_event_state.dart';

/// BLoC for managing AI-enhanced exercises
class ExerciseBloc extends Bloc<ExerciseEvent, ExerciseState> {
  final EnhancedGeminiService _aiService;
  
  ExerciseBloc({
    required EnhancedGeminiService aiService,
  })  : _aiService = aiService,
        super(const ExerciseInitial()) {
    on<LoadExerciseNarration>(_onLoadNarration);
    on<StartExercise>(_onStartExercise);
    on<NextExerciseStep>(_onNextStep);
    on<CompleteExercise>(_onComplete);
    on<ResetExercise>(_onReset);
  }
  
  Future<void> _onLoadNarration(
    LoadExerciseNarration event,
    Emitter<ExerciseState> emit,
  ) async {
    emit(const ExerciseLoadingNarration());
    
    try {
      final narration = await _aiService.generateExerciseNarration(
        exerciseType: event.exerciseType,
      );
      
      emit(ExerciseReady(narration: narration));
    } catch (e) {
      // Fall back to default narration on error
      final defaultNarration = _getDefaultNarration(event.exerciseType);
      emit(ExerciseReady(narration: defaultNarration));
    }
  }
  
  void _onStartExercise(
    StartExercise event,
    Emitter<ExerciseState> emit,
  ) {
    final currentState = state;
    if (currentState is! ExerciseReady) return;
    
    if (currentState.narration.steps.isEmpty) {
      emit(ExerciseError(message: 'No exercise steps available'));
      return;
    }
    
    emit(ExerciseInProgress(
      narration: currentState.narration,
      currentStepIndex: 0,
      currentStep: currentState.narration.steps[0],
      isLastStep: currentState.narration.steps.length == 1,
    ));
  }
  
  void _onNextStep(
    NextExerciseStep event,
    Emitter<ExerciseState> emit,
  ) {
    final currentState = state;
    if (currentState is! ExerciseInProgress) return;
    
    final nextIndex = currentState.currentStepIndex + 1;
    final steps = currentState.narration.steps;
    
    if (nextIndex >= steps.length) {
      // Exercise complete
      add(const CompleteExercise());
      return;
    }
    
    emit(ExerciseInProgress(
      narration: currentState.narration,
      currentStepIndex: nextIndex,
      currentStep: steps[nextIndex],
      isLastStep: nextIndex == steps.length - 1,
    ));
  }
  
  void _onComplete(
    CompleteExercise event,
    Emitter<ExerciseState> emit,
  ) {
    ExerciseNarration? narration;
    
    if (state is ExerciseInProgress) {
      narration = (state as ExerciseInProgress).narration;
    } else if (state is ExerciseReady) {
      narration = (state as ExerciseReady).narration;
    }
    
    // Use default narration if none available
    final finalNarration = narration ?? _getDefaultNarration('breathing');
    
    emit(ExerciseCompleted(
      narration: finalNarration,
      completionMessage: finalNarration.closing,
    ));
  }
  
  void _onReset(
    ResetExercise event,
    Emitter<ExerciseState> emit,
  ) {
    emit(const ExerciseInitial());
  }
  
  /// Default narration for when AI is unavailable
  ExerciseNarration _getDefaultNarration(String exerciseType) {
    switch (exerciseType) {
      case 'breathing':
      case '4-7-8':
        return _getDefaultBreathingNarration();
      case 'grounding':
      case '5-4-3-2-1':
        return _getDefaultGroundingNarration();
      default:
        return _getDefaultBreathingNarration();
    }
  }
  
  ExerciseNarration _getDefaultBreathingNarration() {
    return ExerciseNarration(
      title: '4-7-8 Breathing',
      exerciseType: 'breathing',
      introduction: "Let's practice the 4-7-8 breathing technique. This calming exercise helps activate your body's relaxation response.",
      steps: [
        ExerciseStep(
          instruction: "Find a comfortable position and let your shoulders relax.",
          duration: 5,
          cue: "Settle in",
        ),
        ExerciseStep(
          instruction: "Breathe in slowly through your nose for 4 seconds.",
          duration: 4,
          cue: "Inhale",
        ),
        ExerciseStep(
          instruction: "Hold your breath gently for 7 seconds.",
          duration: 7,
          cue: "Hold",
        ),
        ExerciseStep(
          instruction: "Exhale slowly through your mouth for 8 seconds.",
          duration: 8,
          cue: "Exhale",
        ),
      ],
      checkIn: "Notice how you're feeling now.",
      closing: "Excellent work! Take a moment to notice how you feel. This technique gets more effective with practice.",
      totalDurationSeconds: 24,
    );
  }
  
  ExerciseNarration _getDefaultGroundingNarration() {
    return ExerciseNarration(
      title: '5-4-3-2-1 Grounding',
      exerciseType: 'grounding',
      introduction: "Let's practice the 5-4-3-2-1 grounding technique. This exercise helps bring you back to the present moment.",
      steps: [
        ExerciseStep(
          instruction: "Look around and name 5 things you can SEE.",
          duration: 30,
          cue: "See",
        ),
        ExerciseStep(
          instruction: "Notice 4 things you can TOUCH.",
          duration: 25,
          cue: "Touch",
        ),
        ExerciseStep(
          instruction: "Listen for 3 things you can HEAR.",
          duration: 20,
          cue: "Hear",
        ),
        ExerciseStep(
          instruction: "Identify 2 things you can SMELL.",
          duration: 15,
          cue: "Smell",
        ),
        ExerciseStep(
          instruction: "Notice 1 thing you can TASTE.",
          duration: 10,
          cue: "Taste",
        ),
      ],
      checkIn: "You're doing great. Stay present.",
      closing: "You've successfully grounded yourself in the present moment. Notice how your body feels now compared to before.",
      totalDurationSeconds: 100,
    );
  }
}
