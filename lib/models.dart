import 'package:flutter/material.dart';

import 'theme.dart';

enum Category {
  food('Food', Color(0xFF123F36), Icons.restaurant_rounded),
  transport('Transport', Color(0xFFC49A45), Icons.directions_bus_rounded),
  shopping('Shopping', Color(0xFF6F9A8D), Icons.shopping_bag_rounded),
  bills('Bills', Color(0xFF8A5A3B), Icons.receipt_long_rounded),
  fun('Fun', Color(0xFFA9B58C), Icons.local_activity_rounded);

  const Category(this.label, this.color, this.icon);
  final String label;
  final Color color;
  final IconData icon;

  Color get onColor =>
      color.computeLuminance() > 0.35 ? AppColors.primary : AppColors.background;
}

enum PaymentMethod {
  cash('Cash', Icons.payments_rounded),
  debit('Debit card', Icons.credit_card_rounded),
  credit('Credit card', Icons.credit_score_rounded),
  ewallet('E-wallet', Icons.account_balance_wallet_rounded),
  qris('QRIS', Icons.qr_code_scanner_rounded),
  transfer('Bank transfer', Icons.swap_horiz_rounded);

  const PaymentMethod(this.label, this.icon);
  final String label;
  final IconData icon;
}

enum Recurrence {
  none('One-time'),
  weekly('Weekly'),
  monthly('Monthly'),
  yearly('Yearly');

  const Recurrence(this.label);
  final String label;
}

class Purchase {
  const Purchase(
    this.title,
    this.amount,
    this.date,
    this.category, {
    this.paymentMethod = PaymentMethod.cash,
    this.note = '',
    this.recurrence = Recurrence.none,
  });

  final String title;
  final double amount;
  final DateTime date;
  final Category category;
  final PaymentMethod paymentMethod;
  final String note;
  final Recurrence recurrence;
}