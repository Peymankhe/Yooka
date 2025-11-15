import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اسکن بارکد محصول')),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (barcode) {
              if (!scanned && barcode.barcodes.isNotEmpty) {
                scanned = true;
                final code = barcode.barcodes.first.rawValue ?? '';
                Navigator.pop(context, code); // برگرداندن کد به صفحه قبل
              }
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.black54,
              padding: const EdgeInsets.all(12),
              child: const Text(
                'بارکد را جلوی دوربین بگیر...',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
