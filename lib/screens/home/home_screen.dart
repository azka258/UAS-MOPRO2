import 'package:flutter/material.dart';
import 'package:reuselt/models/donations.dart';
import 'package:reuselt/screens/auth/login_screen.dart';
import 'package:reuselt/screens/chat/chat_screen.dart';
import 'package:reuselt/screens/home/add_donation_screen.dart';
import 'package:reuselt/screens/home/my_donations_screen.dart';
import 'package:reuselt/screens/home/profile_screen.dart';
import 'package:reuselt/screens/home/scan_qr_screen.dart';
import 'package:reuselt/services/donation_service.dart';
import 'package:reuselt/widgets/donation_card.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DonationService _donationService = DonationService();
  String nama = Supabase.instance.client.auth.currentUser?.email ?? 'Unknown';
  List<Donation> _donations = [];
  String _selectedCategory = '';
  String _searchQuery = '';
  Map<String, String> _locationNames = {};
  int _selectedIndex = 0; // Untuk mengontrol tab yang aktif
  bool _isDisposed = false; // Flag to track if the widget is disposed

  @override
  void initState() {
    super.initState();
    _fetchDonations();
  }

  @override
  void dispose() {
    _isDisposed = true; // Set the flag to true when the widget is disposed
    super.dispose();
  }

  Future<void> _fetchDonations() async {
    final donations = await _donationService.getDonations(
      kategori: _selectedCategory.isNotEmpty ? _selectedCategory : null,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      userId: '',
    );

    if (_isDisposed) return; // Check if the widget is disposed

    setState(() {
      _donations = donations;
    });

    _fetchLocationNames();
  }

  Future<void> _fetchLocationNames() async {
    if (_donations.isEmpty || _isDisposed) return; // Check if the widget is disposed

    final Map<String, String> newLocationNames = {};
    for (final donation in _donations) {
      final locationName = await getLocationName(donation.latitude, donation.longitude);
      newLocationNames[donation.id] = locationName;
    }

    if (_isDisposed) return; // Check if the widget is disposed

    setState(() {
      _locationNames = newLocationNames;
    });
  }

  Future<String> getLocationName(double latitude, double longitude) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['display_name'] ?? 'Tidak Diketahui';
      }
    } catch (e) {
      print("Error fetching location: $e");
    }
    return 'Tidak Diketahui';
  }

  Future<void> _logout(BuildContext context) async {
    bool? confirmLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Logout"),
          content: Text("Apakah Anda yakin ingin keluar?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Batal"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      await Supabase.instance.client.auth.signOut();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyDonationsScreen()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logo.png',
              height: 35,
              width: 35,
            ),
            SizedBox(width: 8),
            Text(
              'Donasi Barang',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
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
        elevation: 4,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchDonations,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            // Search Bar dan Kategori
            Padding(
              padding: EdgeInsets.all(16),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: 'Cari barang...',
                            border: InputBorder.none,
                            icon: Icon(Icons.search, color: Colors.grey),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                            _fetchDonations();
                          },
                        ),
                      ),
                      DropdownButton<String>(
                        value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                        hint: Text("Kategori"),
                        items: ['Elektronik', 'Pakaian', 'Buku', 'Makanan', 'Lainnya'].map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value ?? '';
                          });
                          _fetchDonations();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // List Donasi
            Expanded(
              child: _donations.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ada donasi tersedia",
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _donations.length,
                      itemBuilder: (context, index) {
                        final donation = _donations[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: DonationCard(
                            donation: donation,
                            locationName: _locationNames[donation.id] ?? 'Loading...',
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Donasi Saya',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'scanButton',
            mini: true,
            backgroundColor: Colors.green,
            child: Icon(Icons.qr_code_scanner, color: Colors.white),
            onPressed: () async {
              final donationId = await Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => ScanQRScreen()),
);
if (donationId != null && mounted) {
  await _donationService.verifyDonation(donationId);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text("Verifikasi pengambilan berhasil!")));
  _fetchDonations(); // Refresh daftar donasi
}
            },
          ),
          SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'addButton',
            child: Icon(Icons.add, color: Colors.white),
            backgroundColor: Colors.green,
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => AddDonationScreen()),
            ).then((_) {
              if (mounted) {
                _fetchDonations(); // Only refresh if the widget is still mounted
              }
            }),
          ),
        ],
      ),
    );
  }
}