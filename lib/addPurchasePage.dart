import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'theme.dart';
import 'utils.dart';

class AddPurchasePage extends StatefulWidget {
  const AddPurchasePage({super.key});

  @override
  State<AddPurchasePage> createState() => _AddPurchasePageState();
}

class _AddPurchasePageState extends State<AddPurchasePage> {
  static const _quickAmounts = [10000, 50000, 100000, 500000];

  final _formKey = GlobalKey<FormState>();
  final _amountCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();

  Category? _category;
  DateTime _date = DateUtils.dateOnly(DateTime.now());
  PaymentMethod _payment = PaymentMethod.cash;
  bool _recurring = false;
  Recurrence _recurrence = Recurrence.monthly;

  @override
  void dispose() {
    _amountCtrl.dispose();
    _titleCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  void _addToAmount(int value) {
    final next = (parseRupiah(_amountCtrl.text) + value).toInt();
    final text = groupThousands(next.toString());
    _amountCtrl.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          datePickerTheme: const DatePickerThemeData(
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            headerBackgroundColor: AppColors.primary,
            headerForegroundColor: AppColors.secondary,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _date = DateUtils.dateOnly(picked));
  }

  void _save() {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      Purchase(
        _titleCtrl.text.trim(),
        parseRupiah(_amountCtrl.text),
        _date,
        _category!,
        paymentMethod: _payment,
        note: _noteCtrl.text.trim(),
        recurrence: _recurring ? _recurrence : Recurrence.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.primary,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        centerTitle: false,
        title: const Text(
          'Add purchase',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
            children: [
              _buildAmountCard(),
              const _SectionLabel('Title'),
              TextFormField(
                controller: _titleCtrl,
                maxLength: 40,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.next,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                decoration: _fieldDecoration(
                  hint: 'e.g. Groceries',
                  icon: Icons.edit_rounded,
                ),
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Give this purchase a name'
                    : null,
              ),
              const _SectionLabel('Category'),
              _buildCategoryPicker(),
              const _SectionLabel('Date'),
              _buildDateTile(),
              const _SectionLabel('Payment method'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final m in PaymentMethod.values)
                    _ChoicePill(
                      label: m.label,
                      icon: m.icon,
                      selected: _payment == m,
                      onTap: () => setState(() => _payment = m),
                    ),
                ],
              ),
              const _SectionLabel('Notes', optional: true),
              TextFormField(
                controller: _noteCtrl,
                minLines: 3,
                maxLines: 3,
                maxLength: 200,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                decoration: _fieldDecoration(hint: 'Add a note'),
              ),
              const SizedBox(height: 20),
              _buildRecurringCard(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: ColoredBox(
        color: AppColors.background,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: SizedBox(
              height: 56,
              child: FilledButton.icon(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.secondary,
                  shape: const StadiumBorder(),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Save purchase'),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountCard() {
    const amountStyle = TextStyle(
      fontSize: 36,
      fontWeight: FontWeight.w800,
      letterSpacing: -0.5,
      color: AppColors.background,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Amount',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.secondary,
            ),
          ),
          TextFormField(
            controller: _amountCtrl,
            keyboardType: TextInputType.number,
            inputFormatters: [RupiahInputFormatter()],
            cursorColor: AppColors.secondary,
            style: amountStyle,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
              border: InputBorder.none,
              prefixText: 'Rp ',
              prefixStyle: amountStyle.copyWith(color: AppColors.secondary),
              hintText: '0',
              hintStyle: amountStyle.copyWith(
                color: AppColors.background.withValues(alpha: 0.3),
              ),
              errorStyle: const TextStyle(
                color: Color(0xFFF2B8A0),
                fontWeight: FontWeight.w600,
              ),
            ),
            validator: (v) => parseRupiah(v ?? '') <= 0
                ? 'Enter an amount greater than 0'
                : null,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final q in _quickAmounts)
                ActionChip(
                  label: Text('+${formatMoney(q.toDouble())}'),
                  onPressed: () => _addToAmount(q),
                  backgroundColor: Colors.transparent,
                  surfaceTintColor: Colors.transparent,
                  shape: StadiumBorder(
                    side: BorderSide(
                      color: AppColors.secondary.withValues(alpha: 0.5),
                    ),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryPicker() {
    return FormField<Category>(
      validator: (v) => v == null ? 'Pick a category' : null,
      builder: (state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final c in Category.values)
                _ChoicePill(
                  label: c.label,
                  icon: c.icon,
                  color: c.color,
                  onColor: c.onColor,
                  selected: _category == c,
                  onTap: () {
                    setState(() => _category = c);
                    state.didChange(c);
                  },
                ),
            ],
          ),
          if (state.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                state.errorText!,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.error,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateTile() {
    final isToday = DateUtils.isSameDay(_date, DateTime.now());

    return Material(
      color: AppColors.fieldFill,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: _pickDate,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Icon(Icons.calendar_today_rounded,
                  size: 20, color: AppColors.muted),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  formatFullDate(_date),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              if (isToday)
                Container(
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Today',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              Icon(Icons.chevron_right_rounded, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecurringCard() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1.5),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.topCenter,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.repeat_rounded, size: 22, color: AppColors.muted),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recurring expense',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Repeats on the same day',
                        style: TextStyle(fontSize: 13, color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _recurring,
                  onChanged: (v) => setState(() => _recurring = v),
                  thumbColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.secondary
                        : AppColors.primary.withValues(alpha: 0.55),
                  ),
                  trackColor: WidgetStateProperty.resolveWith(
                    (states) => states.contains(WidgetState.selected)
                        ? AppColors.primary
                        : AppColors.divider,
                  ),
                  trackOutlineColor:
                      const WidgetStatePropertyAll(Colors.transparent),
                ),
              ],
            ),
            if (_recurring) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final r in Recurrence.values)
                    if (r != Recurrence.none)
                      _ChoicePill(
                        label: r.label,
                        selected: _recurrence == r,
                        onTap: () => setState(() => _recurrence = r),
                      ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared bits
// ---------------------------------------------------------------------------

InputDecoration _fieldDecoration({String? hint, IconData? icon}) {
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: color, width: width),
      );

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: AppColors.muted),
    prefixIcon:
        icon == null ? null : Icon(icon, size: 20, color: AppColors.muted),
    filled: true,
    fillColor: AppColors.fieldFill,
    counterText: '',
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: border(Colors.transparent),
    enabledBorder: border(Colors.transparent),
    focusedBorder: border(AppColors.primary, 1.5),
    errorBorder: border(AppColors.error),
    focusedErrorBorder: border(AppColors.error, 1.5),
    errorStyle: const TextStyle(
      color: AppColors.error,
      fontWeight: FontWeight.w600,
    ),
  );
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, {this.optional = false});
  final String text;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 24, bottom: 10),
      child: Row(
        children: [
          Text(
            text,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          if (optional) ...[
            const SizedBox(width: 8),
            Text(
              'Optional',
              style: TextStyle(fontSize: 13, color: AppColors.muted),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChoicePill extends StatelessWidget {
  const _ChoicePill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.color = AppColors.primary,
    this.onColor = AppColors.background,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;
  final Color color;
  final Color onColor;

  @override
  Widget build(BuildContext context) {
    final foreground = selected ? onColor : AppColors.primary;

    return Material(
      color: selected ? color : Colors.transparent,
      animationDuration: const Duration(milliseconds: 180),
      shape: StadiumBorder(
        side: BorderSide(
          color: selected ? color : AppColors.divider,
          width: 1.5,
        ),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: selected ? onColor : color),
                const SizedBox(width: 8),
              ],
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}