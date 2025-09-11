import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:app_oracel999/pages/home.dart';
import 'package:app_oracel999/pages/navmenu.dart';

// --- Models สำหรับรับข้อมูลจาก API ---
class LatestRewards {
  final List<String> prize1;
  final List<String> prize2;
  final List<String> prize3;
  final String last3;
  final String last2;

  LatestRewards({
    this.prize1 = const [], this.prize2 = const [], this.prize3 = const [],
    this.last3 = "------", this.last2 = "--",
  });

  factory LatestRewards.fromJson(Map<String, dynamic> json) {
    return LatestRewards(
      prize1: List<String>.from(json['prize_1'] ?? []),
      prize2: List<String>.from(json['prize_2'] ?? []),
      prize3: List<String>.from(json['prize_3'] ?? []),
      last3: json['last_3'] ?? "---",
      last2: json['last_2'] ?? "--",
    );
  }
}

class CheckResult {
  final bool isWinner;
  final String message;
  final String lottoNumber;
  final double prizeMoney;
  final int prizeTier;

  CheckResult({
    required this.isWinner, required this.message, required this.lottoNumber,
    required this.prizeMoney, required this.prizeTier,
  });

 factory CheckResult.fromJson(Map<String, dynamic> json) {
    return CheckResult(
      isWinner: json['is_winner'] ?? false,
      message: json['message'] ?? 'เกิดข้อผิดพลาด',
      lottoNumber: json['lotto_number'] ?? '',
      prizeMoney: (json['prize_money'] as num?)?.toDouble() ?? 0.0,
      prizeTier: json['prize_tier'] ?? 0,
    );
  }
}

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
  final TextEditingController _numberController = TextEditingController();
  LatestRewards? _latestRewards;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchLatestRewards();
  }

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _fetchLatestRewards() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final url = Uri.parse('http://192.168.6.1:8080/rewards/latest');
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        _latestRewards = LatestRewards.fromJson(jsonDecode(response.body)['data']);
      } else {
        throw Exception('ไม่สามารถโหลดผลรางวัลได้ (รหัส: ${response.statusCode})');
      }
    } catch(e) {
      _errorMessage = e.toString();
    } finally {
      if(mounted) { setState(() { _isLoading = false; }); }
    }
  }

  Future<void> _checkMyNumber() async {
     final number = _numberController.text.trim();
     if (number.length != 6) {
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('กรุณากรอกหมายเลข 6 หลักให้ถูกต้อง')),
       );
       return;
     }

     FocusScope.of(context).unfocus();
     showDialog(context: context, builder: (_) => const Center(child: CircularProgressIndicator()), barrierDismissible: false);
     final navigator = Navigator.of(context);

     try {
       final url = Uri.parse('http://192.168.6.1:8080/rewards/check?number=$number');
       final response = await http.get(url).timeout(const Duration(seconds: 10));
       
       navigator.pop();

       if (response.statusCode == 200) {
         final result = CheckResult.fromJson(jsonDecode(response.body)['data']);
         _showResultDialog(result);
       } else {
         throw Exception('ไม่สามารถตรวจรางวัลได้ (รหัส: ${response.statusCode})');
       }
     } catch (e) {
        if(mounted) navigator.pop();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('เกิดข้อผิดพลาด: ${e.toString()}')));
     }
  }
  
  void _showResultDialog(CheckResult result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
                    backgroundColor: result.isWinner ? const Color(0xFF69F0AE) : const Color(0xFFFDD835),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    result.isWinner ? 'ขึ้นเงินรางวัล' : 'ยืนยัน',
                    style: GoogleFonts.itim(fontSize: 18, fontWeight: FontWeight.bold),
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
        Image.asset('assets/image/Cool.png', height: 60), // สมมติว่ามีรูปถ้วยรางวัล
        const SizedBox(height: 16),
        Text(
          'ยินดีด้วย\n${result.message}',
          textAlign: TextAlign.center,
          style: GoogleFonts.itim(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          result.lottoNumber.split('').join(' '),
          style: GoogleFonts.inter(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
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
        Image.asset('assets/image/Sad.png', height: 60), // สมมติว่ามีรูปหน้าเศร้า
        const SizedBox(height: 16),
        Text(
          result.message,
          textAlign: TextAlign.center,
          style: GoogleFonts.itim(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(image: DecorationImage(image: AssetImage('assets/image/bg4.png'), fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: const Color(0xFFAD0101),
          elevation: 0,
          toolbarHeight: 100.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(username: widget.username, userId: widget.userId)),
              );
            },
          ),
          title: Text('ตรวจรางวัล', style: GoogleFonts.itim(color: Colors.white, fontSize: 36)),
          centerTitle: true,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(30))),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _errorMessage != null
                ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.yellow)))
                : RefreshIndicator(
                  onRefresh: _fetchLatestRewards,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          _buildSearchBar(),
                          const SizedBox(height: 20),
                          _buildPrizeSection(),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                ),
        bottomNavigationBar: MyBottomNavigationBar(username: widget.username, userId: widget.userId),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: const Color(0xFFFDD835), borderRadius: BorderRadius.circular(15)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFF0D47A1), borderRadius: BorderRadius.circular(12)),
        child: Column(
          children: [
            Text('ตรวจผลสลากของคุณ', style: GoogleFonts.itim(color: Colors.white, fontSize: 24)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: TextField(
                controller: _numberController,
                keyboardType: TextInputType.number,
                style: GoogleFonts.inter(fontSize: 24, color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 10),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  border: InputBorder.none, hintText: 'X X X X X X', 
                  hintStyle: GoogleFonts.inter(color: Colors.grey[400], letterSpacing: 10),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                minimumSize: const Size(200, 45),
              ),
              child: Text('ตรวจรางวัล', style: GoogleFonts.itim(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildPrizeCard('รางวัลที่ 1', _latestRewards?.prize1.first ?? "------", 'Jackpot 6,000,000 ฿', const Color(0xFFC62828)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSmallPrizeCard('รางวัลที่ 2', _latestRewards?.prize2.first ?? "------", 'win 200,000 ฿', const Color(0xFFD84315))),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallPrizeCard('รางวัลที่ 3', _latestRewards?.prize3.first ?? "------", 'win 80,000 ฿', const Color(0xFFEF6C00))),
            ],
          ),
          const SizedBox(height: 16),
           Row(
            children: [
              Expanded(child: _buildSmallPrizeCard('เลขท้าย 3 ตัว', _latestRewards?.last3 ?? "---", 'win 4,000 ฿', const Color(0xFF2E7D32))),
              const SizedBox(width: 16),
              Expanded(child: _buildSmallPrizeCard('เลขท้าย 2 ตัว', _latestRewards?.last2 ?? "--", 'win 2,000 ฿', const Color(0xFF558B2F))),
            ],
          ),
        ],
      ),
    );
  }
  
   Widget _buildPrizeCard(String title, String number, String amount, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.itim(color: Colors.yellow[600], fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(number, style: GoogleFonts.inter(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, letterSpacing: 2)),
          Text(amount, style: GoogleFonts.itim(color: Colors.white70, fontSize: 18)),
        ],
      ),
    );
  }

   Widget _buildSmallPrizeCard(String title, String number, String amount, Color color) {
    return Container(
       padding: const EdgeInsets.symmetric(vertical: 12),
       decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
      ),
      child: Column(
        children: [
          Text(title, style: GoogleFonts.itim(color: Colors.yellow[600], fontSize: 14, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(number, style: GoogleFonts.inter(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: 1)),
          Text(amount, style: GoogleFonts.itim(color: Colors.white70, fontSize: 12)),
        ],
      ),
    );
  }
}

