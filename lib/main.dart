import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'monthly_history_page.dart';
import 'addPurchasePage.dart';
import 'models.dart';
import 'theme.dart';
import 'utils.dart';

void main() => runApp(const BudgetingeApp());

// ---------------------------------------------------------------------------
// Theme
// ---------------------------------------------------------------------------

class BudgetingeApp extends StatelessWidget {
  const BudgetingeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Budgetinge',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.secondary,
          surface: AppColors.background,
        ),
        textTheme: ThemeData.light().textTheme.apply(
          bodyColor: AppColors.primary,
          displayColor: AppColors.primary,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ---------------------------------------------------------------------------
// Placeholder data (UI showcase only)
// ---------------------------------------------------------------------------

final List<Purchase> _seedPurchases = [
  Purchase('Groceries', 1_200_000, DateTime(2026, 10, 26), Category.food),
  Purchase(
    'Monthly bus pass',
    300_000,
    DateTime(2026, 10, 25),
    Category.transport,
  ),
  Purchase(
    'Running shoes',
    1_300_000,
    DateTime(2026, 10, 23),
    Category.shopping,
  ),
  Purchase('Electricity bill', 200_000, DateTime(2026, 10, 21), Category.bills),
  Purchase('Cinema tickets', 60_000, DateTime(2026, 10, 19), Category.fun),
  Purchase(
    'Lunch with friends',
    350_000,
    DateTime(2026, 10, 18),
    Category.food,
  ),
  Purchase('Internet', 400_001, DateTime(2026, 10, 15), Category.bills),
  Purchase(
    'Ride to airport',
    20_000,
    DateTime(2026, 10, 12),
    Category.transport,
  ),
  Purchase('Backpack', 600_000, DateTime(2026, 10, 9), Category.shopping),
  Purchase('Coffee beans', 200_000, DateTime(2026, 10, 6), Category.food),
];

// ---------------------------------------------------------------------------
// Home page
// ---------------------------------------------------------------------------

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Purchase> _purchases = List.of(_seedPurchases);
  int _touched = -1;

  Map<Category, double> get _totals {
    final map = <Category, double>{for (final c in Category.values) c: 0};
    for (final p in _purchases) {
      map[p.category] = map[p.category]! + p.amount;
    }
    return map;
  }

  double get _grandTotal => _purchases.fold(0, (sum, p) => sum + p.amount);

  Future<void> _openAddPurchase() async {
    final result = await Navigator.of(context).push<Purchase>(
      MaterialPageRoute(builder: (_) => const AddPurchasePage()),
    );
    if (result == null || !mounted) return;

    setState(() {
      _purchases.add(result);
      _touched = -1;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.primary,
          content: Text(
            '${result.title} added',
            style: const TextStyle(
              color: AppColors.background,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final sorted = [..._purchases]..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPurchase,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.secondary,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add purchase',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _Header()),
            SliverToBoxAdapter(child: _buildChart()),
            SliverToBoxAdapter(child: _buildLegend()),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
                child: Text(
                  'Recent purchases',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 112),
              sliver: SliverList.separated(
                itemCount: sorted.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: AppColors.divider),
                itemBuilder: (_, i) => _PurchaseTile(
                  purchase: sorted[i],
                  onTap: () => _showDetails(sorted[i]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final totals = _totals;
    final touchedCategory = _touched >= 0 ? Category.values[_touched] : null;

    final centerLabel = touchedCategory?.label ?? 'Spent this month';
    final centerValue = touchedCategory != null
        ? totals[touchedCategory]!
        : _grandTotal;

    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 260,
        child: Stack(
          alignment: Alignment.center,
          children: [
            PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: 86,
                startDegreeOffset: -90,
                borderData: FlBorderData(show: false),
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (event is FlTapUpEvent) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MonthlyHistoryPage(),
                        ),
                      );
                    }
                    final index =
                        response?.touchedSection?.touchedSectionIndex ?? -1;
                    if (!event.isInterestedForInteractions || index < 0) {
                      if (_touched != -1) setState(() => _touched = -1);
                      return;
                    }
                    if (index != _touched) setState(() => _touched = index);
                  },
                ),
                sections: [
                  for (var i = 0; i < Category.values.length; i++)
                    PieChartSectionData(
                      value: totals[Category.values[i]]!,
                      color: Category.values[i].color,
                      radius: i == _touched ? 40 : 30,
                      showTitle: false,
                    ),
                ],
              ),
            ),
            IgnorePointer(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    centerLabel,
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatMoney(centerValue),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    final totals = _totals;
    final total = _grandTotal;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
      child: Wrap(
        spacing: 20,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          for (final c in Category.values)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: c.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${c.label} ${(totals[c]! / total * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  void _showDetails(Purchase p) {
    final c = p.category;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      // Material 3 caps sheet width at 640; lift the cap for full width.
      constraints: const BoxConstraints(maxWidth: double.infinity),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${p.category.label}, ${formatShortDate(p.date)}',
                        style: TextStyle(color: AppColors.muted),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        formatMoneyFull(p.amount),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: c.color,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(c.icon, color: c.onColor, size: 33),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Receipt area, 3:4 (width:height). Swap the child for the
              // receipt image once it exists.
              AspectRatio(
                aspectRatio: 3 / 4,
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.divider),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'NO RECEIPT',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Widgets
// ---------------------------------------------------------------------------

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          const Expanded(
            child: Text(
              'Budgetinge',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'October 2026',
              style: TextStyle(
                color: AppColors.secondary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PurchaseTile extends StatelessWidget {
  const _PurchaseTile({required this.purchase, this.onTap});
  final Purchase purchase;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = purchase.category;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(color: c.color, shape: BoxShape.circle),
              child: Icon(c.icon, color: c.onColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    purchase.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${c.label}, ${formatShortDate(purchase.date)}',
                    style: TextStyle(fontSize: 13, color: AppColors.muted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '-${formatMoney(purchase.amount)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
