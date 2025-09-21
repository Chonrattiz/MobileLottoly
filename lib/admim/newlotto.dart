// Newlotto.dart

import 'package:app_oracel999/model/response/lotto_item.dart';
import 'package:app_oracel999/model/response/updateitem.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_oracel999/service/lotto_service.dart';

class Newlotto extends StatefulWidget {
  const Newlotto({super.key});

  @override
  State<Newlotto> createState() => _NewlottoState();
}

class _NewlottoState extends State<Newlotto> {
  List<DraftUpdateItem> _draftUpdates = []; // เก็บรายการที่สุ่มรอไว้
  bool _loadingPreview = false;
  bool _loadingRelease = false;

  // --- ✅ ตัวแปรที่เพิ่มเข้ามา ---
  bool _loadingClearDb = false; // สถานะโหลดของปุ่มล้างข้อมูล
  bool _dbHasData = false; // เช็คว่าในฐานข้อมูลมีข้อมูลหรือไม่
  Future<List<LottoItem>>? _lottoFuture; // เก็บ future สำหรับ FutureBuilder

  @override
  void initState() {
    super.initState();
    // --- ✅ กำหนด Future ตอนเริ่มต้น ---
    _lottoFuture = LottoService.fetchAllAsc();
  }

  // ฟังก์ชันสำหรับรีเฟรชข้อมูลใน FutureBuilder
  void _refreshData() {
    if (!mounted) return;
    setState(() {
      _lottoFuture = LottoService.fetchAllAsc();
    });
  }

