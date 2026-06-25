import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/core/theme/app_fonts.dart';
import 'package:world_cup_watch/features/bracket/presentation/bracket_match_card.dart';
import 'package:world_cup_watch/features/bracket/presentation/bracket_painter.dart';
import 'package:world_cup_watch/features/matches/data/models/match_model.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/matches_cubit.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/matches_state.dart';

// ── Layout constants ──────────────────────────────────────────────────────────
const double _cardWidth = 180.0;
const double _cardHeight = 88.0;
const double _colGap = 56.0; // connector zone width between columns
const double _canvasPadH = 24.0;
const double _canvasPadTop = 52.0; // room for round labels
const double _canvasPadBot = 40.0;

// The total canvas height is fixed — every column is laid out inside it.
// R32 has 32 cards so each slot = canvasBody / 32.
// R16 has 16 cards so each slot = canvasBody / 16 = 2× bigger. Etc.
// This makes the bracket "open up" naturally as rounds progress.
const double _canvasBodyH = 32 * 112.0; // 32 slots × 112px each = 3584px

// ── Round definitions ─────────────────────────────────────────────────────────
class _RoundDef {
  final String label;
  final String stageValue;
  final int cardCount; // expected number of matches in this round
  const _RoundDef(this.label, this.stageValue, this.cardCount);
}

const _rounds = [
  _RoundDef('Round of 32', 'r32', 32),
  _RoundDef('Round of 16', 'r16', 16),
  _RoundDef('Quarter-final', 'qf', 8),
  _RoundDef('Semi-final', 'sf', 4),
  _RoundDef('Final', 'final', 2),
];

// ─────────────────────────────────────────────────────────────────────────────

class BracketScreen extends StatelessWidget {
  const BracketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.screenBackground,
      body: BlocBuilder<MatchesCubit, MatchesState>(
        builder: (context, state) {
          if (state is MatchesInitial || state is MatchesLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandRed),
            );
          }

          final cubit = context.read<MatchesCubit>();
          final teamById = {for (final t in cubit.cachedTeams) t.id: t};
          final knockoutMatches = _groupByRound(cubit.allMatches);

          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                  child: Text('Tournament', style: AppFonts.font32Black800),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    'Pan · pinch to explore',
                    style: AppFonts.font13Secondary700,
                  ),
                ),
                Expanded(
                  child: _BracketCanvas(
                    knockoutMatches: knockoutMatches,
                    teamById: teamById,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Map<String, List<Match>> _groupByRound(List<Match> allMatches) {
    final Map<String, List<Match>> result = {};
    for (final match in allMatches) {
      final stage = match.stage.toLowerCase();
      if (stage == 'group') continue;
      result.putIfAbsent(stage, () => []).add(match);
    }
    for (final list in result.values) {
      list.sort((a, b) {
        final ia = int.tryParse(a.id) ?? 0;
        final ib = int.tryParse(b.id) ?? 0;
        return ia.compareTo(ib);
      });
    }
    return result;
  }
}

// ── Canvas ────────────────────────────────────────────────────────────────────

class _BracketCanvas extends StatelessWidget {
  final Map<String, List<Match>> knockoutMatches;
  final Map<String, Team> teamById;

  const _BracketCanvas({required this.knockoutMatches, required this.teamById});

  @override
  Widget build(BuildContext context) {
    final columns = _rounds
        .map((r) => knockoutMatches[r.stageValue] ?? <Match>[])
        .toList();

    final hasData = columns.any((c) => c.isNotEmpty);
    if (!hasData) {
      return Center(
        child: Text(
          'No knockout matches yet.',
          style: AppFonts.font13Secondary700,
        ),
      );
    }

    final totalHeight = _canvasPadTop + _canvasBodyH + _canvasPadBot;
    final totalWidth =
        _canvasPadH * 2 +
        _rounds.length * _cardWidth +
        (_rounds.length - 1) * _colGap;

    return InteractiveViewer(
      constrained: false,
      boundaryMargin: const EdgeInsets.all(80),
      minScale: 0.25,
      maxScale: 2.0,
      child: SizedBox(
        width: totalWidth,
        height: totalHeight,
        child: Stack(
          children: [
            ..._buildLabels(),
            ..._buildConnectors(columns, totalHeight),
            ..._buildCards(columns),
          ],
        ),
      ),
    );
  }

  // ── Column labels ─────────────────────────────────────────────────────────
  List<Widget> _buildLabels() {
    return _rounds.asMap().entries.map((entry) {
      final i = entry.key;
      final round = entry.value;
      final x = _canvasPadH + i * (_cardWidth + _colGap);
      return Positioned(
        left: x,
        top: 14,
        width: _cardWidth,
        child: Text(
          round.label.toUpperCase(),
          textAlign: TextAlign.center,
          style: AppFonts.font11Secondary700.copyWith(letterSpacing: 1.0),
        ),
      );
    }).toList();
  }

  // ── Card positions ────────────────────────────────────────────────────────
  List<Widget> _buildCards(List<List<Match>> columns) {
    final widgets = <Widget>[];

    for (var col = 0; col < _rounds.length; col++) {
      final matches = columns[col];
      if (matches.isEmpty) continue;

      final roundDef = _rounds[col];
      final x = _canvasPadH + col * (_cardWidth + _colGap);

      // Each card occupies an equal vertical slot within _canvasBodyH.
      // Slot height = _canvasBodyH / cardCount — cards are centred in their slot.
      final slotH = _canvasBodyH / roundDef.cardCount;

      for (var row = 0; row < matches.length; row++) {
        final match = matches[row];
        // Center the card vertically within its slot
        final slotTop = _canvasPadTop + row * slotH;
        final y = slotTop + (slotH - _cardHeight) / 2;

        final homeTeam = match.homeTeamId != '0'
            ? teamById[match.homeTeamId]
            : null;
        final awayTeam = match.awayTeamId != '0'
            ? teamById[match.awayTeamId]
            : null;

        widgets.add(
          Positioned(
            left: x,
            top: y,
            width: _cardWidth,
            child: BracketMatchCard(
              match: match,
              homeTeam: homeTeam,
              awayTeam: awayTeam,
            ),
          ),
        );
      }
    }

    return widgets;
  }

  // ── Connector painters ────────────────────────────────────────────────────
  List<Widget> _buildConnectors(List<List<Match>> columns, double totalHeight) {
    final widgets = <Widget>[];

    for (var col = 0; col < _rounds.length - 1; col++) {
      final left = columns[col];
      final right = columns[col + 1];
      if (left.isEmpty || right.isEmpty) continue;

      final leftCenters = _centersFor(col, left.length);
      final rightCenters = _centersFor(col + 1, right.length);

      final x = _canvasPadH + col * (_cardWidth + _colGap) + _cardWidth;

      widgets.add(
        Positioned(
          left: x,
          top: 0,
          width: _colGap,
          height: totalHeight,
          child: CustomPaint(
            painter: BracketPainter(
              leftCenters: leftCenters,
              rightCenters: rightCenters,
              gapWidth: _colGap,
            ),
          ),
        ),
      );
    }

    return widgets;
  }

  /// Returns the Y-center of each card in a given column (canvas coordinates).
  /// Uses the same slot-based layout as _buildCards so connectors align exactly.
  List<double> _centersFor(int colIndex, int matchCount) {
    final roundDef = _rounds[colIndex];
    final slotH = _canvasBodyH / roundDef.cardCount;
    return List.generate(
      matchCount,
      (i) => _canvasPadTop + i * slotH + slotH / 2,
    );
  }
}
