import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GenerateQRScreen extends StatelessWidget {
  final String donationId;

  const GenerateQRScreen({required this.donationId, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Code Donasi"),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            QrImageView(
              data: donationId, // Encode donation ID ke QR
              version: QrVersions.auto,
              size: 200,
            ),
            SizedBox(height: 20),
            Text(
              "Scan QR Code ini untuk verifikasi pengambilan barang.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}