import 'package:flutter/material.dart';

/// A titled card used to group related content on the dashboard screens.
class SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const SectionCard({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

/// A label/value pair with an optional comparison column.
class MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final String? comparison;
  final Color? valueColor;

  const MetricRow({
    super.key,
    required this.label,
    required this.value,
    this.comparison,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: theme.textTheme.bodyMedium),
          ),
          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ),
          if (comparison != null)
            Expanded(
              flex: 2,
              child: Text(
                comparison!,
                textAlign: TextAlign.end,
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }
}
