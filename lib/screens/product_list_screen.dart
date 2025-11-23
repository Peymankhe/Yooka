import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _fetchProducts();
  }

  Future<List<Product>> _fetchProducts() async {
    final data = await ApiService.getAllProducts();
    return data.map<Product>((p) => Product.fromJson(p)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لیست محصولات'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text('خطا در دریافت داده: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('هیچ محصولی یافت نشد.'),
            );
          }

          final products = snapshot.data!;
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                color: product.color.withOpacity(0.1),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: product.color,
                    radius: 25,
                    child: Text(
                      product.overallScore.toString(),
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text('وضعیت: ${product.healthLevel}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    _showProductDetails(context, product);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showProductDetails(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(product.name),
        content: Column(
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
                  riskColor = Colors.orange;
                  break;
                case 'high':
                  riskColor = Colors.red;
                  break;
                default:
                  riskColor = Colors.grey;
              }

              return ListTile(
                leading: Icon(Icons.circle, color: riskColor, size: 14),
                title: Text('${a.code} - ${a.name}'),
                subtitle: Text('سطح خطر: ${a.riskLevel}'),
              );
            }),
          ],
        ),
      ),
    );
  }
}
