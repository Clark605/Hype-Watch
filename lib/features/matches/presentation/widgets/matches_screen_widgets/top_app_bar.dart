import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';

class TopAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TopAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: Container(
        height: preferredSize.height + MediaQuery.of(context).padding.top,
        padding: EdgeInsets.only(
          top: MediaQuery.of(context).padding.top,
          left: 16,
          right: 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.screenBackground.withValues(alpha: 0.8),
          border: Border(
            bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.2)),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.accentGreen.withValues(alpha: 0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(
                Icons.sports_soccer,
                color: AppColors.textSecondary,
              ),
              onPressed: () {},
            ),
            const Text(
              'Which Match?',
              style: TextStyle(
                fontFamily: 'Montserrat',
                fontSize: 32,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: AppColors.brandRed,
                letterSpacing: -0.02 * 32,
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications_none,
                color: AppColors.textSecondary,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(64.0);
}
