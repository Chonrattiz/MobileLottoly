// File: LotteryCheckerPage.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/pages/home.dart';
import 'package:myproject/pages/navmenu.dart';
import 'bottom_navigation_bar.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(home: LotteryCheckerPage());
//   }
// }

class LotteryCheckerPage extends StatelessWidget {
  const LotteryCheckerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EE), // Background color
      appBar: AppBar(
        backgroundColor: const Color(0xFFE4222C), // สีแดง
        elevation: 0,
        toolbarHeight: 120.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(username: ''),
              ),
            );
          },
        ),
        title: Text(
          'ตรวจรางวัล', // เปลี่ยนข้อความเป็น "ตรวจรางวัล"
          style: GoogleFonts.itim(
            color: Colors.white,
            fontSize: 36, // ปรับขนาดตัวอักษร
          ),
        ),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: NetworkImage('assets/image/bg4.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildSearchBar(),
              const SizedBox(height: 20),
              _buildPrizeSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const MyBottomNavigationBar(),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFE4DD05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF057CE4)),
        child: Column(
          children: [
            Text(
              'ตรวจผลสลากของคุณ',
              style: GoogleFonts.itim(color: Colors.white, fontSize: 32),
            ),
            const SizedBox(height: 12),
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 255, 255, 255),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Color.fromARGB(255, 0, 0, 0)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      keyboardType: TextInputType.number,
                      style: GoogleFonts.itim(
                        fontSize: 24,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 20,
                      ),
                      textAlign: TextAlign.center,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'X X X X X X',
                        hintStyle: TextStyle(
                          fontSize: 24,
                          color: Color.fromARGB(255, 172, 172, 172),
                          fontWeight: FontWeight.bold,
                          letterSpacing: 10,
                        ),
                        counterText: "",
                      ),
                      maxLength: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B2E4A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(200, 40),
              ),
              child: Text(
                'ตรวจรางวัล',
                style: GoogleFonts.lato(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          // รางวัลที่ 1
          _buildPrizeCard(
            'รางวัลที่ 1',
            '844322',
            'Jackpot 999,999 ฿',
            const Color(0xFFAD0101),
            height: 150,
            numberFontSize: 36,
            titleFontSize: 20,
            amountFontSize: 20,
          ),
          const SizedBox(height: 16),
          // รางวัลที่ 2 และ 3
          Row(
            children: [
              Expanded(
                child: _buildPrizeCard(
                  'รางวัลที่ 2',
                  '423147',
                  'win 300,000 ฿',
                  const Color(0xFFFF6600),
                  height: 120,
                  numberFontSize: 17.25,
                  titleFontSize: 12,
                  amountFontSize: 11,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPrizeCard(
                  'รางวัลที่ 3',
                  '743555',
                  'win 100,000 ฿',
                  const Color(0xFFC2761A),
                  height: 120,
                  numberFontSize: 17.25,
                  titleFontSize: 12,
                  amountFontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // รางวัลที่ 4 และ 5
          Row(
            children: [
              Expanded(
                child: _buildPrizeCard(
                  'รางวัลที่ 4',
                  '167538',
                  'win 20,000 ฿',
                  const Color(0xFF228B22),
                  height: 120,
                  numberFontSize: 17.25,
                  titleFontSize: 12,
                  amountFontSize: 11,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPrizeCard(
                  'รางวัลที่ 5',
                  '247223',
                  'win 5,000 ฿',
                  const Color(0xFF6C9C1F),
                  height: 120,
                  numberFontSize: 17.25,
                  titleFontSize: 12,
                  amountFontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPrizeCard(
    String title,
    String number,
    String amount,
    Color color, {
    double height = 100,
    double numberFontSize = 20,
    double titleFontSize = 16,
    double amountFontSize = 14,
  }) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: GoogleFonts.inter(
                color: const Color.fromARGB(255, 245, 223, 137),
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              number,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontSize: numberFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              amount,
              style: GoogleFonts.inter(
                color: const Color.fromARGB(255, 245, 223, 137),
                fontSize: amountFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
