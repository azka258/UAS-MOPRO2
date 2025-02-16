import 'package:flutter/material.dart';
import 'package:reuselt/models/donations.dart';
import 'package:reuselt/screens/chat/chat_detail_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DonationDetailScreen extends StatefulWidget {
  final Donation donation;

  const DonationDetailScreen({required this.donation, super.key});

  @override
  _DonationDetailScreenState createState() => _DonationDetailScreenState();
}

class _DonationDetailScreenState extends State<DonationDetailScreen> {
  String donorName = 'Tidak Diketahui';
  String locationName = 'Loading lokasi...';

  @override
  void initState() {
    super.initState();
    _fetchDonorName();
    _fetchLocationName();
  }

  Future<void> _fetchDonorName() async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('nama')
          .eq('id', widget.donation.userId)
          .maybeSingle();

      if (mounted) {
        setState(() {
          donorName = response?['nama'] ?? 'Tidak Diketahui';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          donorName = 'Tidak Diketahui';
        });
      }
    }
  }

  Future<void> _fetchLocationName() async {
    final lat = widget.donation.latitude;
    final lon = widget.donation.longitude;

    if (lat == null || lon == null) {
      if (mounted) {
        setState(() {
          locationName = 'Lokasi tidak tersedia';
        });
      }
      return;
    }

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (mounted) {
          setState(() {
            locationName = data['display_name'] ?? 'Lokasi tidak ditemukan';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          locationName = 'Lokasi tidak ditemukan';
        });
      }
    }
  }

  void _navigateToChat() {
    final donationDetailsMessage = '''
    **Rincian Donasi**
    Nama Barang: ${widget.donation.namaBarang}
    Kategori: ${widget.donation.kategori}
    Deskripsi: ${widget.donation.deskripsi}
    Lokasi: $locationName
    Donatur: $donorName
    Foto: ${widget.donation.fotoUrls.join(', ')}
    ''';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatDetailScreen(
          receiverId: widget.donation.userId,
          receiverName: donorName,
          initialMessage: donationDetailsMessage,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.donation.namaBarang,
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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: widget.donation.fotoUrls.isNotEmpty
                      ? GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // Jumlah kolom dalam grid
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                          itemCount: widget.donation.fotoUrls.length,
                          itemBuilder: (context, index) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                widget.donation.fotoUrls[index],
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(Icons.image_not_supported),
                              ),
                            );
                          },
                        )
                      : Icon(Icons.image, size: 200),
                ),
              ),
              SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.donation.namaBarang,
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Kategori: ${widget.donation.kategori}",
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 8),
                      Text(
                        widget.donation.deskripsi,
                        style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                      ),
                      SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(Icons.person, size: 18, color: Colors.blueGrey),
                          SizedBox(width: 8),
                          Text(
                            "Donatur: $donorName",
                            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.location_on, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Lokasi: $locationName",
                              style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800]),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              Center(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.lightGreen],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ElevatedButton(
                    onPressed: _navigateToChat,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Chat dengan Donatur",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}