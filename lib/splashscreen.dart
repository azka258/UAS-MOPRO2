import 'package:flutter/material.dart';
import 'package:reuselt/screens/auth/login_screen.dart'; // Sesuaikan dengan halaman tujuan setelah splash screen

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(Duration(seconds: 3)); // Durasi splash screen
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Ganti dengan halaman tujuan
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green, // Warna background sesuai tema
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo.png', // Path ke logo Anda
              width: 150,
              height: 150,
            ),
            SizedBox(height: 20),
            Text(
              'Donasi Barang',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10),
            CircularProgressIndicator(
              color: Colors.white, // Warna loading indicator
            ),
          ],
        ),
      ),
    );
  }
}