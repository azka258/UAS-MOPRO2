import 'package:flutter/material.dart';
import 'package:reuselt/models/donations.dart';
import 'package:reuselt/screens/home/add_donation_screen.dart';
import 'package:reuselt/screens/home/donation_det_screen.dart';
import 'package:reuselt/screens/home/generate_qr_screen.dart'; // Import halaman Generate QR
import 'package:reuselt/services/donation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyDonationsScreen extends StatefulWidget {
  @override
  _MyDonationsScreenState createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  final DonationService _donationService = DonationService();
  List<Donation> _myDonations = [];

  @override
  void initState() {
    super.initState();
    _fetchMyDonations();
  }

  Future<void> _fetchMyDonations() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final donations = await _donationService.getUserDonations(userId: user.id);
    setState(() {
      _myDonations = donations;
    });
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: Text(
        'Barang Saya',
        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green, Colors.lightGreen],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 10,
    ),
    body: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Color(0xFFF5F5F5)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: _myDonations.isEmpty
          ? Center(
              child: Text(
                "Belum ada barang yang didonasikan",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _myDonations.length,
              itemBuilder: (context, index) {
                final donation = _myDonations[index];
                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DonationDetScreen(donation: donation),
                      ),
                    ).then((_) => _fetchMyDonations());
                  },
                  child: Card(
                    elevation: 4,
                    margin: EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Grid Horizontal untuk Gambar
                          SizedBox(
                            height: 100,
                            child: donation.fotoUrls.isNotEmpty
                                ? ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: donation.fotoUrls.length,
                                    itemBuilder: (context, imgIndex) {
                                      return Padding(
                                        padding: EdgeInsets.only(right: 8),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.network(
                                            donation.fotoUrls[imgIndex],
                                            width: 100,
                                            height: 100,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                                Icon(Icons.image_not_supported, size: 100),
                                          ),
                                        ),
                                      );
                                    },
                                  )
                                : Center(
                                    child: Icon(Icons.image, size: 100),
                                  ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            donation.namaBarang,
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4),
                          Text(
                            donation.kategori,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Status: ${donation.status}', // Menampilkan status
                            style: TextStyle(
                              color: donation.status == 'Diterima' ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              // Tombol Generate QR
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => GenerateQRScreen(donationId: donation.id),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  "Generate QR",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(Icons.arrow_forward_ios, color: Colors.green, size: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    ),
    floatingActionButton: FloatingActionButton(
      child: Icon(Icons.add, color: Colors.white),
      backgroundColor: Colors.green,
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => AddDonationScreen()),
        ).then((_) => _fetchMyDonations());
      },
    ),
  );
}
}