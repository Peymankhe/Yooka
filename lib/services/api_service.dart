import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class ApiService {
  static late String baseUrl;

  /// انتخاب آدرس API بر اساس Web / Android / iOS
  static void init() {
    if (kIsWeb) {
      baseUrl = "http://localhost:3000"; // برای اجرای روی Web
    } else {
      baseUrl = "http://10.0.2.2:3000"; // مخصوص Android emulator
    }
  }

  /// گرفتن محصول بر اساس بارکد
  static Future<Map<String, dynamic>?> getProductByBarcode(String barcode) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/products/barcode/$barcode");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint("❌ Error getProductByBarcode: $e");
      return null;
    }
  }

  /// دریافت تمام محصولات
  static Future<List<dynamic>> getAllProducts() async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/products");
      final response = await http.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint("❌ Error getAllProducts: $e");
      return [];
    }
  }

  /// افزودن یک محصول جدید
  static Future<bool> addProduct(Map<String, dynamic> productData) async {
    try {
      final url = Uri.parse("$baseUrl/api/v1/products");
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(productData),
      );

      return response.statusCode == 201;
    } catch (e) {
      debugPrint("❌ Error addProduct: $e");
      return false;
    }
  }
}
