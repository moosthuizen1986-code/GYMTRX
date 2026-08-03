import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';

class ExerciseHeader extends StatelessWidget {
  final String exerciseName;
  final String workoutName;

  const ExerciseHeader({
    super.key,
    required this.exerciseName,
    required this.workoutName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            exerciseName,
            style: AppText.heading1,
          ),

          const SizedBox(height: 6),

          Text(
            "Workout • $workoutName",
            style: AppText.bodySecondary,
          ),

          const SizedBox(height: 8),

          const Divider(
            color: AppColors.divider,
            height: 1,
          ),
        ],
      ),
    );
  }
}