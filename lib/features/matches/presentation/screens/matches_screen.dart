import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/matches_cubit.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/matches_state.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/bottom_nav_bar.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/hype_match_card.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/match_date_selector.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/top_app_bar.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MatchesCubit>().loadMatches();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const TopAppBar(),
      extendBody: true,
      body: BlocBuilder<MatchesCubit, MatchesState>(
        builder: (context, state) {
          if (state is MatchesLoading || state is MatchesInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          } else if (state is MatchesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    style: const TextStyle(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<MatchesCubit>().loadMatches(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.onPrimary,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          } else if (state is MatchesLoaded) {
            return CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(
                      left: 20,
                      right: 20,
                      top: 32,
                      bottom: 16,
                    ),
                    child: Text(
                      "Matches",
                      style: TextStyle(
                        fontFamily: 'Montserrat',
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.02 * 32,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 32),
                    child: MatchFilterSelector(),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.only(
                    left: 20,
                    right: 20,
                    bottom:
                        MediaQuery.of(context).padding.bottom +
                        80, // for bottom nav
                  ),
                  sliver: state.matchCards.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Text(
                              "No matches found.",
                              style: TextStyle(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate((
                            context,
                            index,
                          ) {
                            return HypeMatchCard(
                              matchCard: state.matchCards[index],
                            );
                          }, childCount: state.matchCards.length),
                        ),
                ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
