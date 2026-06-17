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
            child: Image.network(
              team.flag,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(color: AppColors.cardBackgroundElevated),
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
