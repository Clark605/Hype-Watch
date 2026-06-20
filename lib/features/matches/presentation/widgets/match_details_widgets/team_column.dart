import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/core/theme/app_fonts.dart';
import 'package:world_cup_watch/features/matches/data/models/team_model.dart';

class TeamColumn extends StatelessWidget {
  const TeamColumn({required this.team, super.key});

  final Team team;

  @override
  Widget build(BuildContext context) {
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
            child: CachedNetworkImage(
              imageUrl: team.flag,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: AppColors.surfaceContainerLow,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceContainerLow,
                child: const Icon(
                  Icons.flag_outlined,
                  color: AppColors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          team.nameEn,
          style: AppFonts.font13Black700,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
