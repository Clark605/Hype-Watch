import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/core/theme/app_fonts.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/matches_cubit.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/matches_state.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/matches_screen_widgets/hype_match_card.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/matches_screen_widgets/match_date_selector.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/matches_screen_widgets/refresh_failed_banner.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/matches_screen_widgets/top_app_bar.dart';
import 'package:world_cup_watch/features/matches/presentation/widgets/matches_screen_widgets/updating_indicator.dart';

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
      appBar: const TopAppBar(),
      backgroundColor: AppColors.screenBackground,
      extendBody: true,
      body: BlocBuilder<MatchesCubit, MatchesState>(
        builder: (context, state) {
          if (state is MatchesLoading || state is MatchesInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.brandRed),
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
                    style: const TextStyle(color: AppColors.textSecondary),
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
            return Stack(
              children: [
                CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          left: 20,
                          right: 20,
                          top: 32,
                          bottom: 16,
                        ),
                        child: Text("Matches", style: AppFonts.font32Black800),
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
                ),
                if (state.refreshFailed)
                  RefreshFailedBanner(
                    onRetry: () => context.read<MatchesCubit>().retryRefresh(),
                    onDismiss: () =>
                        context.read<MatchesCubit>().dismissRefreshFailure(),
                  ),
                if (state.isRefreshing)
                  const Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: UpdatingIndicator(),
                  ),
              ],
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
