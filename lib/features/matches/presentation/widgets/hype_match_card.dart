import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/match_card.dart';

class HypeMatchCard extends StatelessWidget {
  final MatchCard matchCard;

  const HypeMatchCard({super.key, required this.matchCard});

  @override
  Widget build(BuildContext context) {
    final isHighHype = matchCard.hypeScore >= 8.0;
    final isLiveOrToday = matchCard.isToday && !matchCard.isFinished;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: isHighHype
            ? [
                BoxShadow(
                  color: AppColors.tertiaryFixed.withValues(alpha: 0.2),
                  blurRadius: 20,
                  spreadRadius: 0,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isHighHype
                    ? AppColors.tertiaryFixed.withValues(alpha: 0.2)
                    : AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(isLiveOrToday),
                const SizedBox(height: 24),
                _buildTeams(isLiveOrToday),
                if (matchCard.reasons.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  _buildReasonBadge(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(bool isLive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLive)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.errorContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'MATCHDAY', // Mock static for live text since we don't have minute
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.onErrorContainer,
                  ),
                ),
              ],
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  // Can format the date nicely here, let's keep it simple
                  matchCard.match.localDate.split(' ').first,
                  style: const TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        Transform.rotate(
          angle: matchCard.hypeScore >= 9.0 ? 0.05 : 0,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: matchCard.hypeScore >= 8.0
                  ? (matchCard.hypeScore >= 9.5
                        ? AppColors.secondaryFixed
                        : AppColors.tertiaryFixed)
                  : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(8),
              border: matchCard.hypeScore < 8.0
                  ? Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    )
                  : null,
              boxShadow: matchCard.hypeScore >= 9.5
                  ? [
                      BoxShadow(
                        color: AppColors.tertiaryFixed.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Column(
              children: [
                Text(
                  matchCard.hypeScore.toStringAsFixed(1),
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                    color: matchCard.hypeScore >= 8.0
                        ? (matchCard.hypeScore >= 9.5
                              ? AppColors.onSecondaryFixed
                              : AppColors.onTertiaryFixed)
                        : AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'HYPE',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2.0,
                    color: matchCard.hypeScore >= 8.0
                        ? (matchCard.hypeScore >= 9.5
                              ? AppColors.onSecondaryFixed
                              : AppColors.onTertiaryFixedVariant)
                        : AppColors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTeams(bool isLive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: _buildTeamCol(matchCard.homeFlag, matchCard.homeTeam.nameEn),
        ),
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child: Text(
              matchCard.isFinished ? 'FT' : 'VS',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: matchCard.isFinished
                    ? AppColors.onSurface
                    : AppColors.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
        Expanded(
          child: _buildTeamCol(matchCard.awayFlag, matchCard.awayTeam.nameEn),
        ),
      ],
    );
  }

  Widget _buildTeamCol(String flagUrl, String code) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              flagUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.surfaceVariant),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          code,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildReasonBadge() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.local_fire_department,
            color: AppColors.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hype Factors',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  matchCard.reasons.join(' • '),
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
