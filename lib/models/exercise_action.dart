enum ExerciseActionType {
  next,
  rest,
  finished,
}

class ExerciseAction {
  final ExerciseActionType type;
  final String? nextExercise;

  const ExerciseAction.next(this.nextExercise)
      : type = ExerciseActionType.next;

  const ExerciseAction.rest()
      : type = ExerciseActionType.rest,
        nextExercise = null;

  const ExerciseAction.finished()
      : type = ExerciseActionType.finished,
        nextExercise = null;
}