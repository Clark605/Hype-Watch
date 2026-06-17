import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';
import 'package:world_cup_watch/core/theme/app_fonts.dart';
import 'package:world_cup_watch/features/matches/data/models/stadium_model.dart';

class StadiumCard extends StatelessWidget {
  const StadiumCard({required this.stadium, super.key});
  final Stadium stadium;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Venue', style: AppFonts.font11Secondary700),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.cardBackground.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.activeBackground,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.stadium_outlined,
                  color: AppColors.brandRed,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stadium.nameEn ?? 'Unknown Stadium',
                      style: AppFonts.font15Black700,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${stadium.cityEn ?? ''}, ${stadium.countryEn ?? ''}',
                      style: AppFonts.font13Secondary700,
                    ),
                    if (stadium.capacity != null && stadium.capacity! > 0) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${_formatCapacity(stadium.capacity!)} capacity',
                        style: AppFonts.font11Secondary700,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatCapacity(int cap) {
    if (cap >= 1000) {
      return '${(cap / 1000).toStringAsFixed(0)}k';
    }
    return cap.toString();
  }
}
