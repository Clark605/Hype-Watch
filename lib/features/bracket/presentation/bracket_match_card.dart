import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/core/theme/app_fonts.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';

class BracketMatchCard extends StatelessWidget {
  final Match match;
  final Team? homeTeam;
  final Team? awayTeam;

  const BracketMatchCard({
    super.key,
    required this.match,
    this.homeTeam,
    this.awayTeam,
  });

  @override
  Widget build(BuildContext context) {
    final homeLabel =
        homeTeam?.nameEn ??
        (match.homeTeamLabel!.contains('Winner Match')
            ? "TBD"
            : match.homeTeamLabel);
    final awayLabel =
        awayTeam?.nameEn ??
        (match.awayTeamLabel!.contains('Winner Match')
            ? "TBD"
            : match.awayTeamLabel);

    final dateStr = match.localDate.split(' ').first;

    return Container(
      width: 180,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.45)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            dateStr,
            style: AppFonts.font10Secondary700.copyWith(letterSpacing: 0.3),
          ),
          const SizedBox(height: 10),
          _TeamRow(
            flag: homeTeam?.flag,
            label: homeLabel!,
            score: match.finished ? match.homeScore : null,
            isWinner: _isHomeWinner,
          ),
          const SizedBox(height: 6),
          Divider(height: 1, color: AppColors.border.withValues(alpha: 0.4)),
          const SizedBox(height: 6),
          _TeamRow(
            flag: awayTeam?.flag,
            label: awayLabel!,
            score: match.finished ? match.awayScore : null,
            isWinner: _isAwayWinner,
          ),
        ],
      ),
    );
  }

  bool get _isHomeWinner =>
      match.finished &&
      match.homeScore != null &&
      match.awayScore != null &&
      match.homeScore! > match.awayScore!;

  bool get _isAwayWinner =>
      match.finished &&
      match.homeScore != null &&
      match.awayScore != null &&
      match.awayScore! > match.homeScore!;
}

class _TeamRow extends StatelessWidget {
  final String? flag;
  final String label;
  final int? score;
  final bool isWinner;

  const _TeamRow({
    this.flag,
    required this.label,
    this.score,
    this.isWinner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: flag != null
              ? ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: flag!,
                    fit: BoxFit.cover,
                    placeholder: (_, _) =>
                        Container(color: AppColors.cardBackgroundElevated),
                    errorWidget: (_, _, _) => const Icon(
                      Icons.shield_outlined,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                )
              : const Icon(
                  Icons.shield_outlined,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: AppFonts.font12Black700.copyWith(
              fontWeight: isWinner ? FontWeight.w700 : FontWeight.w400,
              color: isWinner ? AppColors.textPrimary : AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        if (score != null) ...[
          const SizedBox(width: 4),
          Text(
            '$score',
            style: AppFonts.font12Black700.copyWith(
              fontWeight: isWinner ? FontWeight.w700 : FontWeight.w400,
              color: isWinner ? AppColors.brandRed : AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
