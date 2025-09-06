import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:app_oracel999/pages/navmenu.dart';
import 'package:app_oracel999/pages/lotto_item.dart';
import 'package:app_oracel999/pages/cart_provider.dart';

// HomeScreen ต้องเป็น StatefulWidget เพื่อจัดการ state
class HomeScreen extends StatefulWidget {
  final String username;
  final String userId;

  const HomeScreen({super.key, required this.username, required this.userId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<LottoItem> _luckyLottos = [];
  List<LottoItem> _auspiciousLottos = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHomePageData(); // โหลดข้อมูลตอนเปิดหน้า
  }

  // ฟังก์ชันดึงข้อมูลจาก API ทั้ง 2 เส้นพร้อมกัน
  Future<void> _fetchHomePageData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final luckyUrl = Uri.parse('http://192.168.85.1:8080/lotto/lucky');
      final auspiciousUrl = Uri.parse(
        'http://192.168.85.1:8080/lotto/Auspicious',
      );

      final responses = await Future.wait([
        http.get(luckyUrl).timeout(const Duration(seconds: 10)),
        http.get(auspiciousUrl).timeout(const Duration(seconds: 10)),
      ]);

      if (responses[0].statusCode == 200) {
        final data = jsonDecode(responses[0].body);
        final List<dynamic> itemsJson = data['data'] ?? [];
        _luckyLottos =
            itemsJson.map((json) => LottoItem.fromJson(json)).toList();
      } else {
        throw Exception('ไม่สามารถโหลดเลขเด็ด (${responses[0].statusCode})');
      }

      if (responses[1].statusCode == 200) {
        final data = jsonDecode(responses[1].body);
        final List<dynamic> itemsJson = data['data'] ?? [];
        _auspiciousLottos =
            itemsJson.map((json) => LottoItem.fromJson(json)).toList();
      } else {
        throw Exception('ไม่สามารถโหลดเลขมงคล (${responses[1].statusCode})');
      }
    } catch (e) {
      _errorMessage = "เกิดข้อผิดพลาด:\n${e.toString()}";
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ฟังก์ชันเพิ่มลงตะกร้า (แก้ไข: เพิ่มพารามิเตอร์ colorType)
  void _addToCart(LottoItem lotto, String colorType) {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final lottoIdAsString = lotto.lottoId.toString();

    // เช็คก่อนว่าสลากนี้อยู่ในตะกร้าแล้วหรือยัง
    if (cart.isItemInCart(lottoIdAsString)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('สลากใบนี้อยู่ในตะกร้าแล้ว'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      // สร้าง CartItem ใหม่พร้อมสีที่ส่งมา
      final newItem = CartItem(
        id: lotto.lottoId.toString(),
        number: lotto.lotteryNumber,
        price: lotto.price.toInt(),
        colorType: colorType, // ใช้สีที่ส่งเข้ามาจาก onAddToCart
      );

      // เพิ่มสลากลงตะกร้า
      cart.addItem(newItem);

      ScaffoldMessenger.of(context).showSnackBar(
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
    return Scaffold(
      appBar: _buildAppBar(context),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/image/bg4.png'),
            fit: BoxFit.cover,
          ),
        ),
        child:
            _isLoading
                ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
                : _errorMessage != null
                ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      _errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontSize: 16,
                      ),
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

  // --- Widgets ย่อย ---
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.red[800],
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: IconButton(
          onPressed: () {
            /* TODO: ไปหน้าโปรไฟล์ */
          },
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
            _buildSection(
              'เลขเด็ดงวดนี้',
              const Color.fromARGB(216, 198, 161, 40),
              _luckyLottos.map((lotto) {
                return _LotteryCard(
                  lotto: lotto,

                  onAddToCart: () => _addToCart(lotto, "red"), // สีแดง
                  cardColor: Colors.red[800]!,
                  borderColor: const Color.fromARGB(255, 254, 229, 4),
                  cartColor: const Color.fromARGB(255, 254, 229, 4),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            _buildSection(
              'เลขมงคล',
              const Color.fromARGB(255, 255, 4, 4),
              _auspiciousLottos.map((lotto) {
                return _LotteryCard(
                  lotto: lotto,
                  onAddToCart: () => _addToCart(lotto, "yellow"), // สีเหลือง
                  cardColor: const Color.fromARGB(255, 253, 214, 108),
                  borderColor: const Color.fromARGB(255, 252, 184, 35),
                  cartColor: const Color.fromARGB(255, 230, 32, 10),
                );
              }).toList(),
            ),
            const SizedBox(height: 50),
          ],
        ),
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
            child: Center(
              child: Text(
                'ไม่พบข้อมูลสลากในหมวดนี้',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          )
        else
          ...cards,
      ],
    );
  }
}

// --- Widgets แยกย่อย ---
class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;
  const _SectionHeader({required this.title, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 0,
        right: 16.0,
        top: 8.0,
        bottom: 16.0,
      ),
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
                          color:
                              cardColor == Colors.red[800]
                                  ? Colors.white
                                  : Colors.grey[800],
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
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
                    Text(
                      'ราคา',
                      style: GoogleFonts.itim(
                        color:
                            cardColor == Colors.red[800]
                                ? Colors.white
                                : Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        lotto.price.toStringAsFixed(0),
                        style: GoogleFonts.itim(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'บาท',
                      style: GoogleFonts.itim(
                        color:
                            cardColor == Colors.red[800]
                                ? Colors.white
                                : Colors.grey[800],
                      ),
                    ),
                    GestureDetector(
                      onTap: onAddToCart,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: CircleAvatar(
                          radius: 20,
                          backgroundColor: cartColor,
                          child: const Icon(
                            Icons.add_shopping_cart,
                            color: Colors.white,
                            size: 24,
                          ),
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
