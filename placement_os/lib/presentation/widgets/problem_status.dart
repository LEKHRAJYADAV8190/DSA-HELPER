import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';
import '../../domain/entities/entities.dart';

/// Small status icons: solved, starred, notes, revision due.
class ProblemStatusIcons extends StatelessWidget {
  const ProblemStatusIcons({
    super.key,
    required this.problem,
    this.revisionDue = false,
    this.compact = true,
  });

  final ProblemEntity problem;
  final bool revisionDue;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final icons = <Widget>[];
    if (problem.solved) {
      icons.add(_icon(Icons.check_circle, AppColors.success, 'Solved'));
    }
    if (problem.starred) {
      icons.add(_icon(Icons.star, AppColors.warning, 'Starred'));
    }
    if (problem.hasNotes) {
      icons.add(_icon(Icons.note, AppColors.primaryLight, 'Notes'));
    }
    if (revisionDue) {
      icons.add(_icon(Icons.refresh, AppColors.primary, 'Revision due'));
    }
    if (icons.isEmpty) return const SizedBox.shrink();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: icons
          .map((w) => Padding(
                padding: EdgeInsets.only(left: compact ? 4 : 6),
                child: w,
              ))
          .toList(),
    );
  }

  Widget _icon(IconData icon, Color color, String tooltip) {
    return Tooltip(
      message: tooltip,
      child: Icon(icon, size: compact ? 14 : 16, color: color),
    );
  }
}

class PatternChip extends StatelessWidget {
  const PatternChip({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: AppColors.primaryLight,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
