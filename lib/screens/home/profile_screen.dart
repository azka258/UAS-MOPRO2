import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;
  String? _profilePictureUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
  final user = Supabase.instance.client.auth.currentUser;
  if (user != null) {
    try {
      // Ambil data pengguna dari tabel `users` (nama dan URL foto profil)
      final response = await Supabase.instance.client
          .from('users')
          .select('nama, profile_picture_url')
          .eq('id', user.id)
          .single();

      setState(() {
        _nameController.text = response['nama'] ?? 'Unknown';
        _profilePictureUrl = response['profile_picture_url'];
      });
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() {
        _nameController.text = 'Unknown';
        _profilePictureUrl = null;
      });
    }
  }
}

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateProfile() async {
  if (_formKey.currentState!.validate()) {
    setState(() {
      _isLoading = true;
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        String? imageUrl;

        // Upload gambar profil jika dipilih
        if (_imageFile != null) {
          final fileExtension = _imageFile!.path.split('.').last;
          final fileName = '${user.id}.$fileExtension';
          await Supabase.instance.client.storage
              .from('profile_pictures')
              .upload(fileName, _imageFile!);

          // Dapatkan URL gambar yang diunggah
          imageUrl = Supabase.instance.client.storage
              .from('profile_pictures')
              .getPublicUrl(fileName);
        }

        // Update nama dan URL foto profil di tabel `users`
        await Supabase.instance.client.from('users').update({
          'nama': _nameController.text,
          if (imageUrl != null) 'profile_picture_url': imageUrl,
        }).eq('id', user.id);

        // Update password jika diisi
        if (_passwordController.text.isNotEmpty) {
          await Supabase.instance.client.auth.updateUser(
            UserAttributes(password: _passwordController.text),
          );
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memperbarui profil: $e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil Saya'),
        backgroundColor: Colors.green,
        elevation: 4,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Foto Profil
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _imageFile != null
                        ? FileImage(_imageFile!)
                        : _profilePictureUrl != null
                            ? NetworkImage(_profilePictureUrl!)
                            : AssetImage('assets/default_profile.png') as ImageProvider,
                    child: _imageFile == null && _profilePictureUrl == null
                        ? Icon(Icons.camera_alt, size: 30, color: Colors.white)
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Nama
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nama',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Nama tidak boleh kosong';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20),
              // Password
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Password Baru',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              // Tombol Simpan
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Simpan Perubahan',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}