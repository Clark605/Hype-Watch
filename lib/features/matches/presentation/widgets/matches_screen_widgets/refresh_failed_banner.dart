import 'package:flutter/material.dart';
import 'package:world_cup_watch/core/theme/app_colors.dart';

/// Dismissible top banner shown when a background refresh fails.
/// Tapping "Retry" calls [onRetry]; tapping close or swiping dismisses the banner.
class RefreshFailedBanner extends StatelessWidget {
  final VoidCallback onRetry;
  final VoidCallback onDismiss;

  const RefreshFailedBanner({
    required this.onRetry,
    required this.onDismiss,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: const Key('refresh_failed_banner'),
      direction: DismissDirection.up,
      onDismissed: (_) => onDismiss(),
      background: Container(
        color: AppColors.error,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Refresh failed. Pull down to retry.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('RETRY', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      child: Container(
        color: AppColors.error,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Refresh failed. Pull down to retry.',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              onPressed: onRetry,
              child: const Text('RETRY', style: TextStyle(color: Colors.white)),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white, size: 20),
              onPressed: onDismiss,
            ),
          ],
        ),
      ),
    );
  }
}
