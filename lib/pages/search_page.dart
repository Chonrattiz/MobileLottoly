import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_oracel999/pages/home.dart';
import 'package:app_oracel999/pages/navmenu.dart';
import 'package:provider/provider.dart';
import 'package:app_oracel999/pages/cart_provider.dart';

// 🔹 Model
class SearchItem {
  SearchItem({required this.id, required this.price, required this.number});
  final String id; // 🆔 เลขชุด
  final int price; // 💰 ราคา
  final String number; // 🔢 หมายเลขสลาก
}

// 🔹 หน้า SearchPage
class SearchPage extends StatefulWidget {
  final String userId;
  final String username;

  const SearchPage({super.key, required this.userId, required this.username});

  @override
  State<SearchPage> createState() => SearchState();
}

class SearchState extends State<SearchPage> {
  // สมมติว่านี่คือข้อมูลผลการค้นหา (ควรมาจาก API จริง)
  final List<SearchItem> _items = [
    SearchItem(id: '60', price: 80, number: '112233'),
    SearchItem(id: '99', price: 80, number: '445566'),
    SearchItem(id: '80', price: 80, number: '778899'),
  ];
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFAD0101);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/bg4.png'),
          fit: BoxFit.cover,
        ),
      ),
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
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(
                    username: widget.username,
                    userId: widget.userId,
                  ),
                ),
              );
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const SizedBox(height: 10),
            _buildSearchBox(),
            const SizedBox(height: 10),
            const Text(
              'ผลการค้นหา',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 197, 46, 36),
              ),
            ),
            const SizedBox(height: 20),
            ..._items.map((item) => SearchItemTile(item: item)),
          ],
        ),
        bottomNavigationBar: MyBottomNavigationBar(
          username: widget.username,
          userId: widget.userId,
        ),
      ),
    );
  }

  // 🔹 กล่องค้นหา
  Widget _buildSearchBox() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 250, 250, 250),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 3,
              blurRadius: 6,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "ค้นหาหมายเลขของสลากฯ",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(193, 56, 46, 1),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 300,
              height: 40,
              child: TextField(
                controller: _searchController,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: 'x x x x x x',
                  hintStyle: const TextStyle(
                    fontSize: 20,
                    color: Colors.black54,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.black,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildButton("ล้างค่า", Colors.red, () {
                  _searchController.clear();
                }),
                _buildButton("ค้นหา", Colors.green, () {
                  print("ค้นหา: ${_searchController.text}");
                  // TODO: เพิ่ม Logic การค้นหาจริง
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(String text, Color color, VoidCallback onPressed) {
    return SizedBox(
      width: 120, // ขยายปุ่มเล็กน้อย
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}

// 🔹 การ์ดแสดงผลการค้นหา
class SearchItemTile extends StatelessWidget {
  const SearchItemTile({super.key, required this.item});
  final SearchItem item;

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFAD0101);
    final gold = const Color(0xFFE3BB66);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: gold,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: red,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ชุดที่ ${item.id}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0, 4))
                        ]),
                    child: Text(
                      item.number.split('').join(' '), // แสดงเลขสลาก
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('ราคา',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 15)),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${item.price}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                const Text('บาท',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16)),
                const SizedBox(width: 8),
                // 🛒 ปุ่มเพิ่มลงตะกร้า
                GestureDetector(
                  onTap: () {
                    final cartProvider =
                        Provider.of<CartProvider>(context, listen: false);

                    if (cartProvider.isItemInCart(item.id)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('สลากใบนี้อยู่ในตะกร้าแล้ว'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    } else {
                      final newItem = CartItem(
                        id: item.id,
                        number: item.number,
                        price: item.price,
                        // ✅ จุดที่แก้ไข: กำหนดสีเป็น "red"
                        colorType: 'red',
                      );
                      cartProvider.addItem(newItem);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('เพิ่มลงในตะกร้าแล้ว'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 227, 187, 102),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Icon(
                      Icons.add_shopping_cart,
                      color: Colors.white,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
