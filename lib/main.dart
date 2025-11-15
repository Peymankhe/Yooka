import 'package:flutter/material.dart';
import 'screens/scan_screen.dart';
import 'screens/product_list_screen.dart';
import 'services/api_service.dart';
import 'models/product_model.dart';

void main() {
  runApp(const YookaApp());
}

class YookaApp extends StatelessWidget {
  const YookaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Yooka',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        fontFamily: 'Vazirmatn',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Yooka – آنالیز محصول'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.qr_code_scanner, size: 100, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                'برای اسکن یا مشاهده محصولات، یکی از گزینه‌های زیر را انتخاب کنید',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              /// --- دکمه اسکن ---
              ElevatedButton.icon(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ScanScreen()),
                  );

                  if (result != null && mounted) {
                    setState(() => scannedCode = result.toString());
                    try {
                      final product = await ApiService.getProductByBarcode(result.toString());
                      if (product != null) {
                        setState(() => scannedProduct = Product.fromJson(product));
                        _showProductDialog(scannedProduct!);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('محصولی با این بارکد یافت نشد')),
                        );
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('خطا در اتصال به سرور: $e')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('اسکن محصول'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 15),

              /// --- دکمه لیست محصولات ---
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProductListScreen()),
                  );
                },
                icon: const Icon(Icons.list_alt),
                label: const Text('لیست محصولات'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                ),
              ),

              const SizedBox(height: 40),

              /// --- نمایش آخرین اسکن ---
              if (scannedProduct != null) ...[
                const Text(
                  'آخرین محصول اسکن‌شده:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Card(
                  color: scannedProduct!.color.withOpacity(0.1),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: scannedProduct!.color,
                      child: Text(
                        scannedProduct!.overallScore.toString(),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(scannedProduct!.name),
                    subtitle: Text('وضعیت: ${scannedProduct!.healthLevel}'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// --- نمایش جزئیات محصول در Dialog ---
  void _showProductDialog(Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product.name),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('بارکد: ${product.barcode}'),
              const SizedBox(height: 10),
              Text('امتیاز: ${product.overallScore} / 100'),
              const SizedBox(height: 10),
              Text('وضعیت: ${product.healthLevel}'),
              const Divider(),
              const Text('افزودنی‌ها:'),
              const SizedBox(height: 8),
              ...product.additives.map((a) {
                Color riskColor;
                switch (a.riskLevel) {
                  case 'safe':
                    riskColor = Colors.green.shade700;
                    break;
                  case 'low':
                    riskColor = Colors.green.shade300;
                    break;
                  case 'medium':
                    riskColor = Colors.orange.shade600;
                    break;
                  case 'high':
                    riskColor = Colors.red.shade700;
                    break;
                  default:
                    riskColor = Colors.grey;
                }

                return Card(
                  color: riskColor.withOpacity(0.15),
                  child: ListTile(
                    title: Text('${a.code} - ${a.name}'),
                    subtitle: Text('سطح خطر: ${a.riskLevel}'),
                    leading: Icon(Icons.circle, color: riskColor, size: 12),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
