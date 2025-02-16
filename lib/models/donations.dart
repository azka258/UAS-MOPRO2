import 'dart:convert';

class Donation {
  final String id;
  final String namaBarang;
  final String deskripsi;
  final List<String> fotoUrls;
  final String kategori;
  final String userId;
  final double latitude;
  final double longitude;
  final String status; // Tambah field status

  Donation({
    required this.id,
    required this.namaBarang,
    required this.deskripsi,
    required this.fotoUrls,
    required this.kategori,
    required this.userId,
    required this.latitude,
    required this.longitude,
    this.status = 'available', // Default status 'available'
  });

  factory Donation.fromJson(Map<String, dynamic> json) {
    return Donation(
      id: json['id'],
      namaBarang: json['nama_barang'],
      deskripsi: json['deskripsi'],
      fotoUrls: _parseFotoUrls(json['foto_urls']),
      kategori: json['kategori'],
      userId: json['user_id'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      status: json['status'] ?? 'available', // Handle null value
    );
  }

  static List<String> _parseFotoUrls(dynamic fotoUrls) {
    if (fotoUrls == null) return [];
    if (fotoUrls is List) {
      return List<String>.from(fotoUrls);
    }
    if (fotoUrls is String) {
      try {
        final parsed = jsonDecode(fotoUrls) as List<dynamic>;
        return parsed.map((e) => e.toString()).toList();
      } catch (e) {
        return [];
      }
    }
    return [];
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_barang': namaBarang,
      'deskripsi': deskripsi,
      'foto_urls': fotoUrls,
      'kategori': kategori,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'status': status, // Sertakan status
    };
  }
}