import 'package:flutter/material.dart';

/// مدل مربوط به افزودنی‌ها (Additives)
class Additive {
  final String code;
  final String name;
  final String riskLevel; // safe, low, medium, high

  Additive({
    required this.code,
    required this.name,
    required this.riskLevel,
  });

  factory Additive.fromJson(Map<String, dynamic> json) {
    return Additive(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      riskLevel: json['riskLevel'] ?? 'unknown',
    );
  }

  /// امتیاز خطر بر اساس سطح ریسک
  int get riskScore {
    switch (riskLevel) {
      case 'safe':
        return 100;
      case 'low':
        return 80;
      case 'medium':
        return 50;
      case 'high':
        return 20;
      default:
        return 0;
    }
  }
}

/// مدل مربوط به محصول (Product)
class Product {
  final String name;
  final String barcode;
  final List<Additive> additives;

  Product({
    required this.name,
    required this.barcode,
    required this.additives,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final additivesList = (json['additives'] as List<dynamic>? ?? [])
    .map((a) {
      if (a is String) {
        // اگر فقط کد E داده شده، یک افزودنی ساده بساز
        return Additive(
          code: a,
          name: a,
          riskLevel: 'unknown',
        );
      } else if (a is Map<String, dynamic>) {
        // اگر آبجکت کامل داده شده
        return Additive.fromJson(a);
      } else {
        return Additive(code: 'N/A', name: 'نامشخص', riskLevel: 'unknown');
      }
    })
    .toList();

    return Product(
      name: json['name'] ?? 'بدون نام',
      barcode: json['barcode'] ?? '',
      additives: additivesList,
    );
  }

  /// محاسبه‌ی میانگین نمره بر اساس افزودنی‌ها
  int get overallScore {
    if (additives.isEmpty) return 100;
    final total = additives.map((a) => a.riskScore).reduce((a, b) => a + b);
    return (total / additives.length).round();
  }

  /// دسته‌بندی سلامت محصول
  String get healthLevel {
    final score = overallScore;
    if (score >= 80) return "عالی";
    if (score >= 60) return "خوب";
    if (score >= 40) return "متوسط";
    return "ضعیف";
  }

  /// رنگ سلامت محصول
  Color get color {
    final score = overallScore;
    if (score >= 80) return Colors.green.shade800; // سبز پررنگ
    if (score >= 60) return Colors.green.shade400; // سبز کم‌رنگ
    if (score >= 40) return Colors.orange.shade600; // نارنجی
    return Colors.red.shade700; // قرمز
  }
}