  Future<void> _preview() async {
    setState(() => _loadingPreview = true);
    try {
      final items = await LottoService.previewUpdate(
        count: 100,
        status: 'sell,sold',
      );
      items.sort((a, b) => a.lottoId.compareTo(b.lottoId));

      if (mounted) {
        setState(() => _draftUpdates = items);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('สุ่มเลขชุดใหม่สำเร็จ (ยังไม่บันทึก)')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('สุ่มไม่สำเร็จ: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loadingPreview = false);
      }
    }
  }

  Future<bool?> _showConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('ยืนยันการปล่อยชุดใหม่', style: GoogleFonts.itim()),
          content: Text(
            'คุณแน่ใจหรือไม่ว่าต้องการอัปเดตเลขชุดใหม่นี้ลงฐานข้อมูล?\n(การกระทำนี้ไม่สามารถย้อนกลับได้)',
            style: GoogleFonts.itim(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'ยกเลิก',
                style: GoogleFonts.itim(color: Colors.grey.shade700),
              ),
              onPressed: () {
                Navigator.of(context).pop(false); // ส่งค่า false กลับไป
              },
            ),
            TextButton(
              child: Text(
                'ยืนยัน',
                style: GoogleFonts.itim(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(true); // ส่งค่า true กลับไป
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _release() async {
    if (_draftUpdates.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ยังไม่มีเลขที่จะปล่อย')));
      return;
    }

    final bool? confirmed = await _showConfirmationDialog();
    if (confirmed != true) {
      return;
    }

    setState(() => _loadingRelease = true);
    try {
      await LottoService.generateNew(_draftUpdates);
      if (mounted) {
        setState(() => _draftUpdates = []);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('อัปเดตเลขลงฐานข้อมูลสำเร็จ')),
        );
        _refreshData(); // รีเฟรชข้อมูลหลักหลังจากปล่อยชุดใหม่สำเร็จ
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('อัปเดตไม่สำเร็จ: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loadingRelease = false);
      }
    }
  }

  // --- ✅ ฟังก์ชันสำหรับแสดง Dialog ยืนยันการล้างข้อมูล ---
  Future<bool?> _showClearDbConfirmationDialog() async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('ยืนยันการล้างข้อมูล', style: GoogleFonts.itim()),
          content: Text(
            'ข้อมูลลอตเตอรี่ทั้งหมดจะถูกลบออกจากระบบ คุณแน่ใจหรือไม่?\n(การกระทำนี้ไม่สามารถย้อนกลับได้)',
            style: GoogleFonts.itim(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'ยกเลิก',
                style: GoogleFonts.itim(color: Colors.grey.shade700),
              ),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(
                'ยืนยันลบทั้งหมด',
                style: GoogleFonts.itim(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );
  }

  // --- ✅ ฟังก์ชันสำหรับล้างข้อมูลในฐานข้อมูล ---
  Future<void> _clearDatabase() async {
    final confirmed = await _showClearDbConfirmationDialog();
    if (confirmed != true) return;

    if (!mounted) return;
    setState(() => _loadingClearDb = true);

    try {
      // giả sử đã thêm hàm clearLottoData() trong LottoService
      // await LottoService.clearLottoData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('ล้างข้อมูลลอตเตอรี่สำเร็จ')),
        );
        _refreshData(); // รีเฟรชข้อมูลเพื่อให้ UI อัปเดตเป็นค่าว่าง
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('ล้างข้อมูลไม่สำเร็จ: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _loadingClearDb = false);
      }
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
              left: 20,
              top: 6,
              child: Text(
                label,
                style: GoogleFonts.itim(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 35,
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
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

    Widget buildBodyList() {
      if (_draftUpdates.isNotEmpty) {
        return Column(
          children: List.generate(_draftUpdates.length, (index) {
            final it = _draftUpdates[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: lottoSetCard(
                label: 'ชุดที่ ${index + 1}',
                digits: it.digits,
              ),
            );
          }),
        );
      }

      return FutureBuilder<List<LottoItem>>(
        future: _lottoFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.only(top: 40.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snap.hasError) {
            return Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Center(
                child: Text(
                  'เกิดข้อผิดพลาด: ${snap.error}',
                  style: GoogleFonts.itim(color: Colors.white, fontSize: 16),
                ),
              ),
            );
          }

          final items = snap.data ?? [];

          // --- ✅ อัปเดต State ว่ามีข้อมูลใน DB หรือไม่ ---
          // ใช้ PostFrameCallback เพื่อป้องกันการเรียก setState ระหว่าง build
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _dbHasData != items.isNotEmpty) {
              setState(() {
                _dbHasData = items.isNotEmpty;
              });
            }
          });

          if (items.isEmpty) {
            return Padding(
              padding: const EdgeInsets.only(top: 40.0),
              child: Center(
                child: Text(
                  'ไม่พบข้อมูลลอตเตอรี่',
                  style: GoogleFonts.itim(color: Colors.white, fontSize: 16),
                ),
              ),
            );
          }

          items.sort((a, b) => a.lottoId.compareTo(b.lottoId));

          return Column(
            children: List.generate(items.length, (index) {
              final it = items[index];
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: lottoSetCard(
                  label: 'ชุดที่ ${index + 1}',
                  digits: it.digits,
                ),
              );
            }),
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
            centerTitle: true,
            backgroundColor: const Color(0xFFD10400),
            flexibleSpace: Align(
              alignment: const Alignment(0.0, 0.4),
              child: Text(
                'สุ่มLottoชุดใหม่',
                style: GoogleFonts.itim(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/image/bb.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 160, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: WrapAlignment.center,
                  children: [
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
                      child:
                          _loadingPreview
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                'สุ่มชุดใหม่',
                                style: GoogleFonts.itim(fontSize: 16),
                              ),
                    ),
                    ElevatedButton(
                      onPressed:
                          (_draftUpdates.isEmpty || _loadingRelease)
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
                      child:
                          _loadingRelease
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                'ปล่อยชุดใหม่',
                                style: GoogleFonts.itim(fontSize: 16),
                              ),
                    ),
                    ElevatedButton(
                      onPressed:
                          _draftUpdates.isEmpty
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
                        style: GoogleFonts.itim(fontSize: 16),
                      ),
                    ),

                    // --- ✅ ปุ่มที่เพิ่มเข้ามาใหม่ ---
                    ElevatedButton(
                      onPressed:
                          _loadingClearDb || !_dbHasData
                              ? null
                              : _clearDatabase,
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.red.shade800, // สีแดงเข้ม
                        side: const BorderSide(color: goldBorder, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      child:
                          _loadingClearDb
                              ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : Text(
                                'ล้างข้อมูลทั้งหมด',
                                style: GoogleFonts.itim(fontSize: 16),
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
                      'กำลังแสดง “ชุดที่รอปล่อย” (กด “ปล่อยชุดใหม่” เพื่อบันทึก)',
                      style: GoogleFonts.itim(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 6),
                buildBodyList(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
