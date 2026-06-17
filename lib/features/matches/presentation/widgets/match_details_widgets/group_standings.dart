import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/core/theme/app_fonts.dart';
import 'package:world_cup_watch/features/matches/data/models/group_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';
import 'package:world_cup_watch/features/matches/presentation/screens/match_details_screen.dart';

class GroupStandings extends StatelessWidget {
  const GroupStandings({
    super.key,
    required this.sorted,
    required this.widget,
    required this.group,
    required this.teamById,
  });

  final List<GroupTeamStanding> sorted;
  final MatchDetailsScreen widget;
  final Groups group;
  final Map<String, Team> teamById;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          group.name?.toUpperCase() ?? 'GROUP STANDINGS',
          style: AppFonts.font11Secondary700,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              // Header row
              StandingsHeader(),
              const Divider(height: 1, color: AppColors.border),
              // Team rows
              ...sorted.asMap().entries.map((entry) {
                final pos = entry.key + 1;
                final standing = entry.value;
                final team = teamById[standing.teamId];
                final isMatchTeam =
                    standing.teamId == widget.match.homeTeamId ||
                    standing.teamId == widget.match.awayTeamId;
                return Column(
                  children: [
                    _StandingRow(
                      position: pos,
                      team: team,
                      standing: standing,
                      isHighlighted: isMatchTeam,
                    ),
                    if (pos < sorted.length)
                      const Divider(
                        height: 1,
                        indent: 16,
                        endIndent: 16,
                        color: AppColors.border,
                      ),
                  ],
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Standings header ──────────────────────────────────────────────────────────
class StandingsHeader extends StatelessWidget {
  const StandingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: const [
          SizedBox(width: 24), // position
          SizedBox(width: 12),
          Expanded(child: SizedBox()), // team name
          _HeaderCell('MP'),
          _HeaderCell('W'),
          _HeaderCell('D'),
          _HeaderCell('L'),
          _HeaderCell('GF'),
          _HeaderCell('GA'),
          _HeaderCell('GD'),
          _HeaderCell('PTS'),
        ],
      ),
    );
  }
}

class _HeaderCell extends StatelessWidget {
  final String text;
  const _HeaderCell(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 28,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppFonts.font10Secondary700,
      ),
    );
  }
}

// ── Single standings row ──────────────────────────────────────────────────────
class _StandingRow extends StatelessWidget {
  final int position;
  final Team? team;
  final GroupTeamStanding standing;
  final bool isHighlighted;

  const _StandingRow({
    required this.position,
    required this.team,
    required this.standing,
    required this.isHighlighted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isHighlighted
          ? AppColors.selectedButtonBorder.withValues(alpha: 0.25)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$position',
              style: AppFonts.font12Black700.copyWith(
                color: isHighlighted
                    ? AppColors.brandRed
                    : AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              children: [
                if (team != null)
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: ClipOval(
                      child: Image.network(
                        team!.flag,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            Container(color: AppColors.cardBackgroundElevated),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    team?.nameEn ?? standing.teamId,
                    style: AppFonts.font12Black700.copyWith(
                      fontWeight: isHighlighted
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          _StatCell('${standing.matchesPlayed}'),
          _StatCell('${standing.won}'),
          _StatCell('${standing.drawn}'),
          _StatCell('${standing.lost}'),
          _StatCell('${standing.goalsFor}'),
          _StatCell('${standing.goalsAgainst}'),
          _StatCell(
            standing.goalDifference >= 0
                ? '+${standing.goalDifference}'
                : '${standing.goalDifference}',
            colored: true,
            positive: standing.goalDifference >= 0,
          ),
          _StatCell('${standing.points}', bold: true),
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final String text;
  final bool bold;
  final bool colored;
  final bool positive;

  const _StatCell(
    this.text, {
    this.bold = false,
    this.colored = false,
    this.positive = true,
  });

  @override
  Widget build(BuildContext context) {
    Color color = AppColors.textPrimary;
    if (colored) {
      color = positive ? AppColors.tertiary : AppColors.error;
    }

    return SizedBox(
      width: 28,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: AppFonts.font12Black700.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color,
        ),
      ),
    );
  }
}
