// lib/pages/check_page.dart

import 'package:app_oracel999/model/response/cash_in_request.dart';
import 'package:app_oracel999/model/response/check_response.dart';
import 'package:app_oracel999/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

// --- Imports ที่สะอาดและเป็นระเบียบ ---
import '../api/api_service.dart';
import 'navmenu.dart';

class LotteryCheckerPage extends StatefulWidget {
  final String userId;
  final String username;

  const LotteryCheckerPage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<LotteryCheckerPage> createState() => _LotteryCheckerPageState();
}

class _LotteryCheckerPageState extends State<LotteryCheckerPage> {
  final _apiService = ApiService();
  final _numberController = TextEditingController();
  late Future<List<CurrentReward>> _rewardsFuture;

  @override
  void initState() {
    super.initState();
    _fetchLatestRewards();
  }

  void _fetchLatestRewards() {
    setState(() {
      _rewardsFuture = _apiService.fetchLatestRewards();
    });
  }

  Future<void> _checkMyNumber() async {
    final number = _numberController.text.trim();
    if (number.length != 6) {
      _showSnackbar('กรุณากรอกหมายเลข 6 หลักให้ถูกต้อง', isError: true);
      return;
    }

    FocusScope.of(context).unfocus();
    showDialog(
      context: context,
      builder: (_) => const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final result = await _apiService.checkLottoNumber(number);
      if (mounted) {
        Navigator.pop(context); // ปิด loading dialog
        _showResultDialog(result);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // ปิด loading dialog
        _showSnackbar(e.toString(), isError: true);
      }
    }
  }

  // --- ฟังก์ชันสำหรับขึ้นเงินรางวัล  ---
  Future<void> _cashInPrize(CheckResult result) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final request = CashInRequest(
        userId: int.parse(widget.userId),
        lottoNumber: result.lottoNumber,
      );
      await _apiService.cashInPrize(request);

