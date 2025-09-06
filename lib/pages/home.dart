import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:app_oracel999/pages/navmenu.dart';
import 'lotto_item.dart';
import 'cart_provider.dart';

// HomeScreen ต้องเป็น StatefulWidget เพื่อจัดการ state การโหลดข้อมูล
class HomeScreen extends StatefulWidget {
  final String username;
  final String userId;

  const HomeScreen({
    super.key,
    required this.username,
    required this.userId,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // --- 1. เพิ่ม GlobalKey สำหรับ ScaffoldMessenger ---
  // นี่คือ "กุญแจพิเศษ" ที่ทำให้เราเรียก SnackBar ได้จากทุกที่
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  // State Variables สำหรับเก็บข้อมูลและสถานะการโหลด
  List<LottoItem> _luckyLottos = [];
  List<LottoItem> _auspiciousLottos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHomePageData(); // เรียก API ตอนหน้าเปิด
  }

  // ฟังก์ชันดึงข้อมูลจาก API ทั้ง 2 เส้นพร้อมกัน
  Future<void> _fetchHomePageData() async {
    // รีเซ็ตสถานะก่อนดึงข้อมูลใหม่ (สำหรับ RefreshIndicator)
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final luckyUrl = Uri.parse('http://192.168.6.1:8080/lotto/lucky');
      final auspiciousUrl = Uri.parse('http://192.168.6.1:8080/lotto/Auspicious');

      // ยิง request 2 เส้นพร้อมกันเพื่อความรวดเร็ว
      final responses = await Future.wait([
        http.get(luckyUrl).timeout(const Duration(seconds: 10)),
        http.get(auspiciousUrl).timeout(const Duration(seconds: 10)),
      ]);

      // ตรวจสอบ Response ของ "เลขเด็ด"
      if (responses[0].statusCode == 200) {
        final data = jsonDecode(responses[0].body);
        final List<dynamic> itemsJson = data['data'] ?? [];
        _luckyLottos = itemsJson.map((json) => LottoItem.fromJson(json)).toList();
      } else {
        throw Exception('ไม่สามารถโหลดเลขเด็ด (รหัส: ${responses[0].statusCode})');
      }

      // ตรวจสอบ Response ของ "เลขมงคล"
      if (responses[1].statusCode == 200) {
        final data = jsonDecode(responses[1].body);
        final List<dynamic> itemsJson = data['data'] ?? [];
        _auspiciousLottos = itemsJson.map((json) => LottoItem.fromJson(json)).toList();
      } else {
        throw Exception('ไม่สามารถโหลดเลขมงคล (รหัส: ${responses[1].statusCode})');
      }
    } catch (e) {
      _errorMessage = "เกิดข้อผิดพลาด:\n${e.toString()}";
    } finally {
      // อัปเดต UI ไม่ว่าจะสำเร็จหรือล้มเหลว
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // --- 2. แก้ไขฟังก์ชัน _addToCart ใหม่ทั้งหมด (สำคัญที่สุด) ---
  void _addToCart(LottoItem lotto) {
    // ดึง CartProvider มาใช้งาน
    final cart = Provider.of<CartProvider>(context, listen: false);

    // ตรวจสอบว่ามีของในตะกร้าแล้วหรือยัง
    if (cart.isItemInCart(lotto)) {
      // --- ถ้ามีแล้ว ---
      // ใช้ GlobalKey ในการแสดง SnackBar
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('สลากใบนี้อยู่ในตะกร้าแล้ว'),
          backgroundColor: Colors.orange, // สีส้มเพื่อเตือน
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // --- ถ้ายังไม่มี ---
      // เพิ่มของลงตะกร้า
      cart.addItem(lotto);
      // ใช้ GlobalKey ในการแสดง SnackBar
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('เพิ่มลงตะกร้าสำเร็จ!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // --- 3. เพิ่ม key ให้กับ Scaffold ---
    return Scaffold(
      key: _scaffoldMessengerKey, // <-- กำหนด key ที่นี่
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/bg4.png'),
            fit: BoxFit.cover,
          ),
        ),
        // จัดการการแสดงผลตามสถานะ
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _errorMessage != null
                ? Center(child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(_errorMessage!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.yellow, fontSize: 16)),
                ))
                : _buildContent(),
      ),
      bottomNavigationBar:
          MyBottomNavigationBar(username: widget.username, userId: widget.userId),
    );
  }

  // Widget สำหรับแสดงเนื้อหาหลักเมื่อโหลดสำเร็จ
  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: _fetchHomePageData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildHeader(),
            const SizedBox(height: 20),
            // สร้าง Section เลขเด็ดจากข้อมูล _luckyLottos
            _buildSection(
              'เลขเด็ดงวดนี้',
              const Color.fromARGB(216, 198, 161, 40),
              _luckyLottos.map((lotto) {
                return _LotteryCard(
                  lotto: lotto,
                  onAddToCart: () => _addToCart(lotto),
                  cardColor: Colors.red[800]!,
                  borderColor: const Color.fromARGB(255, 254, 229, 4),
                  cartColor: const Color.fromARGB(255, 254, 229, 4),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // สร้าง Section เลขมงคลจากข้อมูล _auspiciousLottos
            _buildSection('เลขมงคล', const Color.fromARGB(255, 255, 4, 4),
              _auspiciousLottos.map((lotto) {
                  return _LotteryCard(
                    lotto: lotto,
                    onAddToCart: () => _addToCart(lotto),
                    cardColor: const Color.fromARGB(255, 253, 214, 108),
                    borderColor: const Color.fromARGB(255, 252, 184, 35),
                    cartColor: const Color.fromARGB(255, 230, 32, 10),
                  );
                }).toList()
             ),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  // --- Widgets ย่อย ---
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.red[800],
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () { /* TODO: ไปหน้าโปรไฟล์ */ },
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.red),
          ),
        ),
      ),
      title: Text(
        'หน้าแรก',
        style: GoogleFonts.itim(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.red[800],
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Text(
        'วันนี้เฮงๆรวยๆ คุณ ${widget.username}',
        style: GoogleFonts.itim(fontSize: 24, color: Colors.white),
      ),
    );
  }

  Widget _buildSection(String title, Color headerColor, List<Widget> cards) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(title: title, color: headerColor),
        if (cards.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: Text('ไม่พบข้อมูลสลากในหมวดนี้', style: TextStyle(color: Colors.white70))),
          )
        else
          ...cards,
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 0, right: 16.0, top: 8.0, bottom: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(9.0),
            bottomRight: Radius.circular(9.0),
          ),
        ),
        child: Text(title, style: GoogleFonts.itim(color: Colors.white)),
      ),
    );
  }
}

class _LotteryCard extends StatelessWidget {
  final LottoItem lotto;
  final VoidCallback onAddToCart;
  final Color cardColor;
  final Color borderColor;
  final Color cartColor;

  const _LotteryCard({
    required this.lotto,
    required this.onAddToCart,
    required this.cardColor,
    required this.borderColor,
    required this.cartColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
          color: borderColor,
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'รหัสสลาก: ${lotto.lottoId}',
                        style: GoogleFonts.itim(
                          color: cardColor == Colors.red[800] ? Colors.white : Colors.grey[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          lotto.lotteryNumber.split('').join(' '),
                          style: GoogleFonts.itim(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text('ราคา', style: GoogleFonts.itim(color: cardColor == Colors.red[800] ? Colors.white : Colors.grey[800])),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                      child: Text(lotto.price.toStringAsFixed(0), style: GoogleFonts.itim(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    Text('บาท', style: GoogleFonts.itim(color: cardColor == Colors.red[800] ? Colors.white : Colors.grey[800])),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: cartColor,
                          child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 24),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

