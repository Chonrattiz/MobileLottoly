// Newlotto.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/lotto_service.dart';

class Newlotto extends StatefulWidget {
  const Newlotto({super.key});

  @override
  State<Newlotto> createState() => _NewlottoState();
}

class _NewlottoState extends State<Newlotto> {
  List<DraftUpdateItem> _draftUpdates = []; // mapping lotto_id -> new number
  bool _loadingPreview = false;
  bool _loadingRelease = false;

  // ⬇️ เพิ่ม: ใช้เช็คว่ามีข้อมูลในตาราง lotto อยู่ไหม
  late Future<int> _countFuture;

  @override
  void initState() {
    super.initState();
    _countFuture = LottoService.countAll(); // เช็คจำนวนตอนเข้า
  }

  Future<void> _reloadCount() async {
    setState(() {
      _countFuture = LottoService.countAll();
    });
  }

  // ปุ่มสร้างล็อตเตอรี่ 100 ชุด (ทำเฉพาะตอน count == 0)
  Future<void> _seed100() async {
    try {
      final inserted = await LottoService.Generate(count: 100);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('สร้างล็อตเตอรี่สำเร็จ $inserted ชุด')),
      );

      // หลัง seed เสร็จ โหลดจำนวนใหม่ -> UI จะเปลี่ยนไปโหมดปกติทันที
      await _reloadCount();

