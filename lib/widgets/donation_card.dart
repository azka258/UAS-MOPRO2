import 'package:flutter/material.dart';
import '../models/donations.dart';
import '../screens/home/donation_detail_screen.dart';

class DonationCard extends StatelessWidget {
  final Donation donation;
  final String locationName;

  const DonationCard({
    required this.donation,
    required this.locationName,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        enabled: donation.status != 'taken', // Nonaktifkan jika status 'taken'
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: donation.fotoUrls.isNotEmpty
              ? Image.network(
                  donation.fotoUrls.first, // Ambil gambar pertama dari list
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      Icon(Icons.image_not_supported, size: 50),
                )
              : Icon(Icons.image, size: 50), // Placeholder jika tidak ada gambar
        ),
        title: Text(
          donation.namaBarang,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              donation.deskripsi,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey),
                SizedBox(width: 4),
                Expanded(
                  child: Text(
                    locationName,
                    style: TextStyle(color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            Chip(
              backgroundColor: donation.status == 'taken' 
                  ? Colors.grey 
                  : Colors.green,
              label: Text(
                donation.status == 'taken' 
                    ? 'Sudah Diambil' 
                    : 'Tersedia',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        onTap: donation.status != 'taken' // Hanya aktif jika status bukan 'taken'
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DonationDetailScreen(donation: donation),
                  ),
                );
              }
            : null, // Nonaktifkan onTap jika status 'taken'
      ),
    );
  }
}