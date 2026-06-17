import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/features/matches/data/models/group_model.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/match_details_cubit.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/match_details_state.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/match_details_widgets/details_app_bar.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/match_details_widgets/group_standings.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/match_details_widgets/score_hero.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/match_details_widgets/stadium_card.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/match_details_widgets/state_badge.dart';

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
      backgroundColor: AppColors.screenBackground,
      body: CustomScrollView(
        slivers: [
          DetailsAppBar(),
          SliverToBoxAdapter(
            child: BlocBuilder<MatchDetailsCubit, MatchDetailsState>(
              builder: (context, state) {
                if (state is MatchDetailsLoading) {
                  return const SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColors.brandRed,
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
                        style: const TextStyle(color: AppColors.textSecondary),
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

  // ── Main content ──────────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context, MatchDetailsLoaded state) {
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
            StadiumCard(stadium: state.stadium!),
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

    return StateBadge(isKnockout: isKnockout, label: label, widget: widget);
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

    return ScoreHero(
      widget: widget,
      isFinished: isFinished,
      homeScore: homeScore,
      awayScore: awayScore,
    );
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

    return GroupStandings(
      sorted: sorted,
      widget: widget,
      group: group,
      teamById: teamById,
    );
  }
}
