// lib/pages/search_page.dart

import 'package:app_oracel999/model/response/cart_entry.dart';
import 'package:app_oracel999/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- Imports ที่สะอาดและเป็นระเบียบ ---
import '../api/api_service.dart';
import '../model/response/check_response.dart'; // 👈 **สำคัญ:** ต้อง import เข้ามาเพื่อรู้จัก CurrentReward
import '../model/response/lotto_item.dart';
import '../providers/cart_provider.dart';
import 'navmenu.dart';

class SearchPage extends StatefulWidget {
  final String userId;
  final String username;

  const SearchPage({super.key, required this.userId, required this.username});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final _apiService = ApiService();
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final _searchController = TextEditingController();

  List<LottoItem> _searchResults = [];
  bool _isLoading = false;
  String? _searchMessage;

  // --- 1. State เพื่อเก็บสถานะการประกาศผลรางวัล ---
  bool _areRewardsAnnounced = false;

  @override
  void initState() {
    super.initState();
    // --- 2. เรียกฟังก์ชันตรวจสอบผลรางวัลเมื่อหน้าถูกโหลด ---
    _checkRewardStatus();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // --- 3. ฟังก์ชันสำหรับตรวจสอบสถานะผลรางวัล (ฉบับแก้ไข) ---
  Future<void> _checkRewardStatus() async {
    try {
      // ดึงข้อมูล "รายการ" ผลรางวัลล่าสุดจาก API
      final List<CurrentReward> latestRewardsList = await _apiService.fetchLatestRewards();

      // ตรวจสอบว่า "รายการ" ที่ได้มานั้นว่างเปล่าหรือไม่
      if (mounted && latestRewardsList.isNotEmpty) {
        // ถ้ารายการ "ไม่ว่าง" แสดงว่าประกาศผลแล้ว
        setState(() {
          _areRewardsAnnounced = true;
        });
      }
    } catch (e) {
      // หากเกิดข้อผิดพลาด ให้ถือว่ายังไม่ประกาศผล (เพื่อความปลอดภัย)
      if (mounted) {
         setState(() {
          _areRewardsAnnounced = false;
        });
      }
      // สามารถแสดงข้อความแจ้งเตือนได้หากต้องการ
      // print("Could not check reward status: $e");
    }
  }

  // --- ฟังก์ชันค้นหา ---
  Future<void> _performSearch() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      _showSnackbar('กรุณาป้อนหมายเลขที่ต้องการค้นหา', isError: true);
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _searchMessage = null;
      _searchResults = [];
    });

    try {
      final results = await _apiService.searchLotto(query);
      setState(() {
        _searchResults = results;
        if (results.isEmpty) {
          _searchMessage = 'ไม่พบสลากที่ตรงกับ "$query"';
        }
      });
    } catch (e) {
      setState(() {
        _searchMessage =
            "เกิดข้อผิดพลาด:\n${e.toString().replaceFirst('Exception: ', '')}";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- ฟังก์ชันสุ่มตัวเลข ---
  Future<void> _getRandomNumber() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
      _searchMessage = 'กำลังสุ่มเลข...';
      _searchResults = [];
    });

    try {
      final randomLotto = await _apiService.getRandomLotto();
      setState(() {
        _searchController.text = randomLotto.lottoNumber; // 👈 **แก้ไข:** lottoNumber
        _searchMessage = 'เจอเลขสุ่มแล้ว! กดค้นหาได้เลย';
      });
    } catch (e) {
      setState(() {
        _searchMessage =
            "เกิดข้อผิดพลาด:\n${e.toString().replaceFirst('Exception: ', '')}";
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- ฟังก์ชันเพิ่มลงตะกร้า ---
  void _addToCart(LottoItem lotto) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.isItemInCart(lotto)) {
      _showSnackbar('สลากใบนี้อยู่ในตะกร้าแล้ว', isError: true);
    } else {
      cart.addItem(CartEntry(lotto: lotto, colorType: 'red'));
      _showSnackbar('เพิ่มลงตะกร้าสำเร็จ!');
    }
  }

  // --- ฟังก์ชันแสดง SnackBar ---
  void _showSnackbar(String message, {bool isError = false}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFAD0101);

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          toolbarHeight: 80,
          title: Text(
            'ค้นหาเลข',
            style: GoogleFonts.itim(
                fontWeight: FontWeight.bold, fontSize: 25, color: Colors.white),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    HomeScreen(username: widget.username, userId: widget.userId),
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/image/bg4.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            children: [
              _buildSearchCard(),
              const SizedBox(height: 20),
              const Text(
                'ผลการค้นหา',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 197, 46, 36)),
              ),
              const SizedBox(height: 10),
              _buildSearchResults(),
            ],
          ),
        ),
        bottomNavigationBar: MyBottomNavigationBar(
          username: widget.username,
          userId: widget.userId,
        ),
      ),
    );
  }

  // --- UI Card สำหรับค้นหา ---
  Widget _buildSearchCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text("ค้นหาหมายเลขสลากฯ",
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFAD0101))),
          const SizedBox(height: 20),
          TextField(
            controller: _searchController,
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold, letterSpacing: 4),
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: InputDecoration(
              hintText: 'กรอกเลข 1-6 หลัก',
              counterText: "",
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                  onPressed: _getRandomNumber,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 47, 132, 211)),
                  child: const Text('สุ่มตัวเลข', style: TextStyle(color: Colors.white))),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _searchResults = [];
                    _searchMessage = null;
                  });
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red[700]),
                child: const Text('ล้างค่า', style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: _performSearch,
                style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 73, 231, 81)),
                child: const Text('ค้นหา', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- แสดงผลลัพธ์การค้นหา ---
  Widget _buildSearchResults() {
    if (_isLoading) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(color: Colors.white)));
    }
    if (_searchMessage != null) {
      return Center(
          child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(_searchMessage!,
                  style: const TextStyle(color: Colors.white, fontSize: 18))));
    }
    return Column(
      children: _searchResults
          .map((item) => _SearchResultTile(
                item: item,
                onAddToCart: () => _addToCart(item),
                // --- 4. ส่งค่าสถานะการประกาศผลไปยัง Widget แสดงผล ---
                areRewardsAnnounced: _areRewardsAnnounced,
              ))
          .toList(),
    );
  }
}

