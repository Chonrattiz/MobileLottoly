import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http; // 🎯 1. Import http package
import 'dart:convert'; // 🎯 สำหรับ jsonDecode

// 🎯 2. สร้าง Model Class เพื่อรับข้อมูลจาก API
class RewardData {
  final int prizeTier;
  final String lottoNumber;
  final double prizeMoney;

  RewardData({
    required this.prizeTier,
    required this.lottoNumber,
    required this.prizeMoney,
  });

  // Factory constructor สำหรับแปลง JSON เป็น Object
  factory RewardData.fromJson(Map<String, dynamic> json) {
    return RewardData(
      prizeTier: json['prize_tier'],
      lottoNumber: json['lotto_number'],
      prizeMoney: (json['prize_money'] as num).toDouble(),
    );
  }
}

// 🎯 3. เปลี่ยนเป็น StatefulWidget
class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  // 🎯 4. สร้าง State variables สำหรับจัดการสถานะ
  late Future<List<RewardData>> _rewardsFuture;

  @override
  void initState() {
    super.initState();
    // 🎯 5. เรียกฟังก์ชัน fetch ข้อมูลเมื่อหน้าถูกสร้าง
    _rewardsFuture = _fetchRewards();
  }

  // 🎯 6. สร้างฟังก์ชันสำหรับเรียก API
  Future<List<RewardData>> _fetchRewards() async {
    // --- เลือกใช้ URL ให้ถูกกับสถานการณ์ ---

    // ✅ 1. แก้ไข endpoint จาก 'currsent' เป็น 'current'

    // ✅ 2. เปลี่ยน 'localhost' เป็น IP Address ที่ถูกต้อง

    // ‼️ หากทดสอบบน Android Emulator, ให้ใช้ IP นี้
    final url = Uri.parse('https://api-oracel999.onrender.com/rewards/currsent');

    // ‼️ หากทดสอบบนโทรศัพท์จริง, ให้ใช้ IP ของคอมพิวเตอร์ในวง Wi-Fi
    // final url = Uri.parse('http://192.168.1.100:8080/rewards/current'); // << ใส่ IP จริงของคุณ

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final List<dynamic> data = body['data'];

        return data.map((json) => RewardData.fromJson(json)).toList();
      } else {
        // ทำให้ Error message บอก Status Code ด้วย จะได้ debug ง่ายขึ้น
        throw Exception(
          'Failed to load rewards: Server responded with status code ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Failed to load rewards: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: const Color(0xFFE4222C),
        elevation: 0,
        toolbarHeight: 120.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: Text(
          'ประกาศรางวัล',
          style: GoogleFonts.itim(color: Colors.white, fontSize: 36),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SizedBox(
            height: double.infinity,
            width: double.infinity,
            child: Image.asset('assets/image/bg3.png', fit: BoxFit.cover),
          ),
          Column(
            children: [
              _buildActionButtons(), // ปุ่มยังคงอยู่เหมือนเดิม
              Expanded(
                // 🎯 7. ใช้ FutureBuilder เพื่อจัดการสถานะการโหลดข้อมูล
                child: FutureBuilder<List<RewardData>>(
                  future: _rewardsFuture,
                  builder: (context, snapshot) {
                    // กรณี: กำลังโหลดข้อมูล
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    // กรณี: เกิด Error
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'เกิดข้อผิดพลาด: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    // กรณี: ไม่มีข้อมูล หรือข้อมูลเป็น array ว่าง
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(
                        child: Text(
                          'ยังไม่มีการประกาศรางวัล',
                          style: GoogleFonts.itim(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      );
                    }

                    // กรณี: โหลดข้อมูลสำเร็จ
                    final rewards = snapshot.data!;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildPrizeSection(
                        rewards,
                      ), // ส่งข้อมูลที่ได้ไปแสดงผล
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget _buildActionButtons() { ... โค้ดเดิม ... }
  // Widget _buildGoldBorderButton(String text) { ... โค้ดเดิม ... }

  // 🎯 8. ปรับปรุง `_buildPrizeSection` ให้รับข้อมูล rewards
  Widget _buildPrizeSection(List<RewardData> rewards) {
    // หาข้อมูลรางวัลแต่ละอันจาก list
    // ใช้ .firstWhere หรือ loop ตามความเหมาะสม ในที่นี้ใช้ firstWhere เพื่อความง่าย
    final prize1 = rewards.firstWhere(
      (r) => r.prizeTier == 1,
      orElse: () =>
          RewardData(prizeTier: 1, lottoNumber: '??????', prizeMoney: 0),
    );
    final prize2 = rewards.firstWhere(
      (r) => r.prizeTier == 2,
      orElse: () =>
          RewardData(prizeTier: 2, lottoNumber: '??????', prizeMoney: 0),
    );
    final prize3 = rewards.firstWhere(
      (r) => r.prizeTier == 3,
      orElse: () =>
          RewardData(prizeTier: 3, lottoNumber: '??????', prizeMoney: 0),
    );
    final prize5 = rewards.firstWhere(
      (r) => r.prizeTier == 5,
      orElse: () =>
          RewardData(prizeTier: 5, lottoNumber: '??????', prizeMoney: 0),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _buildPrizeCard(
            'รางวัลที่ ${prize1.prizeTier}',
            prize1.lottoNumber,
            'Jackpot ${prize1.prizeMoney.toStringAsFixed(0)} ฿', // Format เงิน
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
                  'รางวัลที่ ${prize2.prizeTier}',
                  prize2.lottoNumber,
                  'win ${prize2.prizeMoney.toStringAsFixed(0)} ฿',
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
                  'รางวัลที่ ${prize3.prizeTier}',
                  prize3.lottoNumber,
                  'win ${prize3.prizeMoney.toStringAsFixed(0)} ฿',
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
          // ตัวอย่างรางวัลที่ 5
          _buildPrizeCard(
            'รางวัลที่ ${prize5.prizeTier}',
            prize5.lottoNumber,
            'win ${prize5.prizeMoney.toStringAsFixed(0)} ฿',
            const Color(0xFF6C9C1F),
            height: 120,
            numberFontSize: 24,
            titleFontSize: 16,
            amountFontSize: 14,
          ),
        ],
      ),
    );
  }

  // ไม่ต้องแก้ไข Widget _buildPrizeCard และ _buildGoldBorderButton
  // ... โค้ด Widget 2 อันนี้เหมือนเดิม ...
  Widget _buildActionButtons() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(child: _buildGoldBorderButton('สุ่มเลขรางวัล')),
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
        color: color.withOpacity(0.8),
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
}
