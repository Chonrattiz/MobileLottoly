import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // 1. import package provider
import 'package:app_oracel999/pages/login.dart';
import 'package:app_oracel999/providers/cart_provider.dart'; // 2. import "สมอง" ของตะกร้า

void main() {
  // 3. ครอบแอปทั้งหมดด้วย ChangeNotifierProvider
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(), // <-- สร้าง "สมอง" ของตะกร้าที่นี่
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lotto Login',
      theme: ThemeData(primarySwatch: Colors.deepOrange), // เปลี่ยนสี Theme เล็กน้อย
      home: const LoginPage(), // เริ่มที่หน้า Login โดยตรง
    );
  }
}
