import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme.dart';

class IncomeSettings {
  const IncomeSettings({required this.monthlyIncome, required this.payday});
  final double monthlyIncome;
  final int payday; 
  Map<String, dynamic> toJson() => {'monthlyIncome': monthlyIncome, 'payday': payday};
}

String _thousands(num v) {
  final digits = v.round().toString(); 
  var result = '';
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) result += '.';
    result += digits[i];
  }
  return result;
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue now) {
    final digits = now.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue();
    final text = _thousands(int.parse(digits));
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

const _dayLabel = TextStyle(
    color: AppColors.background, fontSize: 18, fontWeight: FontWeight.w600);

class _DayFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue old, TextEditingValue now) {
    final n = int.tryParse(now.text);
    return now.text.isEmpty || (n != null && n >= 1 && n <= 31) ? now : old;
  }
}

class IncomeSetupPage extends StatefulWidget {
  const IncomeSetupPage({super.key, this.initial});
  final IncomeSettings? initial; 
  @override
  State<IncomeSetupPage> createState() => _IncomeSetupPageState();
}

class _IncomeSetupPageState extends State<IncomeSetupPage> {
  late final _controller = TextEditingController(
    text: widget.initial == null ? '' : _thousands(widget.initial!.monthlyIncome),
  )..addListener(() => setState(() {}));
  late final _dayController = TextEditingController(text: '${widget.initial?.payday ?? 25}');
  int get _payday => int.tryParse(_dayController.text) ?? 0;
  double get _income =>
      double.tryParse(_controller.text.replaceAll('.', '')) ?? 0;

  @override
  void dispose() {
    _controller.dispose();
    _dayController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(IncomeSettings(monthlyIncome: _income, payday: _payday));
  }

  @override
  Widget build(BuildContext context) {
    const pad = EdgeInsets.symmetric(horizontal: 20);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(padding: const EdgeInsets.fromLTRB(24, 20, 24, 24), children: [
              const Text('Monthly income',
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -1)),
              const SizedBox(height: 28),
              _label('How much do you earn each month?'),
              _card(
                padding: pad.copyWith(top: 6, bottom: 6),
                child: Row(children: [
                  const Text('Rp',
                      style: TextStyle(
                          color: AppColors.secondary, fontSize: 22, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, _ThousandsFormatter()],
                      cursorColor: AppColors.secondary,
                      style: const TextStyle(
                          color: AppColors.background,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: '0',
                        hintStyle: TextStyle(color: AppColors.background.withValues(alpha: 0.35)),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 32),
              _label('Which day do you get paid?'),
              _card(
                padding: pad.copyWith(top: 6, bottom: 6),
                child: Row(children: [
                  const Text('Day', style: _dayLabel),
                  SizedBox(
                    width: 72,
                    child: TextField(
                      controller: _dayController,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, _DayFormatter()],
                      onChanged: (_) => setState(() {}),
                      cursorColor: AppColors.secondary,
                      style: const TextStyle(
                          color: AppColors.secondary, fontSize: 30, fontWeight: FontWeight.w800),
                      decoration: const InputDecoration(border: InputBorder.none),
                    ),
                  ),
                  const Text('of every month', style: _dayLabel),
                ]),
              ),
              if (_payday > 28)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text('In shorter months, payday falls on the last day.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted)),
                ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: FilledButton(
              onPressed: _income > 0 && _payday > 0 ? _save : null,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.secondary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.25),
                disabledForegroundColor: AppColors.background.withValues(alpha: 0.7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              child: const Text('Save'),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(text, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      );

  Widget _card({required Widget child, required EdgeInsets padding}) => Container(
        padding: padding,
        decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(20)),
        child: child,
      );
}