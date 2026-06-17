import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/core/theme/app_fonts.dart';
import 'package:world_cup_watch/features/matches/presentation/screens/match_details_screen.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/match_details_widgets/team_column.dart';

class ScoreHero extends StatelessWidget {
  const ScoreHero({
    super.key,
    required this.widget,
    required this.isFinished,
    required this.homeScore,
    required this.awayScore,
  });

  final MatchDetailsScreen widget;
  final bool isFinished;
  final int? homeScore;
  final int? awayScore;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              // Home team
              Expanded(child: TeamColumn(team: widget.homeTeam)),
              // Score / VS
              Expanded(
                child: Column(
                  children: [
                    if (isFinished && homeScore != null && awayScore != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$homeScore', style: AppFonts.font48black900),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '–',
                              style: AppFonts.font32secondary300,
                            ),
                          ),
                          Text('$awayScore', style: AppFonts.font48black900),
                        ],
                      )
                    else
                      Text('VS', style: AppFonts.font28secondary900),
                    const SizedBox(height: 8),
                    Text(
                      isFinished
                          ? 'FULL TIME'
                          : widget.match.localDate.split(' ').first,
                      style: AppFonts.font10Secondary700,
                    ),
                  ],
                ),
              ),
              // Away team
              Expanded(child: TeamColumn(team: widget.awayTeam)),
            ],
          ),
        ),
      ),
    );
  }
}
