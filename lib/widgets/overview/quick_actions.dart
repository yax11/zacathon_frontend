import 'package:flutter/material.dart';
import '../../app/core/theme/app_colors.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({
    super.key,
    this.onZenithToZenith,
    this.onZenithToOthers,
    this.onHistory,
  });

  final VoidCallback? onZenithToZenith;
  final VoidCallback? onZenithToOthers;
  final VoidCallback? onHistory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _ActionButton(
            label: 'To Zenith',
            icon: Icons.account_balance_outlined,
            onTap: onZenithToZenith,
          ),
          _ActionButton(
            label: 'To Others',
            icon: Icons.sync_alt_outlined,
            onTap: onZenithToOthers,
          ),
          _ActionButton(
            label: 'History',
            icon: Icons.history_outlined,
            onTap: onHistory,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
