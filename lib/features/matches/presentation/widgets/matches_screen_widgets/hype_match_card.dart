import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/core/theme/app_fonts.dart';
import 'package:world_cup_watch/features/matches/data/repo/matches_repo.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/match_card.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/match_details_cubit.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/matches_cubit.dart';
import 'package:world_cup_watch/features/matches/presentation/screens/match_details_screen.dart';

class HypeMatchCard extends StatelessWidget {
  final MatchCard matchCard;

  const HypeMatchCard({super.key, required this.matchCard});

  // ── Navigation ────────────────────────────────────────────────────────────────
  void _openDetails(BuildContext context) {
    // Pull cached groups + teams from MatchesCubit's state so we don't re-fetch
    final matchesCubit = context.read<MatchesCubit>();
    final groups = matchesCubit.cachedGroups;
    final teams = matchesCubit.cachedTeams;
    final repository = context.read<MatchesRepository>();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) =>
              MatchDetailsCubit(repository: repository, match: matchCard.match),
          child: MatchDetailsScreen(
            match: matchCard.match,
            homeTeam: matchCard.homeTeam,
            awayTeam: matchCard.awayTeam,
            groups: groups,
            teams: teams,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isHighHype = matchCard.hypeScore >= 8.0;
    final isLiveOrToday =
        matchCard.match.timeElapsed == 'live' || matchCard.isToday;

    return GestureDetector(
      onTap: () => _openDetails(context),
      child: Container(
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
      ),
    );
  }

  Widget _buildHeader(bool isLive) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                  ),
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
                    Text('MATCHDAY', style: AppFonts.font12Red700),
                  ],
                ),
              )
            else
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
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
                          matchCard.match.localDate.split(' ').first,
                          style: AppFonts.font12Red700.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
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
                        Icons.emoji_events_outlined,
                        size: 16,
                        color: AppColors.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        matchCard.match.matchday != null
                            ? 'Round ${matchCard.match.matchday}'
                            : matchCard.match.stage,
                        style: AppFonts.font12Red700.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainer,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    matchCard.match.group ?? 'Knockout',
                    style: AppFonts.font12Red700.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ],
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
                  style: AppFonts.font18Black800.copyWith(
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
                  style: AppFonts.font10Secondary700.copyWith(
                    color: matchCard.hypeScore >= 8.0
                        ? (matchCard.hypeScore >= 9.5
                              ? AppColors.onSecondaryFixed
                              : AppColors.onTertiaryFixed)
                        : AppColors.onSurfaceVariant,
                    letterSpacing: 2.0,
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
        // ── Center: score if finished, VS if upcoming ──────────────────────────
        Expanded(
          child: Container(
            alignment: Alignment.center,
            child:
                matchCard.isFinished &&
                    matchCard.homeScore != null &&
                    matchCard.awayScore != null
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${matchCard.homeScore}',
                            style: AppFonts.font32Black800,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 6),
                            child: Text('–', style: AppFonts.font32Black800),
                          ),
                          Text(
                            '${matchCard.awayScore}',
                            style: AppFonts.font32Black800,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('FT', style: AppFonts.font10Secondary700),
                    ],
                  )
                : Text('VS', style: AppFonts.font28secondary900),
          ),
        ),
        Expanded(
          child: _buildTeamCol(matchCard.awayFlag, matchCard.awayTeam.nameEn),
        ),
      ],
    );
  }

  Widget _buildTeamCol(String flagUrl, String name) {
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
            child: CachedNetworkImage(
              imageUrl: flagUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceContainerLow,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.brandRed,
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceContainerLow,
                child: const Icon(
                  Icons.flag_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(name, style: AppFonts.font15Black700, textAlign: TextAlign.center),
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
                Text('Hype Factors', style: AppFonts.font13Black700),
                const SizedBox(height: 4),
                Text(
                  matchCard.reasons.join(' • '),
                  style: AppFonts.font11Secondary700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
