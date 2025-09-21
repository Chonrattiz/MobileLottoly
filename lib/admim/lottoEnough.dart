import 'package:app_oracel999/admim/RewardPage.dart';
import 'package:app_oracel999/model/response/lotto_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app_oracel999/admim/newlotto.dart';
import 'package:app_oracel999/service/lotto_service.dart';

class lottoenough extends StatelessWidget {
  const lottoenough({super.key});

  @override
  Widget build(BuildContext context) {
    const redHeader = Color(0xFFAD0101);
    const goldBorder = Color(0xFFE3BB66);
    const numberRed = Color(0xFFD10400);

    // ✅ รับ lottoId แทน index
    Widget lottoSetCard({required int lottoId, required List<int> digits}) {
      return Container(
        width: 373,
        height: 82,
        decoration: BoxDecoration(
          color: redHeader,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: goldBorder, width: 8),
          boxShadow: const [
            BoxShadow(
              blurRadius: 6,
              offset: Offset(0, 2),
              color: Colors.black26,
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 12,
              top: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: redHeader,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  // ✅ แสดงเป็น lotto_id จริง
                  'ชุดที่ $lottoId',
                  style: GoogleFonts.itim(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 25),
              child: Container(
                height: 35,
                margin: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children:
                      digits
                          .map(
                            (d) => Text(
                              '$d',
                              style: GoogleFonts.itim(
                                color: numberRed,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          )
                          .toList(),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'ลอตโต้ที่เหลือ',
          style: GoogleFonts.itim(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFD10400),
        elevation: 0,
        toolbarHeight: 70, // ✅ ลดความสูงให้พอดี
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/bg3.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 180, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // 🔥 ดึงจริงจาก API
                FutureBuilder<List<LottoItem>>(
                  future: LottoService.fetchAllAsc(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 40.0),
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snap.hasError) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          'เกิดข้อผิดพลาด: ${snap.error}',
                          style: GoogleFonts.itim(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    final all = snap.data ?? [];
                    // ✅ แสดงเฉพาะสถานะ sell (ทนช่องว่าง/ตัวพิมพ์)
                    final items =
                        all
                            .where(
                              (e) => e.status.trim().toLowerCase() == 'sell',
                            )
                            .toList();

                    if (items.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 40.0),
                        child: Text(
                          'ไม่พบลอตเตอรี่สถานะ sell',
                          style: GoogleFonts.itim(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      );
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final double cardW =
                            constraints.maxWidth >= 373
                                ? 373
                                : constraints.maxWidth;
                        return Column(
                          // ✅ map จาก item จริง เพื่อเข้าถึง lottoId และ digits
                          children:
                              items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: SizedBox(
                                    width: cardW,
                                    child: lottoSetCard(
                                      lottoId: item.lottoId,
                                      digits: item.digits,
                                    ),
                                  ),
                                );
                              }).toList(),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const _BottomActionBar(),
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar({this.onOpenNew, this.onOpenReward});
  final Future<void> Function()? onOpenNew;
  final Future<void> Function()? onOpenReward;

  @override
  Widget build(BuildContext context) {
    const barColor = Color(0xFFD10400);
    return BottomAppBar(
      color: barColor,
      elevation: 8,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        child: Row(
          children: [
            Expanded(
              child: _NavButton(
                icon: Icons.shuffle,
                label: 'สุ่มLottoชุดใหม่',
                onTap: onOpenNew,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _NavButton(
                icon: Icons.confirmation_number,
                label: 'ประกาศรางวัล',
                onTap: onOpenReward,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.label, this.onTap});
  final IconData icon;
  final String label;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    const gold1 = Color(0xFF7D6738);
    const gold2 = Color(0xFFE3BB66);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => onTap?.call(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 39,
              height: 39,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
              ),
              child: ShaderMask(
                shaderCallback:
                    (b) => const LinearGradient(
                      colors: [gold1, gold2],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(b),
                child: Icon(icon, size: 20, color: Colors.white),
              ),
            ),
            const SizedBox(height: 2),
            ShaderMask(
              shaderCallback:
                  (b) => const LinearGradient(
                    colors: [Color(0xFFA49869), gold2],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ).createShader(b),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.itim(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}