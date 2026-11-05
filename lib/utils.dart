import 'package:flutter/services.dart';

String formatMoney(double value) {
  final double number;
  final String suffix;
  if (value >= 1000000) {
    number = value / 1000000;
    suffix = 'jt';
  } else if (value >= 1000) {
    number = value / 1000;
    suffix = 'K';
  } else {
    number = value;
    suffix = '';
  }

  var text = number.toStringAsFixed(suffix.isEmpty ? 0 : 1);
  if (text.endsWith('.0')) text = text.substring(0, text.length - 2);

  final parts = text.split('.');
  final whole = groupThousands(parts[0]);
  final decimal = parts.length > 1 ? ',${parts[1]}' : '';

  return 'Rp$whole$decimal$suffix';
}

String groupThousands(String digits) => digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );

double parseRupiah(String text) =>
    double.tryParse(text.replaceAll('.', '')) ?? 0;

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatShortDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';

String formatFullDate(DateTime d) =>
    '${d.day} ${_months[d.month - 1]} ${d.year}';

class RupiahInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text
        .replaceAll(RegExp(r'[^0-9]'), '')
        .replaceFirst(RegExp(r'^0+'), '');
    if (digits.isEmpty) {
      return const TextEditingValue(text: '');
    }
    final text = groupThousands(digits);
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

String formatMoneyFull(double value) {
  final whole = value.round().toString().replaceAllMapped(
        RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
      );
  return 'Rp$whole';
}