      if (mounted) {
        Navigator.pop(context); // ปิด loading
        Navigator.pop(context); // ปิด dialog ผลรางวัล
        _showSnackbar('ขึ้นเงินรางวัลสำเร็จ!', isError: false);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) => HomeScreen(
                  username: widget.username,
                  userId: widget.userId,
                ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // ปิด loading
        _showSnackbar(e.toString(), isError: true);
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.replaceFirst('Exception: ', '')),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: const Color(0xFFAD0101),
          elevation: 0,
          toolbarHeight: 100.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed:
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => HomeScreen(
                          username: widget.username,
                          userId: widget.userId,
                        ),
                  ),
                ),
          ),
          title: Text(
            'ตรวจรางวัล',
            style: GoogleFonts.itim(color: Colors.white, fontSize: 36),
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
          ),
        ),
       body: FutureBuilder<List<CurrentReward>>(
          future: _rewardsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    "เกิดข้อผิดพลาด:\n${snapshot.error.toString().replaceFirst('Exception: ', '')}",
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.yellow, fontSize: 16),
                  ),
                ),
              );
            }
            if (snapshot.hasData) {
              final latestRewards = snapshot.data!;
              return RefreshIndicator(
                onRefresh: () async => _fetchLatestRewards(),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    children: [
                      _buildSearchBar(),
                      const SizedBox(height: 20),
                      _buildPrizeSection(latestRewards),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              );
            }
            return const Center(
              child: Text(
                'ไม่พบข้อมูลรางวัล',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
        bottomNavigationBar: MyBottomNavigationBar(
          username: widget.username,
          userId: widget.userId,
        ),
      ),
    );
  }

  // --- โค้ดส่วน UI ที่เหลือ (Widgets) ---

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFFDD835),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0D47A1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              'ตรวจผลสลากของคุณ',
              style: GoogleFonts.itim(color: Colors.white, fontSize: 24),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(
                  fontSize: 24,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 10,
                ),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'X X X X X X',
                  hintStyle: GoogleFonts.inter(
                    color: Colors.grey[400],
                    letterSpacing: 10,
                  ),
                  counterText: "",
                  prefixIcon: const Icon(Icons.search),
                ),
                maxLength: 6,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkMyNumber,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2B2E4A),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                minimumSize: const Size(200, 45),
              ),
              child: Text(
                'ตรวจรางวัล',
                style: GoogleFonts.itim(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeSection(List<CurrentReward> rewards) {
  final formatter = NumberFormat("#,###");

  String getNumber(int tier) =>
      rewards.firstWhere((r) => r.prizeTier == tier,
          orElse: () => CurrentReward(prizeTier: tier, prizeMoney: 0, lottoNumber: 'ยังไม่ได้ประกาศ')).lottoNumber;

  double getMoney(int tier) =>
      rewards.firstWhere((r) => r.prizeTier == tier,
          orElse: () => CurrentReward(prizeTier: tier, prizeMoney: 0, lottoNumber: '')).prizeMoney;

  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      children: [
        _buildPrizeCard(
          'รางวัลที่ 1',
          getNumber(1),
          getMoney(1) > 0 ? "Jackpot ${formatter.format(getMoney(1))} ฿" : "Jackpot -",
          const Color(0xFFC62828),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmallPrizeCard(
                'รางวัลที่ 2',
                getNumber(2),
                getMoney(2) > 0 ? "รับ ${formatter.format(getMoney(2))} ฿" : "ยังไม่ประกาศ",
                const Color(0xFFD84315),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSmallPrizeCard(
                'รางวัลที่ 3',
                getNumber(3),
                getMoney(3) > 0 ? "รับ ${formatter.format(getMoney(3))} ฿" : "ยังไม่ประกาศ",
                const Color(0xFFEF6C00),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildSmallPrizeCard(
                'เลขท้าย 3 ตัว',
                getNumber(4),
                getMoney(4) > 0 ? "รับ ${formatter.format(getMoney(4))} ฿" : "ยังไม่ประกาศ",
                const Color(0xFF2E7D32),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildSmallPrizeCard(
                'เลขท้าย 2 ตัว',
                getNumber(5),
                getMoney(5) > 0 ? "รับ ${formatter.format(getMoney(5))} ฿" : "ยังไม่ประกาศ",
                const Color(0xFF558B2F),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}


  void _showResultDialog(CheckResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            backgroundColor: Colors.transparent,
            contentPadding: EdgeInsets.zero,
            content: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: const Color(0xFFB71C1C),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (result.isWinner)
                    _buildWinnerContent(result)
                  else
                    _buildLoserContent(result),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            result.isWinner
                                ? const Color(0xFF69F0AE)
                                : const Color(0xFFFDD835),
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () {
                        if (result.isWinner) {
                          // ถ้าเป็นผู้ชนะ ให้เรียกฟังก์ชันขึ้นเงิน
                          _cashInPrize(result);
                        } else {
                          // ถ้าไม่ใช่ ก็แค่ปิด dialog
                          Navigator.pop(context);
                        }
                      },
                      child: Text(
                        result.isWinner ? 'ขึ้นเงินรางวัล' : 'ยืนยัน',
                        style: GoogleFonts.itim(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildWinnerContent(CheckResult result) {
    final formatter = NumberFormat("#,###");
    return Column(
      children: [
        Image.asset('assets/image/Cool.png', height: 60),
        const SizedBox(height: 16),
        Text(
          'ยินดีด้วย\n${result.message}',
          textAlign: TextAlign.center,
          style: GoogleFonts.itim(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          result.lottoNumber.split('').join(' '),
          style: GoogleFonts.inter(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          '+${formatter.format(result.prizeMoney)}',
          style: GoogleFonts.itim(fontSize: 22, color: Colors.yellow[600]),
        ),
      ],
    );
  }

  Widget _buildLoserContent(CheckResult result) {
    return Column(
      children: [
        Image.asset('assets/image/Sad.png', height: 60),
        const SizedBox(height: 16),
        Text(
          result.message,
          textAlign: TextAlign.center,
          style: GoogleFonts.itim(
            fontSize: 18,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ครั้งหน้ายังมีโอกาส\nกรุณาซื้อต่อไปเรื่อยๆ',
          textAlign: TextAlign.center,
          style: GoogleFonts.itim(fontSize: 14, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildPrizeCard(
    String title,
    String number,
    String amount,
    Color color,
  ) {
    final isFallback = number.contains('ยังไม่ได้ประกาศ');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.itim(
              color: Colors.yellow[600],
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            number,
            style:
                isFallback
                    ? GoogleFonts.itim(color: Colors.white, fontSize: 18)
                    : GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
            textAlign: TextAlign.center,
          ),
          Text(
            amount,
            style: GoogleFonts.itim(color: Colors.white70, fontSize: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallPrizeCard(
    String title,
    String number,
    String amount,
    Color color,
  ) {
    final isFallback = number.contains('ยังไม่ได้ประกาศ');
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.itim(
              color: Colors.yellow[600],
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            number,
            style:
                isFallback
                    ? GoogleFonts.itim(color: Colors.white, fontSize: 18)
                    : GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
            textAlign: TextAlign.center,
          ),
          Text(
            amount,
            style: GoogleFonts.itim(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
