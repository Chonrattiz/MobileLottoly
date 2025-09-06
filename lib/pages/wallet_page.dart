import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app_oracel999/pages/home.dart';
import 'package:app_oracel999/pages/navmenu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

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
  int? _walletBalance;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final url =
          Uri.parse('http://192.168.6.1:8080/wallet?user_id=${widget.userId}');
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // --- 4. แก้ไขวิธีดึงข้อมูลให้ตรงกับ JSON ที่ Backend ส่งมา ---
        // เราต้องเข้าไปใน object 'user' ก่อน แล้วค่อยดึง 'wallet'
        final balance = data['user']?['wallet'];

        if (balance is int) {
          setState(() {
            _walletBalance = balance;
            _isLoading = false;
          });
        } else {
          throw Exception('ไม่พบข้อมูล wallet ในรูปแบบที่ถูกต้อง');
        }
      } else {
        throw Exception('ไม่สามารถโหลดข้อมูลได้: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _errorMessage = "เกิดข้อผิดพลาด: ${e.toString()}";
        _isLoading = false;
      });
    }
  }

  String _formatBalance(int? balance) {
    if (balance == null) return 'N/A';
    return NumberFormat('#,###').format(balance);
  }

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFAD0101);
    final green = const Color.fromARGB(255, 1, 173, 10);
    final gold = const Color(0xFFE3BB66);

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
          title: Text('กระเป๋า',
              style: GoogleFonts.itim(
                  fontWeight: FontWeight.bold,
                  fontSize: 30,
                  color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    username: widget.username,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
        ),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : _errorMessage != null
                  ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(_errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.yellow, fontSize: 16)),
                  )
                  : _buildWalletContent(gold, green),
        ),
        bottomNavigationBar: MyBottomNavigationBar(
          username: widget.username,
          userId: widget.userId,
        ),
      ),
    );
  }
  Widget _buildWalletContent(Color gold, Color green) {
    return ListView(
      children: [
        const SizedBox(height: 150),
        Center(
          child: Container(
            width: 350,
            height: 350,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: gold,
              shape: BoxShape.circle,
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: green,
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('ยอดเงินคงเหลือ',
                      style: GoogleFonts.itim(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Text(
                    // ส่วนนี้ไม่ต้องแก้ไข เพราะมันจะดึงค่าจาก _walletBalance ให้อัตโนมัติ
                    _formatBalance(_walletBalance),
                    style: GoogleFonts.itim(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold),
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

