// lib/pages/home_page.dart

import 'package:app_oracel999/model/response/cart_entry.dart';
import 'package:app_oracel999/pages/userprofile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- Imports ที่สะอาดและเป็นระเบียบ ---
import '../api/api_service.dart';
import '../model/response/lotto_item.dart';
import '../providers/cart_provider.dart';
import 'navmenu.dart';

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
  // 1. สร้าง Instance ของ ApiService
  final _apiService = ApiService();

  List<LottoItem> _luckyLottos = [];
  List<LottoItem> _auspiciousLottos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHomePageData();
  }

  // --- 👇 2. แก้ไขฟังก์ชันนี้ให้เรียกใช้ ApiService ---
  Future<void> _fetchHomePageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      // เรียกใช้ฟังก์ชันจาก ApiService ที่เราสร้างไว้
      final lottoData = await _apiService.fetchHomePageData();
      setState(() {
        // นำข้อมูลที่ได้มาอัปเดต State
        _luckyLottos = lottoData['luckyLottos']!;
        _auspiciousLottos = lottoData['auspiciousLottos']!;
      });
    } catch (e) {
      setState(() {
        _errorMessage =
            "เกิดข้อผิดพลาด:\n${e.toString().replaceFirst('Exception: ', '')}";
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // ฟังก์ชันเพิ่มของลงตะกร้า ✅ (แก้ไขเป็นใช้ ScaffoldMessenger.of(context))
  void _addToCart(LottoItem lotto, String colorType) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    if (cart.isItemInCart(lotto)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('อยู่ในตะกร้าแล้ว'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 1),//กำหนดเวลาแสดง1วิ
        ),
      );
    } else {
      cart.addItem(CartEntry(lotto: lotto, colorType: colorType));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('เพิ่มเข้าตะกร้าสำเร็จ'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 1),//กำหนดเวลาแสดง1วิ
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/bg4.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _errorMessage != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Colors.yellow, fontSize: 16),
                      ),
                    ),
                  )
                : _buildContent(),
      ),
      bottomNavigationBar: MyBottomNavigationBar(
        username: widget.username,
        userId: widget.userId,
      ),
    );
  }

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
            _buildSection('เลขเด็ดงวดนี้', _luckyLottos, isLucky: true),
            const SizedBox(height: 20),
            _buildSection('เลขมงคล', _auspiciousLottos, isLucky: false),
            const SizedBox(height: 50),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.red[800],
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => ProfilePage(
                  userId: widget.userId,
                  username: widget.username,
                ),
              ),
            );
          },
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.red),
          ),
        ),
      ),
      title: Text('หน้าแรก',
          style: GoogleFonts.itim(
              color: Colors.white, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.red[800],
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Text('วันนี้เฮงๆรวยๆ คุณ ${widget.username}',
          style: GoogleFonts.itim(fontSize: 24, color: Colors.white)),
    );
  }

  Widget _buildSection(String title, List<LottoItem> lottos,
      {required bool isLucky}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: title,
          color: isLucky
              ? const Color.fromARGB(216, 198, 161, 40)
              : const Color.fromARGB(255, 255, 4, 4),
        ),
        if (lottos.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(
              child: Text('ไม่พบข้อมูลสลากในหมวดนี้',
                  style: TextStyle(color: Colors.white70)),
            ),
          )
        else
          ...lottos.map((lotto) {
            return _LotteryCard(
              lotto: lotto,
              onAddToCart: () =>
                  _addToCart(lotto, isLucky ? "red" : "yellow"),
              cardColor: isLucky
                  ? Colors.red[800]!
                  : const Color.fromARGB(255, 253, 214, 108),
              borderColor: isLucky
                  ? const Color.fromARGB(255, 254, 229, 4)
                  : const Color.fromARGB(255, 252, 184, 35),
              cartColor: isLucky
                  ? const Color.fromARGB(255, 254, 229, 4)
                  : const Color.fromARGB(255, 230, 32, 10),
            );
          }).toList(),
      ],
    );
  }
}

// --- Widgets ย่อยที่ควรย้ายไปไฟล์ Widgets/home/ ---
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
          left: 0, right: 16.0, top: 8.0, bottom: 16.0),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: color,
          borderRadius: const BorderRadius.only(
              topRight: Radius.circular(9.0),
              bottomRight: Radius.circular(9.0)),
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
      padding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            color: borderColor, borderRadius: BorderRadius.circular(16.0)),
        child: Container(
          margin: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: cardColor, borderRadius: BorderRadius.circular(10.0)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('รหัสสลาก: ${lotto.lottoId}',
                          style: GoogleFonts.itim(
                              color: cardColor == Colors.red[800]
                                  ? Colors.white
                                  : Colors.grey[800],
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16.0, vertical: 10.0),
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.0)),
                        child: Text(lotto.lotteryNumber.split('').join(' '),
                            style: GoogleFonts.itim(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800])),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Text('ราคา',
                        style: GoogleFonts.itim(
                            color: cardColor == Colors.red[800]
                                ? Colors.white
                                : Colors.grey[800])),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8)),
                      child: Text(lotto.price.toStringAsFixed(0),
                          style: GoogleFonts.itim(
                              color: Colors.black,
                              fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 4),
                    Text('บาท',
                        style: GoogleFonts.itim(
                            color: cardColor == Colors.red[800]
                                ? Colors.white
                                : Colors.grey[800])),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: cartColor,
                          child: const Icon(Icons.add_shopping_cart,
                              color: Colors.white, size: 24),
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
