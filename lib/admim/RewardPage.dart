import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../service/lotto_service.dart';
import '../model/response/reward_data.dart';

class RewardPage extends StatefulWidget {
  const RewardPage({super.key});

  @override
  State<RewardPage> createState() => _RewardPageState();
}

class _RewardPageState extends State<RewardPage> {
  late Future<List<RewardData>> _rewardsFuture;
  Map<int, double> _customPrizes = {};
  List<RewardData>? _previewRewards;
  bool _isPreviewLoading = false;
  bool _isReleasing = false;

  @override
  void initState() {
    super.initState();
    _rewardsFuture = LottoService.fetchCurrentRewards();
  }

  // ----------------------
  // ฟังก์ชันสุ่มรางวัล
  // ----------------------
  Future<void> _generatePreview() async {
    if (_isPreviewLoading) return;
    setState(() => _isPreviewLoading = true);
    try {
      final newRewards = await LottoService.generatePreview();
      setState(() => _previewRewards = newRewards);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isPreviewLoading = false);
    }
  }

  // ----------------------
  // ฟังก์ชันปล่อยรางวัล
  // ----------------------
  Future<void> _releaseRewards() async {
    if (_previewRewards == null || _previewRewards!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาสุ่มเลขรางวัลก่อนทำการปล่อยรางวัล'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('ยืนยันการปล่อยรางวัล'),
            content: Text(
              'คุณแน่ใจหรือไม่ที่จะปล่อยรางวัลชุดนี้? ข้อมูลรางวัลเก่าจะถูกลบทั้งหมด',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('ยืนยัน'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => _isReleasing = true);
    try {
      final message = await LottoService.releaseRewards(
        _previewRewards!,
        customPrizes: _customPrizes.isNotEmpty ? _customPrizes : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
      setState(() {
        _previewRewards = null;
        _rewardsFuture = LottoService.fetchCurrentRewards();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isReleasing = false);
    }
  }

  // ----------------------
  // ฟังก์ชันตั้งค่าเงินรางวัล
  // ----------------------
  void _showSetPrizesDialog(List<RewardData> currentRewards) {
    final controllers = {
      for (var reward in currentRewards)
        reward.prizeTier: TextEditingController(
          text: (_customPrizes[reward.prizeTier] ?? reward.prizeMoney)
              .toStringAsFixed(0),
        ),
    };

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('ตั้งค่าเงินรางวัล'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    currentRewards.map((reward) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: TextField(
                          controller: controllers[reward.prizeTier],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'รางวัลที่ ${reward.prizeTier}',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('ยกเลิก'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    controllers.forEach((tier, controller) {
                      final value = double.tryParse(controller.text);
                      if (value != null) _customPrizes[tier] = value;
                    });
                  });
                  Navigator.of(context).pop();
                },
                child: Text('บันทึก'),
              ),
            ],
          ),
    );
  }

  // ----------------------
  // UI Build
  // ----------------------
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
          onPressed: () => Navigator.of(context).pop(),
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
            child: Image.asset('assets/image/bb.png', fit: BoxFit.cover),
          ),
          FutureBuilder<List<RewardData>>(
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

              final displayData = _previewRewards ?? snapshot.data ?? [];

              if (displayData.isEmpty) {
                return Column(
                  children: [
                    _buildActionButtons([]),
                    Expanded(
                      child: Center(
                        child: Text(
                          'ยังไม่มีการประกาศรางวัล',
                          style: GoogleFonts.itim(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _buildActionButtons(displayData),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildPrizeSection(displayData),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  // ----------------------
  // ปุ่มด้านบน
  // ----------------------
  Widget _buildActionButtons(List<RewardData> rewards) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: _buildGoldBorderButton(
                  _isPreviewLoading ? 'กำลังสุ่ม...' : 'สุ่มเลขรางวัล',
                  _isPreviewLoading ? null : _generatePreview,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGoldBorderButton(
                  'ตั้งค่าเงินรางวัล',
                  rewards.isNotEmpty
                      ? () => _showSetPrizesDialog(rewards)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildGoldBorderButton(
            _isReleasing ? 'กำลังปล่อยรางวัล...' : 'ปล่อยรางวัลงวดใหม่',
            _isReleasing || _previewRewards == null ? null : _releaseRewards,
          ),
        ],
      ),
    );
  }

  Widget _buildGoldBorderButton(String text, void Function()? onPressed) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFFFD700), width: 3),
        borderRadius: BorderRadius.circular(25),
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF90191B),
          disabledBackgroundColor: Colors.grey.shade700,
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

  // ----------------------
  // แสดงรางวัล
  // ----------------------
  Widget _buildPrizeSection(List<RewardData> rewards) {
    double getPrizeMoney(int tier, double defaultMoney) =>
        _customPrizes[tier] ?? defaultMoney;

    RewardData getReward(int tier, String defaultNumber) {
      return rewards.firstWhere(
        (r) => r.prizeTier == tier,
        orElse:
            () => RewardData(
              prizeTier: tier,
              lottoNumber: defaultNumber,
              prizeMoney: 0,
            ),
      );
    }

    final prize1 = getReward(1, '??????');
    final prize2 = getReward(2, '??????');
    final prize3 = getReward(3, '??????');
    final prize4 = getReward(4, '??????');
    final prize5 = getReward(5, '??????');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          _buildPrizeCard(
            'รางวัลที่ ${prize1.prizeTier}',
            prize1.lottoNumber,
            'Jackpot ${getPrizeMoney(1, prize1.prizeMoney).toStringAsFixed(0)} ฿',
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
                  'win ${getPrizeMoney(2, prize2.prizeMoney).toStringAsFixed(0)} ฿',
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
                  'win ${getPrizeMoney(3, prize3.prizeMoney).toStringAsFixed(0)} ฿',
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
                  'รางวัลเลขท้าย 3 ตัว',
                  prize4.lottoNumber.length >= 3
                      ? prize4.lottoNumber.substring(
                        prize4.lottoNumber.length - 3,
                      )
                      : prize4.lottoNumber,
                  'win ${getPrizeMoney(4, prize4.prizeMoney).toStringAsFixed(0)} ฿',
                  const Color.fromARGB(255, 49, 48, 34),
                  height: 120,
                  numberFontSize: 17.25,
                  titleFontSize: 12,
                  amountFontSize: 11,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildPrizeCard(
                  'รางวัลเลขท้าย 2 ตัว',
                  prize5.lottoNumber.length >= 2
                      ? prize5.lottoNumber.substring(
                        prize5.lottoNumber.length - 2,
                      )
                      : prize5.lottoNumber,
                  'win ${getPrizeMoney(5, prize5.prizeMoney).toStringAsFixed(0)} ฿',
                  const Color.fromARGB(255, 49, 48, 34),
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
