import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/core/theme/app_fonts.dart';

class DetailsAppBar extends StatelessWidget {
  const DetailsAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 0,
      pinned: true,
      backgroundColor: AppColors.screenBackground.withValues(alpha: 0.92),
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text('Match Details', style: AppFonts.font18Black800),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(
          height: 1,
          color: AppColors.border.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
