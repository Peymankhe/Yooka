import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'screens/scan_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/product_list_screen.dart';
import 'services/api_service.dart';
import 'models/product_model.dart';

void main() {
  ApiService.init(); // انتخاب اتوماتیک URL API
  runApp(const YookaApp());
}

class YookaApp extends StatelessWidget {
  const YookaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yooka – یوکا',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Vazirmatn',
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? scannedCode;
  Product? scannedProduct;

  /// تاریخچه آخرین ۵ بارکد
  List<String> barcodeHistory = [];

  void _addBarcodeToHistory(String code) {
    if (!barcodeHistory.contains(code)) {
      barcodeHistory.insert(0, code);
      if (barcodeHistory.length > 5) {
        barcodeHistory.removeLast();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('یوکا – آنالیز محصول'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.qr_code_scanner, size: 90, color: Colors.green),
              const SizedBox(height: 10),
              const Text(
                'برای اسکن یا مشاهده محصولات، یکی از گزینه‌های زیر را انتخاب کنید',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // دکمه اسکن
              ElevatedButton.icon(
                onPressed: _scanBarcode,
                icon: const Icon(Icons.camera_alt),
                label: const Text('اسکن محصول'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
              ),

              const SizedBox(height: 15),

              // دکمه لیست محصولات
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductListScreen()));
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('لیست محصولات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                ),
              ),

              const SizedBox(height: 30),

              // کارت نمایش بارکد اسکن‌شده
              if (scannedCode != null) _buildScannedBarcodeCard(),

              const SizedBox(height: 20),

              // نمایش تاریخچه آخرین ۵ بارکد
              if (barcodeHistory.isNotEmpty) _buildHistoryList(),
            ],
          ),
        ),
      ),
    );
  }

  /// اسکن بارکد
  Future<void> _scanBarcode() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    );

    if (result != null) {
      setState(() {
        scannedCode = result.toString();
        _addBarcodeToHistory(result.toString());
      });

      final product = await ApiService.getProductByBarcode(result.toString());
      if (product != null) {
        scannedProduct = Product.fromJson(product);
        _showProductDialog(scannedProduct!);
      } else {
        _showProductNotFoundDialog(result.toString());
      }
    }
  }

  /// UI کارت بارکد اسکن‌شده
  Widget _buildScannedBarcodeCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.qr_code_2, size: 30, color: Colors.green),
                const SizedBox(width: 10),
                const Text('بارکد اسکن‌شده', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.copy, color: Colors.blue),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: scannedCode!));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(content: Text('بارکد کپی شد')));
                  },
                )
              ],
            ),

            const SizedBox(height: 10),

            // نمایش شماره بارکد
            SelectableText(
              scannedCode!,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // نمایش تصویر بارکد
            BarcodeWidget(
              data: scannedCode!,
              barcode: Barcode.code128(),
              width: 230,
              height: 80,
            ),
          ],
        ),
      ),
    );
  }

  /// تاریخچه بارکدها
  Widget _buildHistoryList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('آخرین بارکدهای اسکن‌شده:',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        ...barcodeHistory.map((code) => ListTile(
              leading: const Icon(Icons.history, color: Colors.grey),
              title: Text(code),
              trailing: IconButton(
                icon: const Icon(Icons.copy, color: Colors.blue),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context)
                      .showSnackBar(const SnackBar(content: Text('بارکد کپی شد')));
                },
              ),
            )),
      ],
    );
  }

  /// پیام محصول یافت نشد
  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('محصول یافت نشد'),
        content: Text('محصولی با بارکد $barcode در دیتابیس موجود نیست.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('بستن')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => AddProductScreen(barcode: barcode)),
              );
            },
            child: const Text('افزودن محصول'),
          ),
        ],
      ),
    );
  }

  /// نمایش اطلاعات محصول
  void _showProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product.name),
        content: Text('امتیاز: ${product.overallScore}\nبارکد: ${product.barcode}'),
      ),
    );
  }
}
