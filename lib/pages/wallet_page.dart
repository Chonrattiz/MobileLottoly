// lib/pages/wallet_page.dart

import 'package:app_oracel999/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- Imports  ---
import '../api/api_service.dart';
import '../model/response/wallet_response.dart';
import 'navmenu.dart';

class WalletPage extends StatefulWidget {
  final String userId;
  final String username;

  const WalletPage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<WalletPage> createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  final _apiService = ApiService();
  late Future<Wallet> _walletFuture; // 1. ใช้ FutureBuilder จัดการ State

  @override
  void initState() {
    super.initState();
    // 2. เรียก API แค่ครั้งเดียวตอนเปิดหน้า
    _walletFuture = _apiService.fetchWalletBalance(widget.userId);
  }

  String _formatBalance(int? balance) {
    if (balance == null) return 'N/A';
    return NumberFormat('#,###').format(balance);
  }

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFAD0101);
    final gold = const Color(0xFFE3BB66);
    final green = const Color.fromARGB(255, 1, 173, 10);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/bg4.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          toolbarHeight: 80,
          title: Text('กระเป๋า', style: GoogleFonts.itim(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(username: widget.username, userId: widget.userId)),
            ),
          ),
        ),
        // --- 3. ใช้ FutureBuilder ในการแสดงผล ---
        body: FutureBuilder<Wallet>(
          future: _walletFuture,
          builder: (context, snapshot) {
            // --- สถานะ: กำลังโหลด ---
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Colors.white));
            }
            // --- สถานะ: เกิดข้อผิดพลาด ---
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  "เกิดข้อผิดพลาด:\n${snapshot.error.toString().replaceFirst('Exception: ', '')}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.yellow, fontSize: 16),
                ),
              );
            }
            // --- สถานะ: โหลดสำเร็จและมีข้อมูล ---
            if (snapshot.hasData) {
              final wallet = snapshot.data!;
              return _buildWalletContent(gold, green, wallet.balance);
            }
            // --- สถานะอื่นๆ (เช่น ไม่มีข้อมูล) ---
            return const Center(child: Text('ไม่พบข้อมูล', style: TextStyle(color: Colors.white)));
          },
        ),
        bottomNavigationBar: MyBottomNavigationBar(
          username: widget.username,
          userId: widget.userId,
        ),
      ),
    );
  }

  // --- 4. ปรับปรุง Widget ให้รับค่า balance มาแสดงผล ---
  Widget _buildWalletContent(Color gold, Color green, int balance) {
    return ListView(
      children: [
        const SizedBox(height: 150),
        Center(
          child: Container(
            width: 350,
            height: 350,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: gold, shape: BoxShape.circle),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(color: green, shape: BoxShape.circle),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ยอดเงินคงเหลือ', style: GoogleFonts.itim(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text(
                    _formatBalance(balance),
                    style: GoogleFonts.itim(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}