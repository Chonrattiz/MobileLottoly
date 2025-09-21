import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../api/api_service.dart';
import 'package:app_oracel999/model/response/check_response.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  late Future<List<CurrentReward>> _rewardsFuture; // ✅ เปลี่ยน type
  final _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _rewardsFuture = _apiService.fetchLatestRewards(); // ✅ ใช้ CurrentReward
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
              _buildActionButtons(),
              Expanded(
                child: FutureBuilder<List<CurrentReward>>( // ✅ ใช้ CurrentReward
                  future: _rewardsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'เกิดข้อผิดพลาด: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }
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

                    final rewards = snapshot.data!;
                    return SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildPrizeSection(rewards),
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

  Widget _buildPrizeSection(List<CurrentReward> rewards) {
    final prize1 = rewards.firstWhere(
      (r) => r.prizeTier == 1,
      orElse: () =>
          CurrentReward(prizeTier: 1, prizeMoney: 0, lottoNumber: '??????'),
    );
    final prize2 = rewards.firstWhere(
      (r) => r.prizeTier == 2,
      orElse: () =>
          CurrentReward(prizeTier: 2, prizeMoney: 0, lottoNumber: '??????'),
    );
    final prize3 = rewards.firstWhere(
      (r) => r.prizeTier == 3,
      orElse: () =>
          CurrentReward(prizeTier: 3, prizeMoney: 0, lottoNumber: '??????'),
    );
    final prize5 = rewards.firstWhere(
      (r) => r.prizeTier == 5,
      orElse: () =>
          CurrentReward(prizeTier: 5, prizeMoney: 0, lottoNumber: '??????'),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _buildPrizeCard(
            'รางวัลที่ ${prize1.prizeTier}',
            prize1.lottoNumber,
            'Jackpot ${prize1.prizeMoney.toStringAsFixed(0)} ฿',
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
