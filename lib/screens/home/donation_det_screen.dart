import 'package:flutter/material.dart';
import 'package:reuselt/models/donations.dart';
import 'package:reuselt/screens/chat/chat_detail_screen.dart';
import 'package:reuselt/services/donation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DonationDetScreen extends StatefulWidget {
  final Donation donation;

  const DonationDetScreen({required this.donation, super.key});

  @override
  _DonationDetScreenState createState() => _DonationDetScreenState();
}

class _DonationDetScreenState extends State<DonationDetScreen> {
  final DonationService _donationService = DonationService();
  final _namaController = TextEditingController();
  final _deskripsiController = TextEditingController();
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _namaController.text = widget.donation.namaBarang;
    _deskripsiController.text = widget.donation.deskripsi;
    _selectedCategory = widget.donation.kategori;
  }

  Future<void> _updateDonation() async {
    if (_namaController.text.isEmpty || _deskripsiController.text.isEmpty || _selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lengkapi semua data!')),
      );
      return;
    }

    bool? confirm = await _showConfirmationDialog(
      title: "Konfirmasi Update",
      content: "Apakah Anda yakin ingin mengupdate donasi ini?",
    );

    if (confirm == true) {
      await _donationService.updateDonation(
        id: widget.donation.id,
        namaBarang: _namaController.text,
        deskripsi: _deskripsiController.text,
        kategori: _selectedCategory!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Donasi berhasil diperbarui!')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<void> _deleteDonation() async {
    bool? confirm = await _showConfirmationDialog(
      title: "Konfirmasi Hapus",
      content: "Apakah Anda yakin ingin menghapus donasi ini? Tindakan ini tidak dapat dibatalkan.",
    );

    if (confirm == true) {
      await _donationService.deleteDonation(widget.donation.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Donasi berhasil dihapus!')),
        );
        Navigator.pop(context, true);
      }
    }
  }

  Future<bool?> _showConfirmationDialog({required String title, required String content}) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Ya'),
            ),
          ],
        );
      },
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
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.white),
            onPressed: _deleteDonation,
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
                    children: [
                      TextField(
                        controller: _namaController,
                        decoration: InputDecoration(
                          labelText: 'Nama Barang',
                          prefixIcon: Icon(Icons.shopping_bag, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextField(
                        controller: _deskripsiController,
                        decoration: InputDecoration(
                          labelText: 'Deskripsi',
                          prefixIcon: Icon(Icons.description, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        maxLines: 3,
                      ),
                      SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Kategori',
                          prefixIcon: Icon(Icons.category, color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        value: _selectedCategory,
                        items: ['Elektronik', 'Pakaian', 'Buku', 'Makanan', 'Lainnya']
                            .map((kategori) => DropdownMenuItem(
                                  value: kategori,
                                  child: Text(kategori),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        },
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
                    onPressed: _updateDonation,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Update Donasi',
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
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
                    onPressed: () async {
                      String donorName = await getDonorName(widget.donation.userId);
                      if (mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatDetailScreen(
                              receiverId: widget.donation.userId,
                              receiverName: donorName,
                            ),
                          ),
                        );
                      }
                    },
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

  Future<String> getDonorName(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('nama')
          .eq('id', userId)
          .maybeSingle();

      return response?['nama'] ?? 'Tidak Diketahui';
    } catch (e) {
      return 'Tidak Diketahui';
    }
  }
}