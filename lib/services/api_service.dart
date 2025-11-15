import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api/v1';
  //static const String baseUrl = 'http://10.0.2.2:3000/api/v1'; 
  // توجه: در شبیه‌ساز اندروید به‌جای localhost از 10.0.2.2 استفاده می‌کنیم

  static Future<List<dynamic>> getProducts() async {
    final url = Uri.parse('$baseUrl/products');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('خطا در دریافت لیست محصولات');
    }
  }

  static Future<Map<String, dynamic>?> getProductByBarcode(String code) async {
    final url = Uri.parse('$baseUrl/products');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = json.decode(response.body);
      try {
        // پیدا کردن محصول با بارکد مشابه
        return data.firstWhere(
          (item) => item['barcode'] == code,
          orElse: () => null,
        );
      } catch (_) {
        return null;
      }
    } else {
      throw Exception('خطا در اتصال به سرور');
    }
  }
}
