import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Palette {
  static const Color text = Color(0xFF1C1204);
  static const Color primary = Color(0xFF123F36);
  static const Color secondary = Color(0xFF2A6B5C);
  static const Color tertiary = Color(0xFFC49A45);
  static const Color background = Color(0xFFE8DCC4);
}

const _bulan = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

String _rp(double value) {
  final angka = value.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
  return 'Rp$angka';
}

class ExtraBudgetPage extends StatefulWidget {
  const ExtraBudgetPage({super.key});

  @override
  State<ExtraBudgetPage> createState() => _ExtraBudgetPageState();
}

class _ExtraBudgetPageState extends State<ExtraBudgetPage> {
  final DateTime _now = DateTime.now();
  List<Map<String, dynamic>> _items = [];

  String get _key =>
      'extra_budget_${_now.year}-${_now.month.toString().padLeft(2, '0')}';

  String get _labelBulan => '${_bulan[_now.month - 1]} ${_now.year}';

  double get _total =>
      _items.fold<double>(0, (sum, e) => sum + (e['amount'] as num).toDouble());

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return;
    final list = (jsonDecode(raw) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    if (!mounted) return;
    setState(() => _items = list);
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_items));
  }

  void _addItem(double amount, String note) {
    setState(() {
      _items.add({
        'id': DateTime.now().microsecondsSinceEpoch.toString(),
        'amount': amount,
        'note': note,
      });
    });
    _save();
  }

  void _deleteItem(String id) {
    setState(() => _items.removeWhere((e) => e['id'] == id));
    _save();
  }

  Future<void> _showAddDialog() async {
    final amountController = TextEditingController();
    final noteController = TextEditingController();
    String? error;

    await showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: _Palette.background,
          title: const Text(
            'Add budget for this month',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'Amount',
                  prefixText: 'Rp ',
                  errorText: error,
                  labelStyle: const TextStyle(color: _Palette.secondary),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: _Palette.secondary),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: _Palette.primary, width: 2),
                  ),
                ),
              ),
              TextField(
                controller: noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  labelStyle: TextStyle(color: _Palette.secondary),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _Palette.secondary),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: _Palette.primary, width: 2),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(foregroundColor: _Palette.secondary),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final amount = double.tryParse(amountController.text.trim());
                if (amount == null || amount <= 0) {
                  setDialogState(() => error = 'Enter an amount greater than 0');
                  return;
                }
                _addItem(amount, noteController.text.trim());
                Navigator.pop(dialogContext);
              },
              style: FilledButton.styleFrom(
                backgroundColor: _Palette.primary,
                foregroundColor: _Palette.background,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context);

    return Theme(
      data: base.copyWith(
        scaffoldBackgroundColor: _Palette.background,
        colorScheme: ColorScheme.fromSeed(seedColor: _Palette.primary).copyWith(
          primary: _Palette.primary,
          secondary: _Palette.secondary,
          tertiary: _Palette.tertiary,
          surface: _Palette.background,
          onSurface: _Palette.text,
        ),
        textTheme: base.textTheme.apply(
          bodyColor: _Palette.text,
          displayColor: _Palette.text,
        ),
      ),
      child: Scaffold(
        backgroundColor: _Palette.background,
        appBar: AppBar(
          title: const Text('Extra Budget'),
          backgroundColor: _Palette.primary,
          foregroundColor: _Palette.background,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _showAddDialog,
          backgroundColor: _Palette.primary,
          foregroundColor: _Palette.tertiary,
          icon: const Icon(Icons.add),
          label: const Text('Add budget'),
        ),
        body: Column(
          children: [
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _Palette.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Extra budget for $_labelBulan',
                    style: TextStyle(
                      color: _Palette.background.withValues(alpha: 0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _rp(_total),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _Palette.tertiary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Valid this month only',
                    style: TextStyle(
                      color: _Palette.background.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _items.isEmpty
                  ? Center(
                      child: Text(
                        'No extra budget yet',
                        style: TextStyle(
                          color: _Palette.text.withValues(alpha: 0.65),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        final note = item['note'] as String;

                        return Dismissible(
                          key: ValueKey(item['id']),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            color: const Color(0xFFB3261E),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            child:
                                const Icon(Icons.delete, color: Colors.white),
                          ),
                          onDismissed: (_) =>
                              _deleteItem(item['id'] as String),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: _Palette.secondary,
                              foregroundColor: _Palette.background,
                              child: Icon(Icons.add),
                            ),
                            title: Text(
                              '+${_rp((item['amount'] as num).toDouble())}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              note.isEmpty ? 'No note' : note,
                              style: TextStyle(
                                color: _Palette.text.withValues(alpha: 0.65),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}