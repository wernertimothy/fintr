import 'package:flutter/material.dart';

/// A spending category with a global monthly limit, applied to every month.
@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.monthlyLimit,
    required this.colorValue,
  });

  final String id;
  final String name;
  final double monthlyLimit;

  /// ARGB color stored as an int so it serializes trivially to JSON.
  final int colorValue;

  Color get color => Color(colorValue);

  Category copyWith({
    String? name,
    double? monthlyLimit,
    int? colorValue,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      colorValue: colorValue ?? this.colorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'monthlyLimit': monthlyLimit,
        'colorValue': colorValue,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
        colorValue: json['colorValue'] as int,
      );

  @override
  bool operator ==(Object other) =>
      other is Category &&
      other.id == id &&
      other.name == name &&
      other.monthlyLimit == monthlyLimit &&
      other.colorValue == colorValue;

  @override
  int get hashCode => Object.hash(id, name, monthlyLimit, colorValue);
}
