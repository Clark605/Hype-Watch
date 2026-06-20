import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/core/theme/app_fonts.dart';
import 'package:world_cup_watch/core/utils/scorerers_json_normalizer.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/match_details_widgets/team_column.dart';

class ScoreHero extends StatelessWidget {
  const ScoreHero({
    super.key,
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
  });

  final Match match;
  final Team homeTeam;
  final Team awayTeam;

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
          child: Column(
            children: [
              Row(
                children: [
                  // Home team
                  Expanded(child: TeamColumn(team: homeTeam)),
                  // Score / VS
                  Expanded(
                    child: Column(
                      children: [
                        if (match.finished &&
                            match.homeScore != null &&
                            match.awayScore != null)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '${match.homeScore}',
                                style: AppFonts.font48black900,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  '–',
                                  style: AppFonts.font32secondary300,
                                ),
                              ),
                              Text(
                                '${match.awayScore}',
                                style: AppFonts.font48black900,
                              ),
                            ],
                          )
                        else
                          Text('VS', style: AppFonts.font28secondary900),
                        const SizedBox(height: 8),
                        Text(
                          match.finished
                              ? 'FULL TIME'
                              : match.localDate.split(' ').first,
                          style: AppFonts.font10Secondary700,
                        ),
                      ],
                    ),
                  ),
                  // Away team
                  Expanded(child: TeamColumn(team: awayTeam)),
                ],
              ),

              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 48,
                children: [
                  Expanded(child: _getandDisplayScorers(match.homeScorers)),
                  Expanded(child: _getandDisplayScorers(match.awayScorers)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getandDisplayScorers(String? scorers) {
    List<String> displayText = [];
    List<Widget> scorerWidgets = [];
    if (scorers == null || scorers.isEmpty) {
      return SizedBox.shrink();
    }
    displayText = scorersJsonNormalizer(scorers);
    for (String scorer in displayText) {
      scorerWidgets.add(Text(scorer, style: AppFonts.font12Black700));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: scorerWidgets,
    );
  }
}
