import 'dart:io';
import 'package:reuselt/models/donations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DonationService {
  final SupabaseClient _supabase = Supabase.instance.client;
  
  Future<Donation> getDonationById(String id) async {
  final response = await _supabase
      .from('donasi')
      .select()
      .eq('id', id)
      .single();

  return Donation.fromJson(response);
}

  Future<List<Donation>> getDonations({String? kategori, String? search, required String userId}) async {
    var query = _supabase.from('donasi').select('''
      *,
      users:nama
    ''');

    if (kategori != null && kategori.isNotEmpty) {
      query = query.eq('kategori', kategori);
    }

    if (search != null && search.isNotEmpty) {
      query = query.ilike('nama_barang', '%$search%');
    }

    final response = await query;
    return response.map<Donation>((json) => Donation.fromJson(json)).toList();
  }

  Future<void> addDonation({
    required String namaBarang,
    required String deskripsi,
    required List<File> imageFiles,
    required String kategori,
    required String nama,
    required double latitude,
    required double longitude,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("User belum login");

    // Upload multiple images
    final List<String> imageUrls = [];
    for (final imageFile in imageFiles) {
      final storagePath = 'donasi/${DateTime.now().millisecondsSinceEpoch}_${imageFiles.indexOf(imageFile)}.jpg';
      await _supabase.storage.from('donasi_images').upload(storagePath, imageFile);
      final imageUrl = _supabase.storage.from('donasi_images').getPublicUrl(storagePath);
      imageUrls.add(imageUrl);
    }

    // Get user data
    final userData = await _supabase
        .from('users')
        .select('nama')
        .eq('id', user.id)
        .single();

    // Insert to database
    await _supabase.from('donasi').insert({
      'nama_barang': namaBarang,
      'deskripsi': deskripsi,
      'foto_urls': imageUrls, // Gunakan array untuk multiple images
      'kategori': kategori,
      'latitude': latitude,
      'longitude': longitude,
      'user_id': user.id,
      'user_name': userData['nama'] ?? 'Unknown',
      'status': 'available', // Default status saat ditambahkan
    });
  }

  Future<void> updateDonation({
    required String id,
    required String namaBarang,
    required String deskripsi,
    required String kategori,
    List<File>? newImages, // Tambahkan opsi update gambar
  }) async {
    final updateData = {
      'nama_barang': namaBarang,
      'deskripsi': deskripsi,
      'kategori': kategori,
    };

    // Jika ada gambar baru
    if (newImages != null && newImages.isNotEmpty) {
      final List<String> newImageUrls = [];
      for (final imageFile in newImages) {
        final storagePath = 'donasi/${DateTime.now().millisecondsSinceEpoch}_${newImages.indexOf(imageFile)}.jpg';
        await _supabase.storage.from('donasi_images').upload(storagePath, imageFile);
        final imageUrl = _supabase.storage.from('donasi_images').getPublicUrl(storagePath);
        newImageUrls.add(imageUrl);
      }
      updateData['foto_urls'] = newImageUrls.first;
    }

    await _supabase.from('donasi').update(updateData).eq('id', id);
  }

  Future<void> deleteDonation(String id) async {
    // Hapus gambar terkait terlebih dahulu
    final donation = await _supabase
        .from('donasi')
        .select('foto_urls')
        .eq('id', id)
        .single();

    for (final url in donation['foto_urls']) {
      final path = url.split('/').last;
      await _supabase.storage.from('donasi_images').remove([path]);
    }

    // Hapus data dari database
    await _supabase.from('donasi').delete().eq('id', id);
  }

  Future<List<Donation>> getUserDonations({required String userId}) async {
    final response = await _supabase
        .from('donasi')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map((data) => Donation.fromJson(data)).toList();
  }

  Future<void> verifyDonation(String donationId) async {
    await _supabase
        .from('donasi')
        .update({'status': 'taken'})
        .eq('id', donationId);
  }
}
