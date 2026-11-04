import 'package:flutter/material.dart';
import 'main.dart';

class MonthlyHistoryPage extends StatefulWidget {
  const MonthlyHistoryPage({super.key});

  @override
  State<MonthlyHistoryPage> createState() => _MonthlyHistoryPageState();
}

class _MonthlyHistoryPageState extends State<MonthlyHistoryPage> {
  String _month = 'October 2026';

  // (category, spent, limit)
  static const _data = {
    'September 2026': [
      (Category.food, 1400000, 1500000),
      (Category.transport, 400000, 500000),
      (Category.shopping, 350000, 500000),
      (Category.fun, 550000, 500000),
    ],
    'October 2026': [
      (Category.food, 1250000, 1500000),
      (Category.transport, 480000, 500000),
      (Category.shopping, 850000, 750000),
      (Category.fun, 300000, 500000),
    ],
    'November 2026': [
      (Category.food, 450000, 1500000),
      (Category.transport, 120000, 500000),
      (Category.shopping, 200000, 500000),
      (Category.fun, 100000, 500000),
    ],
  };

  @override
  Widget build(BuildContext context) {
    final items = _data[_month]!;
    final spent = items.fold(0, (sum, e) => sum + e.$2);
    final budget = items.fold(0, (sum, e) => sum + e.$3);
    final left = budget - spent;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          children: [
            // Header: same style as the dashboard
            Row(
              children: [
                IconButton.filled(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'History',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: DropdownButton<String>(
                    value: _month,
                    isDense: true,
                    underline: const SizedBox(),
                    dropdownColor: AppColors.primary,
                    iconEnabledColor: AppColors.secondary,
                    style: const TextStyle(
                      color: AppColors.secondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    items: [
                      for (final m in _data.keys)
                        DropdownMenuItem(value: m, child: Text(m)),
                    ],
                    onChanged: (m) => setState(() => _month = m!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Summary card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Spent this month',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.background.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    money(spent.toDouble()),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: (spent / budget).clamp(0.0, 1.0),
                      minHeight: 8,
                      color: AppColors.secondary,
                      backgroundColor:
                          AppColors.background.withValues(alpha: 0.2),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    left < 0
                        ? 'Over budget by ${money(-left.toDouble())}'
                        : '${money(left.toDouble())} left of ${money(budget.toDouble())}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(top: 32, bottom: 8),
              child: Text(
                'By category',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),

            // One row per category
            for (final (c, used, limit) in items) _CategoryRow(c, used, limit),
          ],
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow(this.category, this.spent, this.limit);
  final Category category;
  final int spent, limit;

  @override
  Widget build(BuildContext context) {
    final ratio = spent / limit;
    // Brown (same as Bills) = over limit, otherwise dark green
    final color = ratio > 1 ? Category.bills.color : AppColors.primary;
    final iconColor = category.color.computeLuminance() > 0.35
        ? AppColors.primary
        : AppColors.background;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration:
                BoxDecoration(color: category.color, shape: BoxShape.circle),
            child: Icon(category.icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        category.label,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      '${(ratio * 100).round()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    minHeight: 7,
                    color: color,
                    backgroundColor: AppColors.divider,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${money(spent.toDouble())} / ${money(limit.toDouble())}',
                  style: TextStyle(fontSize: 13, color: AppColors.muted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}