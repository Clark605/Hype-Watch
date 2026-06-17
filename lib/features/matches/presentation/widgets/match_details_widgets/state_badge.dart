import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/core/theme/app_fonts.dart';
import 'package:world_cup_watch/features/matches/presentation/screens/match_details_screen.dart';

class StateBadge extends StatelessWidget {
  const StateBadge({
    super.key,
    required this.isKnockout,
    required this.label,
    required this.widget,
  });

  final bool isKnockout;
  final String label;
  final MatchDetailsScreen widget;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isKnockout
                ? AppColors.activeBackground
                : AppColors.cardBackgroundElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isKnockout
                  ? AppColors.brandRed.withValues(alpha: 0.3)
                  : AppColors.border.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: AppFonts.font11Secondary700.copyWith(
              color: isKnockout ? AppColors.brandRed : AppColors.textSecondary,
              letterSpacing: 1.2,
            ),
          ),
        ),
        if (widget.match.matchday != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'MATCHDAY ${widget.match.matchday}',
              style: AppFonts.font11Secondary700,
            ),
          ),
        ],
      ],
    );
  }
}
