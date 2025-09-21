import 'dart:async';
import 'package:app_oracel999/model/response/lotto_item.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_oracel999/admim/RewardPage.dart';
import 'package:app_oracel999/admim/lottoEnough.dart';
import 'package:app_oracel999/admim/lottoselled.dart';
import 'package:app_oracel999/admim/newlotto.dart';
import 'package:app_oracel999/service/lotto_service.dart';
import 'package:app_oracel999/admim/UIprofileAdmin.dart';
import 'lotto_refresh.dart';

class AdminMain extends StatefulWidget {
  const AdminMain({
    super.key,
    required this.username,
    required this.userId,
    required this.role,
  });

  final String username;
  final String userId;
  final String role;

  @override
  State<AdminMain> createState() => _AdminMainState();
}

class _AdminMainState extends State<AdminMain> {
  late Future<List<LottoItem>> _future;
  StreamSubscription? _sub;

  @override
  void initState() {
    super.initState();
    _reload();
    // ฟังสัญญาณรีเฟรชจากหน้าอื่น (เช่น Newlotto)
    _sub = LottoRefresh.instance.stream.listen((_) => _reload());
  }

  void _reload() {
    _future = LottoService.fetchAllAsc();
    setState(() {}); // กระตุ้น FutureBuilder ให้วิ่งใหม่
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ guard role
    if (widget.role.trim().toLowerCase() != 'admin') {
      return Scaffold(
        appBar: AppBar(
          title: Text('รายการ (Admin)', style: GoogleFonts.itim()),
          backgroundColor: const Color(0xFFD10400),
        ),
        body: Center(
          child: Text(
            'คุณไม่มีสิทธิ์เข้าถึงหน้านี้',
            style: GoogleFonts.itim(fontSize: 18),
          ),
        ),
      );
    }

    const redHeader = Color(0xFFAD0101);
    const goldBorder = Color(0xFFE3BB66);
    const numberRed = Color(0xFFD10400);

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
      // ✨ --- START: โค้ดที่แก้ไข --- ✨
      appBar: AppBar(
        title: Text(
          'รายการ (Admin)',
          style: GoogleFonts.itim(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFD10400),
        elevation: 0,
        centerTitle: false, // ชิดซ้ายตามดีไซน์
        toolbarHeight: 70, // ✅ ลดความสูงไม่ให้กินพื้นที่เกิน
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
        ),
        actions: [
          InkWell(
            borderRadius: BorderRadius.circular(50),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => ProfilePageUI(
                        userId: widget.userId,
                        role: widget.role,
                      ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Text(
                    'สวัสดี, ${widget.username}',
                    style: GoogleFonts.itim(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.account_circle,
                    size: 40,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // ✨ --- END: โค้ดที่แก้ไข --- ✨
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
          // ✅ ดึง-ลง-เพื่อรีเฟรช
          RefreshIndicator(
            onRefresh: () async => _reload(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                20,
                150,
                20,
                24,
              ), // ปรับ Padding ด้านบนให้พอดี
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // ไปหน้า "ลอตเตอรี่ที่เหลือ" แล้วรอค่ากลับ
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const lottoenough(),
                            ),
                          );
                          if (mounted) _reload(); // กลับมาแล้วรีโหลด
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF90191B),
                          side: const BorderSide(color: goldBorder, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          'ลอตโต้ที่เหลือ',
                          style: GoogleFonts.itim(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const Lottoselled(),
                            ),
                          );
                          if (mounted) _reload();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF90191B),
                          side: const BorderSide(color: goldBorder, width: 2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                        ),
                        child: Text(
                          'ขายแล้ว',
                          style: GoogleFonts.itim(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 🔥 โหลดจริงจาก API
                  FutureBuilder<List<LottoItem>>(
                    future: _future,
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
                      final items = snap.data ?? [];
                      if (items.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Text(
                            'ไม่พบรายการลอตเตอรี่',
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
                                  ? 373.0
                                  : constraints.maxWidth.toDouble();
                          return Column(
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
          ),
        ],
      ),
      bottomNavigationBar: _BottomActionBar(
        onOpenNew: () async {
          final changed = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Newlotto()),
          );
          if (changed == true && mounted) _reload();
        },
        onOpenReward: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RewardPage()),
          );
          if (mounted) _reload(); // ถ้ากลับมาแล้วอยากรีโหลดรายการ
        },
      ),
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
