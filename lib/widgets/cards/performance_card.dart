import 'package:flutter/material.dart';

import '../../models/exercise_record.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text.dart';
import '../common/gym_card.dart';

class PerformanceCard extends StatelessWidget {
  final ExerciseRecord record;

  const PerformanceCard({
    super.key,
    required this.record,
  });

  @override
  Widget build(BuildContext context) {
    if (record.bestEstimated1RM == 0) {
      return GYMCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Row(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: AppColors.warning,
                ),
                SizedBox(width: 8),
                Text(
                  "PERSONAL RECORD",
                  style: AppText.heading3,
                ),
              ],
            ),
            SizedBox(height: 20),
            Text(
              "No records yet",
              style: AppText.bodySecondary,
            ),
            SizedBox(height: 6),
            Text(
              "Complete your first set to create your first personal record.",
              style: AppText.caption,
            ),
          ],
        ),
      );
    }

    return GYMCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.emoji_events,
                color: AppColors.warning,
              ),
              SizedBox(width: 8),
              Text(
                "PERSONAL RECORD",
                style: AppText.heading3,
              ),
            ],
          ),

          const SizedBox(height: 24),

          Text(
            "${record.bestSetWeight.toStringAsFixed(record.bestSetWeight % 1 == 0 ? 0 : 1)} kg × ${record.bestSetReps}",
            style: AppText.display,
          ),

          const SizedBox(height: 20),

          const Text(
            "Estimated 1RM",
            style: AppText.caption,
          ),

          const SizedBox(height: 4),

          Text(
            "${record.bestEstimated1RM.toStringAsFixed(1)} kg",
            style: AppText.heading2,
          ),

          if (record.bestSetDate != null) ...[
            const SizedBox(height: 20),

            const Text(
              "Achieved",
              style: AppText.caption,
            ),

            const SizedBox(height: 4),

            Text(
              "${record.bestSetDate!.day}/${record.bestSetDate!.month}/${record.bestSetDate!.year}",
              style: AppText.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}