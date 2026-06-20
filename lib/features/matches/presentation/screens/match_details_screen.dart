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
  // Derived once from widget fields — no need to store in state or cubit.
  late final Map<String, Team> _teamById;
  late final Groups? _matchGroup;

  @override
  void initState() {
    super.initState();

    // Build team lookup map directly from the already-loaded teams list.
    _teamById = {for (final t in widget.teams) t.id: t};

    // Find the group this match belongs to — null for knockout stage.
    final groupName = widget.match.group;
    if (groupName != null && groupName.isNotEmpty) {
      try {
        _matchGroup = widget.groups.firstWhere(
          (g) => g.name?.toLowerCase() == groupName.toLowerCase(),
        );
      } catch (_) {
        _matchGroup = null;
      }
    } else {
      _matchGroup = null;
    }

    context.read<MatchDetailsCubit>().load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: CustomScrollView(
        slivers: [
          const DetailsAppBar(),
          SliverToBoxAdapter(child: _buildContent()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),

          // ── Stage badge — renders immediately, no bloc needed ──────────────
          _buildStageBadge(widget.match.stage, widget.match.group),
          const SizedBox(height: 24),

          // ── Score / Teams hero — renders immediately ───────────────────────
          ScoreHero(
            match: widget.match,
            homeTeam: widget.homeTeam,
            awayTeam: widget.awayTeam,
          ),
          const SizedBox(height: 32),

          // ── Stadium section — only this section waits on the cubit ─────────
          BlocBuilder<MatchDetailsCubit, MatchDetailsState>(
            builder: (context, state) {
              if (state is StadiumLoading) {
                return const SizedBox(
                  height: 80,
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.brandRed,
                      strokeWidth: 2,
                    ),
                  ),
                );
              }
              if (state is StadiumLoaded && state.stadium != null) {
                return Column(
                  children: [
                    StadiumCard(stadium: state.stadium!),
                    const SizedBox(height: 32),
                  ],
                );
              }
              // StadiumLoaded(stadium: null) or StadiumError — hide section.
              return const SizedBox.shrink();
            },
          ),

          // ── Group standings — renders immediately, null for knockout ────────
          if (_matchGroup != null) ...[
            _buildGroupStandings(_matchGroup, _teamById),
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

  // ── Group standings ───────────────────────────────────────────────────────────
  Widget _buildGroupStandings(Groups group, Map<String, Team> teamById) {
    final standings = group.teams ?? [];
    if (standings.isEmpty) return const SizedBox.shrink();

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
