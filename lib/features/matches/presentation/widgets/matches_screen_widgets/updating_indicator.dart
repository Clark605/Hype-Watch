import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';

/// Small indicator shown at the top while a background refresh is in progress.
class UpdatingIndicator extends StatelessWidget {
  const UpdatingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.brandRed.withValues(alpha: 0.1),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.brandRed,
            ),
          ),
          const SizedBox(width: 8),
          const Text(
            'Updating...',
            style: TextStyle(color: AppColors.brandRed, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