class _SearchResultTile extends StatelessWidget {
  final LottoItem item;
  final VoidCallback onAddToCart;
  // --- 5. รับค่าสถานะการประกาศผล ---
  final bool areRewardsAnnounced;

  const _SearchResultTile({
    required this.item,
    required this.onAddToCart,
    required this.areRewardsAnnounced,
  });

  @override
  Widget build(BuildContext context) {
    const cardColor = Color(0xFFB71C1C);
    const borderColor = Color(0xFFE3BB66);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(color: borderColor, borderRadius: BorderRadius.circular(24)),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(20)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('รหัสสลาก: ${item.lottoId}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: Center(
                        child: Text(item.lottoNumber.split('').join(' '), // 👈 **แก้ไข:** lottoNumber
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black)),
                      ),
                    ),
                  ]),
            ),
            const SizedBox(width: 16),
            Column(
              children: [
                Text('${item.price.toStringAsFixed(0)} บาท',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                // --- 6. เพิ่มเงื่อนไข !areRewardsAnnounced ในการแสดงผลไอคอนตะกร้า ---
                // ไอคอนจะแสดงก็ต่อเมื่อ: สลากมีสถานะ 'sell' และ ยังไม่มีการประกาศผลรางวัล
                if (item.status.toLowerCase() == 'sell' && !areRewardsAnnounced)
                  GestureDetector(
                    onTap: onAddToCart,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(color: borderColor, shape: BoxShape.circle),
                      child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 25),
                    ),
                  )
                else
                  // ถ้าเงื่อนไขไม่ตรง ให้แสดงกล่องว่างๆ ที่มีขนาดเท่ากับไอคอน
                  const SizedBox(width: 45, height: 45),
              ],
            ),
          ],
        ),
      ),
    );
  }
}