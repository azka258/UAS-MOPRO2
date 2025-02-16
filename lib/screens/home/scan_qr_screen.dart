import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:reuselt/models/donations.dart';
import 'package:reuselt/services/donation_service.dart';
import 'package:reuselt/widgets/donation_card.dart';

class ScanQRScreen extends StatefulWidget {
  @override
  _ScanQRScreenState createState() => _ScanQRScreenState();
}

class _ScanQRScreenState extends State<ScanQRScreen> {
  MobileScannerController cameraController = MobileScannerController();
  Donation? _scannedDonation;
  final DonationService _donationService = DonationService();
  bool _isLoading = false;

  Future<void> _verifyAndShowDonation(String donationId) async {
    setState(() => _isLoading = true);
    
    try {
      // 1. Verify donation
      await _donationService.verifyDonation(donationId);
      
      // 2. Get donation details
      final donation = await _donationService.getDonationById(donationId);
      
      // 3. Update UI
      setState(() {
        _scannedDonation = donation;
        _isLoading = false;
      });

    } catch (e) {
      setState(() => _isLoading = false);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Error"),
          content: Text(e.toString()),
        ),
      );
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
        backgroundColor: Colors.green,
        actions: [
          if (_scannedDonation != null)
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () => setState(() => _scannedDonation = null),
            )
        ],
      ),
      body: Stack(
        children: [
          // Bagian Kamera (Pastikan mengisi seluruh layar)
          SizedBox.expand(
            child: MobileScanner(
              controller: cameraController,
              onDetect: (capture) {
                if (_scannedDonation != null || _isLoading) return;
                
                final barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _verifyAndShowDonation(barcode.rawValue!);
                  }
                }
              },
            ),
          ),

          // Overlay Loading
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),

          // Overlay Hasil Scan
          if (_scannedDonation != null)
            Container(
              color: Colors.black54,
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DonationCard(
                    donation: _scannedDonation!,
                    locationName: "Lokasi Donasi",
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.check_circle),
                    label: Text("Konfirmasi Pengambilan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    onPressed: () => Navigator.pop(context, _scannedDonation!.id),
                  ),
                  SizedBox(height: 15),
                  TextButton(
                    child: Text(
                      "Scan Lagi",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onPressed: () => setState(() => _scannedDonation = null),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}