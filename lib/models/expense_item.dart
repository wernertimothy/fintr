import 'package:flutter/material.dart';

/// A single expense: a name + amount, belonging to a category and a month.
@immutable
class ExpenseItem {
  const ExpenseItem({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.month,
    required this.createdAt,
  });

  final String id;
  final String name;
  final double amount;
  final String categoryId;

  /// Month key in `YYYY-MM` form (sortable, human-readable).
  final String month;
  final DateTime createdAt;

  ExpenseItem copyWith({
    String? name,
    double? amount,
    String? categoryId,
    String? month,
  }) {
    return ExpenseItem(
      id: id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      month: month ?? this.month,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'amount': amount,
        'categoryId': categoryId,
        'month': month,
        'createdAt': createdAt.toIso8601String(),
      };

  factory ExpenseItem.fromJson(Map<String, dynamic> json) => ExpenseItem(
        id: json['id'] as String,
        name: json['name'] as String,
        amount: (json['amount'] as num).toDouble(),
        categoryId: json['categoryId'] as String,
        month: json['month'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  @override
  bool operator ==(Object other) =>
      other is ExpenseItem &&
      other.id == id &&
      other.name == name &&
      other.amount == amount &&
      other.categoryId == categoryId &&
      other.month == month &&
      other.createdAt == createdAt;

  @override
  int get hashCode =>
      Object.hash(id, name, amount, categoryId, month, createdAt);
}
