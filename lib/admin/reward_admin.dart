import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: LotteryPrizePage());
  }
}

class LotteryPrizePage extends StatelessWidget {
  const LotteryPrizePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(
        0,
        255,
        0,
        0,
      ), // ทำให้ Scaffold โปร่งใสเพื่อแสดงภาพพื้นหลัง
      appBar: AppBar(
        backgroundColor: const Color(0xFFE4222C),
        elevation: 0,
        toolbarHeight: 120.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // Navigator.of(context).pop();
          },
        ),
        title: Text(
          'ประกาศรางวัล',
          style: GoogleFonts.itim(color: Colors.white, fontSize: 36),
        ),
        centerTitle: true,
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.only(
        //     bottomLeft: Radius.circular(20),
        //     bottomRight: Radius.circular(20),
        //   ),
        // ),
      ),
      body: Stack(
        children: [
          // ส่วนที่ 1: รูปภาพพื้นหลัง
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset(
              'assets/image/bg3.png', // 🖼️ โปรดเปลี่ยนเส้นทางนี้เป็นที่อยู่ของไฟล์รูปภาพของคุณ
              fit: BoxFit.cover, // ทำให้รูปภาพครอบคลุมพื้นที่ทั้งหมด
            ),
          ),
          // ส่วนที่ 2: เนื้อหาเดิมของคุณที่ซ้อนทับอยู่ด้านบน
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildActionButtons(),
                      _buildPrizeSection(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              _buildBottomButtons(),
            ],
          ),
        ],
      ),
    );
  }

  // 🔶 ปุ่มด้านบนทั้งหมดมีขอบทอง
  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildGoldBorderButton('รีเซตรางวัล')),
              const SizedBox(width: 12),
              Expanded(child: _buildGoldBorderButton('ตั้งค่าเงินรางวัล')),
            ],
          ),
          const SizedBox(height: 12),
          _buildGoldBorderButton('ปล่อยรางวัลงวดใหม่'),
        ],
      ),
    );
  }

  // 🟨 ปุ่มมีขอบสีทอง
  Widget _buildGoldBorderButton(String text) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFD700), width: 3), // ขอบทอง
        borderRadius: BorderRadius.circular(25),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF90191B),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.inter(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildPrizeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _buildPrizeCard(
            'รางวัลที่ 1',
            '844322',
            'Jackpot 999,999 ฿',
            const Color(0xFFAD0101),
            height: 120,
            numberFontSize: 36,
            titleFontSize: 20,
            amountFontSize: 20,
          ),
          const SizedBox(height: 16),
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
          Row(
            children: [
              Expanded(
                child: _buildPrizeCard(
                  'รางวัลที่ 4 \nเลขท้าย 3 ตัว',
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
                  'รางวัลที่ 5\n เลขท้าย 2 ตัว',
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
        color: color.withOpacity(0.8), // ลดความทึบของสีเพื่อให้มองเห็นพื้นหลัง
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFFFD700), width: 1),
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
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: const Color.fromARGB(255, 245, 223, 137),
                fontSize: titleFontSize,
                // fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
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

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.only(
        top: 16.0,
        bottom: 24.0,
        left: 16.0,
        right: 16.0,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFFAD0101),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.black, // สีดำ
                radius: 30, // ขนาดของวงกลม
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(
                    Icons.sync_alt,
                    color: Color.fromARGB(255, 245, 223, 137),
                  ),
                  onPressed: () {},
                ),
              ),
              Text(
                'สุ่มLottoชุดใหม่',
                style: GoogleFonts.itim(
                  color: const Color.fromARGB(255, 245, 223, 137),
                  fontSize: 14,
                ),
              ),
            ],
          ),
          Column(
            children: [
              CircleAvatar(
                backgroundColor: Colors.black, // สีดำ
                radius: 30, // ขนาดของวงกลม
                child: IconButton(
                  iconSize: 30,
                  icon: const Icon(
                    Icons.confirmation_num,
                    color: Color.fromARGB(255, 245, 223, 137),
                  ),
                  onPressed: () {},
                ),
              ),
              Text(
                'ประกาศรางวัล',
                style: GoogleFonts.inter(
                  color: const Color.fromARGB(255, 245, 223, 137),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
