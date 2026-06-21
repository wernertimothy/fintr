import 'package:flutter/material.dart';

/// A spending category with a global monthly limit, applied to every month.
@immutable
class Category {
  const Category({
    required this.id,
    required this.name,
    required this.monthlyLimit,
    required this.colorValue,
    required this.iconCodePoint,
  });

  final String id;
  final String name;
  final double monthlyLimit;

  /// ARGB color stored as an int so it serializes trivially to JSON.
  final int colorValue;

  /// Material icon code point (e.g. [Icons.fastfood].codePoint).
  final int iconCodePoint;

  Color get color => Color(colorValue);

  // ignore: non_const_argument_for_const_parameter
  IconData get icon => IconData(iconCodePoint, fontFamily: 'MaterialIcons');

  Category copyWith({
    String? name,
    double? monthlyLimit,
    int? colorValue,
    int? iconCodePoint,
  }) {
    return Category(
      id: id,
      name: name ?? this.name,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      colorValue: colorValue ?? this.colorValue,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'monthlyLimit': monthlyLimit,
        'colorValue': colorValue,
        'iconCodePoint': iconCodePoint,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'] as String,
        name: json['name'] as String,
        monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
        colorValue: json['colorValue'] as int,
        iconCodePoint: json['iconCodePoint'] as int,
      );

  @override
  bool operator ==(Object other) =>
      other is Category &&
      other.id == id &&
      other.name == name &&
      other.monthlyLimit == monthlyLimit &&
      other.colorValue == colorValue &&
      other.iconCodePoint == iconCodePoint;

  @override
  int get hashCode =>
      Object.hash(id, name, monthlyLimit, colorValue, iconCodePoint);
}
