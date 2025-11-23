import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AddProductScreen extends StatefulWidget {
  final String barcode;
  const AddProductScreen({super.key, required this.barcode});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();
  final scoreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('افزودن محصول جدید')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('بارکد: ${widget.barcode}', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'نام محصول'),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: scoreController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'امتیاز (0 تا 100)'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                final name = nameController.text.trim();
                final score = int.tryParse(scoreController.text.trim()) ?? 0;

                final newProduct = {
                  "name": name,
                  "barcode": widget.barcode,
                  "overallScore": score,
                  "additives": []
                };

                await ApiService.addProduct(newProduct);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('محصول با موفقیت اضافه شد')),
                );

                Navigator.pop(context);
              },
              child: const Text('ثبت محصول'),
            )
          ],
        ),
      ),
    );
  }
}