      // ถ้าต้องแจ้งหน้าอื่นให้รีเฟรชด้วย (ถ้ามี event bus ของโปรเจ็กต์)
      // LottoRefresh.instance.bump();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('สร้างไม่สำเร็จ: $e')));
    }
  }

  Future<void> _preview() async {
    setState(() => _loadingPreview = true);
    try {
      final items = await LottoService.previewUpdate(
        count: 100,
        status: 'sell,sold', // สุ่มจากทุกสถานะที่ต้องการ
      );
      // ✅ จัดเรียง lotto_id จากน้อยไปมาก
      items.sort((a, b) => a.lottoId.compareTo(b.lottoId));

      setState(() => _draftUpdates = items); // แทนที่ชุดเดิม
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('สุ่มเลขชุดใหม่สำเร็จ (ยังไม่บันทึก)')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('สุ่มไม่สำเร็จ: $e')));
    } finally {
      setState(() => _loadingPreview = false);
    }
  }

  Future<void> _release() async {
    if (_draftUpdates.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ยังไม่มีเลขที่จะปล่อย')));
      return;
    }
    setState(() => _loadingRelease = true);
    try {
      // ✅ UPDATE ตาม mapping ที่ preview มา (ไม่สุ่มใหม่, ไม่ insert)
      await LottoService.bulkUpdateNumbers(_draftUpdates);
      setState(() => _draftUpdates = []);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อัปเดตเลขลงฐานข้อมูลสำเร็จ')),
      );

      // แจ้งหน้าอื่นให้รีเฟรช (ถ้ามีระบบกลาง)
      // LottoRefresh.instance.bump();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('อัปเดตไม่สำเร็จ: $e')));
    } finally {
      setState(() => _loadingRelease = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const redHeader = Color(0xFFAD0101);
    const goldBorder = Color(0xFFE3BB66);
    const numberRed = Color(0xFFD10400);

    Widget lottoSetCard({required String label, required List<int> digits}) {
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
                  label,
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
                  children: digits
                      .map(
                        (d) => Text(
                          '$d',
                          style: GoogleFonts.itim(
                            color: numberRed,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
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

    Widget _buildBodyList() {
      // 🔶 โหมด PREVIEW: โชว์ชุดที่รอปล่อย (lotto_id จริง + เลขใหม่) — เรียง asc
      if (_draftUpdates.isNotEmpty) {
        final previewSorted = [..._draftUpdates]
          ..sort((a, b) => a.lottoId.compareTo(b.lottoId));
        return LayoutBuilder(
          builder: (context, constraints) {
            final double cardW = constraints.maxWidth >= 373
                ? 373.0
                : constraints.maxWidth.toDouble();
            return Column(
              children: previewSorted.map((it) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: SizedBox(
                    width: cardW,
                    child: lottoSetCard(
                      label: 'ชุดที่ ${it.lottoId}', // ใช้ lotto_id จริง
                      digits: it.digits, // ใช้เลข "ใหม่" ที่จะอัปเดต
                    ),
                  ),
                );
              }).toList(),
            );
          },
        );
      }

      // 🔷 โหมดปกติ: ดึงรายการจริงจาก DB — เรียง asc
      return FutureBuilder<List<LottoItem>>(
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
                style: GoogleFonts.itim(color: Colors.white, fontSize: 16),
              ),
            );
          }
          final items = snap.data ?? [];
          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Text(
                'ไม่พบข้อมูลลอตเตอรี่',
                style: GoogleFonts.itim(color: Colors.white, fontSize: 16),
              ),
            );
          }

          // ✅ จัดเรียง lotto_id asc (กันพลาด แม้ backend จะเรียงมาอยู่แล้ว)
          items.sort((a, b) => a.lottoId.compareTo(b.lottoId));

          return LayoutBuilder(
            builder: (context, constraints) {
              final double cardW = constraints.maxWidth >= 373
                  ? 373.0
                  : constraints.maxWidth.toDouble();
              return Column(
                children: items.map((it) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: SizedBox(
                      width: cardW,
                      child: lottoSetCard(
                        label: 'ชุดที่ ${it.lottoId}',
                        digits: it.digits,
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(135.0),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(15),
            bottomRight: Radius.circular(15),
          ),
          child: AppBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Text(
                'สุ่มLottoชุดใหม่',
                style: GoogleFonts.itim(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            backgroundColor: const Color(0xFFD10400),
          ),
        ),
      ),

      // ⬇️ ใช้ FutureBuilder เช็ค count ก่อน
      body: FutureBuilder<int>(
        future: _countFuture,
        builder: (context, snap) {
          // กำลังโหลดจำนวน
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // โหลดจำนวนพลาด
          if (snap.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('โหลดจำนวนล้มเหลว: ${snap.error}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _reloadCount,
                    child: const Text('ลองใหม่'),
                  ),
                ],
              ),
            );
          }

          final cnt = snap.data ?? 0;

          // ✅ ถ้า "ยังไม่มีข้อมูลเลย" -> แสดงปุ่มกลางจอ "สร้างล็อตเตอรี่ 100 ชุด"
          if (cnt == 0) {
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/bb.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.auto_mode),
                  onPressed: _seed100,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF90191B),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  label: Text(
                    'สร้างล็อตเตอรี่ 100 ชุด',
                    style: GoogleFonts.itim(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            );
          }

          // ✅ มีข้อมูลแล้ว -> แสดง UI เดิม (ปุ่มสุ่ม/ปล่อย + รายการ)
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/bb.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 180, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // ▶️ Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // สุ่มอีกครั้ง (แทนที่ preview เดิมได้เรื่อย ๆ)
                        ElevatedButton(
                          onPressed: _loadingPreview ? null : _preview,
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
                          child: _loadingPreview
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'สุ่มชุดใหม่',
                                  style: GoogleFonts.itim(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),

                        // ปล่อย = UPDATE เลขใหม่ลง DB (ไม่สุ่มใหม่)
                        ElevatedButton(
                          onPressed: (_draftUpdates.isEmpty || _loadingRelease)
                              ? null
                              : _release,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.green.shade700,
                            side: const BorderSide(color: goldBorder, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
                          child: _loadingRelease
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(
                                  'ปล่อยชุดใหม่',
                                  style: GoogleFonts.itim(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),

                        // เคลียร์ preview กลับไปดูข้อมูลจริง
                        ElevatedButton(
                          onPressed: _draftUpdates.isEmpty
                              ? null
                              : () {
                                  setState(() => _draftUpdates = []);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('ล้างชุดที่รอปล่อยแล้ว'),
                                    ),
                                  );
                                },
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.grey.shade700,
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
                            'เคลียร์ชุดนี้',
                            style: GoogleFonts.itim(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // แถบแจ้งเตือนเมื่ออยู่โหมด preview
                    if (_draftUpdates.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF212121).withOpacity(0.7),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: goldBorder, width: 1),
                        ),
                        child: Text(
                          'กำลังแสดง “ชุดที่รอปล่อย” (กดสุ่มอีกครั้งเพื่อเปลี่ยน หรือกด “ปล่อยชุดใหม่” เพื่ออัปเดตลงฐานข้อมูล)',
                          style: GoogleFonts.itim(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    const SizedBox(height: 6),

                    // รายการ (preview หรือรายการจริง)
                    _buildBodyList(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
