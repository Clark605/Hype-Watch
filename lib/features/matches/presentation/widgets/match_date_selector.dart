import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/matches_cubit.dart';
import 'package:world_cup_watch/features/matches/presentation/cubit/matches_state.dart';

class MatchFilterSelector extends StatelessWidget {
  const MatchFilterSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesCubit, MatchesState>(
      builder: (context, state) {
        if (state is! MatchesLoaded) return const SizedBox.shrink();

        return SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: MatchesFilter.values.map((filter) {
              final isSelected = state.activeFilter == filter;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: _FilterButton(
                  title: _getFilterTitle(filter),
                  isSelected: isSelected,
                  onTap: () {
                    context.read<MatchesCubit>().applyFilter(filter);
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  String _getFilterTitle(MatchesFilter filter) {
    switch (filter) {
      case MatchesFilter.today:
        return 'Today';
      case MatchesFilter.upcoming:
        return 'Upcoming';
      case MatchesFilter.finished:
        return 'Finished';
      case MatchesFilter.all:
        return 'All Matches';
    }
  }
}

class _FilterButton extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.secondaryContainer.withValues(alpha: 0.2)
              : AppColors.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.secondaryFixed
                : AppColors.outlineVariant.withValues(alpha: 0.5),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.tertiaryFixed.withValues(alpha: 0.2),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          title.toUpperCase(),
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isSelected
                ? AppColors.onSecondaryFixed
                : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
