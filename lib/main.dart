import 'package:flutter/material.dart';
import 'package:reuselt/splashscreen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/auth/login_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://iwsyhrcadfqaeripbnef.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Iml3c3locmNhZGZxYWVyaXBibmVmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzk1ODk2NDEsImV4cCI6MjA1NTE2NTY0MX0._pgF4HWb_JwFBzUtYJgjpvL3fno1iCRj0Dz7LpLubr8',
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:SplashScreen(),
    );
  }
}
