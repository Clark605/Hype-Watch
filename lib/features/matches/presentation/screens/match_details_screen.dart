import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/features/matches/data/models/group_model.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/stadium_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/match_details_cubit.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/match_details_state.dart';

class MatchDetailsScreen extends StatefulWidget {
  final Match match;
  final Team homeTeam;
  final Team awayTeam;

  /// Pre-loaded groups from MatchesCubit — no re-fetch needed.
  final List<Groups> groups;

  /// Pre-loaded teams from MatchesCubit — no re-fetch needed.
  final List<Team> teams;

  const MatchDetailsScreen({
    super.key,
    required this.match,
    required this.homeTeam,
    required this.awayTeam,
    required this.groups,
    required this.teams,
  });

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MatchDetailsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: BlocBuilder<MatchDetailsCubit, MatchDetailsState>(
              builder: (context, state) {
                if (state is MatchDetailsLoading) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    ),
                  );
                }
                if (state is MatchDetailsError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        state.message,
                        style: const TextStyle(
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  );
                }
                if (state is MatchDetailsLoaded) {
                  return _buildContent(context, state);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── App Bar ───────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppColors.background.withValues(alpha: 0.92),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        'Match Details',
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppColors.onSurface,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.outlineVariant.withValues(alpha: 0.2),
        ),
      ),
    );
  }

  // ── Main content ──────────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context, MatchDetailsLoaded state) {
    print("state.toString(): ${state.stadium?.nameEn}");
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          // ── Stage badge ────────────────────────────────────────────────────
          _buildStageBadge(widget.match.stage, widget.match.group),
          const SizedBox(height: 24),
          // ── Score / Teams hero ─────────────────────────────────────────────
          _buildScoreHero(),
          const SizedBox(height: 32),
          // ── Stadium section (only if data available) ───────────────────────
          if (state.stadium != null) ...[
            _buildStadiumCard(state.stadium!),
            const SizedBox(height: 32),
          ],
          // ── Group standings (only for group-stage matches) ─────────────────
          if (state.group != null) ...[
            _buildGroupStandings(state.group!, state.teamById),
            const SizedBox(height: 32),
          ],
        ],
      ),
    );
  }

  // ── Stage badge ───────────────────────────────────────────────────────────────
  Widget _buildStageBadge(String stage, String? groupName) {
    final label = _stageLabel(stage, groupName);
    final isKnockout = stage.toLowerCase() != 'group';

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: isKnockout
                ? AppColors.primaryFixed
                : AppColors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isKnockout
                  ? AppColors.primary.withValues(alpha: 0.3)
                  : AppColors.outlineVariant.withValues(alpha: 0.4),
            ),
          ),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: isKnockout
                  ? AppColors.primary
                  : AppColors.onSurfaceVariant,
            ),
          ),
        ),
        if (widget.match.matchday != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              'MATCHDAY ${widget.match.matchday}',
              style: const TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }

  String _stageLabel(String stage, String? groupName) {
    switch (stage.toLowerCase()) {
      case 'group':
        return groupName ?? 'Group Stage';
      case 'round_of_32':
        return 'Round of 32';
      case 'round_of_16':
        return 'Round of 16';
      case 'quarter_final':
        return 'Quarter Final';
      case 'semi_final':
        return 'Semi Final';
      case 'final':
        return 'Final';
      default:
        return stage;
    }
  }

  // ── Score hero ────────────────────────────────────────────────────────────────
  Widget _buildScoreHero() {
    final isFinished = widget.match.finished;
    final homeScore = widget.match.homeScore;
    final awayScore = widget.match.awayScore;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              // Home team
              Expanded(child: _buildTeamCol(widget.homeTeam)),
              // Score / VS
              Expanded(
                child: Column(
                  children: [
                    if (isFinished && homeScore != null && awayScore != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$homeScore',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.onSurface,
                              height: 1.0,
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              '–',
                              style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 32,
                                fontWeight: FontWeight.w300,
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                          Text(
                            '$awayScore',
                            style: const TextStyle(
                              fontFamily: 'Montserrat',
                              fontSize: 48,
                              fontWeight: FontWeight.w900,
                              color: AppColors.onSurface,
                              height: 1.0,
                            ),
                          ),
                        ],
                      )
                    else
                      const Text(
                        'VS',
                        style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      isFinished
                          ? 'FULL TIME'
                          : widget.match.localDate.split(' ').first,
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Away team
              Expanded(child: _buildTeamCol(widget.awayTeam)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCol(Team team) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.outline.withValues(alpha: 0.25),
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.network(
              team.flag,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(color: AppColors.surfaceVariant),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          team.nameEn,
          style: const TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.onSurface,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ── Stadium card ──────────────────────────────────────────────────────────────
  Widget _buildStadiumCard(Stadium stadium) {
    print('Building stadium card for ${stadium.nameEn}');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(label: 'VENUE'),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primaryFixed,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.stadium_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stadium.nameEn ?? 'Unknown Stadium',
                      style: const TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stadium.cityEn}, ${stadium.countryEn}',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    if (stadium.capacity != null && stadium.capacity! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_formatCapacity(stadium.capacity ?? 0)} capacity',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          color: AppColors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCapacity(int cap) {
    if (cap >= 1000) {
      return '${(cap / 1000).toStringAsFixed(0)}k';
    }
    return cap.toString();
  }

  // ── Group standings ───────────────────────────────────────────────────────────
  Widget _buildGroupStandings(Groups group, Map<String, Team> teamById) {
    final standings = group.teams ?? [];
    if (standings.isEmpty) return const SizedBox.shrink();

    // Sort by points desc, then goal difference desc
    final sorted = [...standings]
      ..sort((a, b) {
        final pts = b.points.compareTo(a.points);
        if (pts != 0) return pts;
        return b.goalDifference.compareTo(a.goalDifference);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label: group.name?.toUpperCase() ?? 'GROUP STANDINGS'),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainer.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.outlineVariant.withValues(alpha: 0.3),
            ),
          ),
          child: Column(
            children: [
              // Header row
              _StandingsHeader(),
              const Divider(height: 1, color: AppColors.outlineVariant),
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
                        color: AppColors.outlineVariant,
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

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontFamily: 'JetBrains Mono',
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.5,
        color: AppColors.onSurfaceVariant,
      ),
    );
  }
}

// ── Standings header ──────────────────────────────────────────────────────────
class _StandingsHeader extends StatelessWidget {
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
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: AppColors.onSurfaceVariant,
        ),
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
    final displayName = team?.nameEn ?? standing.teamId;

    return Container(
      color: isHighlighted
          ? AppColors.secondaryFixed.withValues(alpha: 0.25)
          : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text(
              '$position',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isHighlighted
                    ? AppColors.primary
                    : AppColors.onSurfaceVariant,
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
                        errorBuilder: (_, __, ___) =>
                            Container(color: AppColors.surfaceVariant),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    displayName,
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontSize: 12,
                      fontWeight: isHighlighted
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: AppColors.onSurface,
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
    Color color = AppColors.onSurface;
    if (colored) {
      color = positive ? AppColors.tertiary : AppColors.error;
    }

    return SizedBox(
      width: 28,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 12,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          color: color,
        ),
      ),
    );
  }
}
