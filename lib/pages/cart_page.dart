import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_oracel999/pages/home.dart';
import 'package:app_oracel999/pages/navmenu.dart';
import 'package:provider/provider.dart';
import 'package:app_oracel999/pages/cart_provider.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key, required String username, required String userId});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final red = const Color(0xFFAD0101);
    final green = const Color.fromARGB(255, 8, 224, 62);

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
          title: Text('ตระกร้า',
              style: GoogleFonts.itim(
                  textStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 30,
                      color: Colors.white))),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              // แก้ไข: ควรส่งค่า username และ userId กลับไปด้วย
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const HomeScreen(username: '', userId: '')),
              );
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text('รายการ',
                style: GoogleFonts.itim(
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 25,
                        color: Color(0xFFAD0101)))),
            const SizedBox(height: 16),
            // สร้างรายการจาก provider
            ...cartProvider.items.map((item) => _CartItemTile(
                  item: item,
                  onChangedSelected: (v) =>
                      cartProvider.toggleItem(item.id, v ?? false),
                  onChangedNumber: (text) =>
                      cartProvider.updateNumber(item.id, text),
                )),
            const SizedBox(height: 20),
            _summaryRow('จำนวน', '${cartProvider.selectedCount} รายการ'),
            const SizedBox(height: 12),
            _summaryRow('ราคารวม', '${cartProvider.total} บาท'),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {},
              child:
                  const Text('ดำเนินการสั่งซื้อ', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        // แก้ไข: ควรส่งค่า username และ userId ไปด้วย
        bottomNavigationBar: const MyBottomNavigationBar(
          username: '',
          userId: '',
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 227, 187, 102),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(value,
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
      );
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({
    required this.item,
    required this.onChangedSelected,
    required this.onChangedNumber,
  });

  final CartItem item;
  final ValueChanged<bool?> onChangedSelected;
  final ValueChanged<String> onChangedNumber;

  String _formatDigits(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    final six = digits.length > 6 ? digits.substring(0, 6) : digits;
    return six.split('').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    // --- ส่วนที่แก้ไข ---
    // สร้าง Map เพื่อแปลง String สีไปเป็น Object Color
    final Map<String, Color> colorMap = {
      "red": Colors.red[800]!,
      "yellow": const Color.fromARGB(255, 253, 214, 108),
    };

    // ดึงสีที่ถูกต้องจาก Map, ถ้าไม่เจอให้ใช้สีดำเป็นค่าเริ่มต้น
    final cardColor = colorMap[item.colorType] ?? Colors.black;

    final gold = const Color(0xFFE3BB66);

    // คำนวณสีตัวอักษรให้อ่านง่าย
    final textColor =
        cardColor.computeLuminance() > 0.5 ? Colors.black87 : Colors.white;
    // --- จบส่วนที่แก้ไข ---

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _TickBox(
          checked: item.selected,
          onTap: () => onChangedSelected(!item.selected),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: gold,
              borderRadius: BorderRadius.circular(24),
            ),
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: cardColor, // <-- ใช้สีที่แปลงแล้ว
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ชุดที่ ${item.id}',
                      style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.w900,
                          fontSize: 16)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 40,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: const [
                                BoxShadow(
                                    color: Colors.black26,
                                    blurRadius: 2,
                                    offset: Offset(0, 4))
                              ]),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formatDigits(item.number.isNotEmpty
                                ? item.number
                                : '123456'), // แสดงเลขจาก item
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                                color: Colors.black87),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('ราคา',
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 15, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text('${item.price}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                                color: Colors.black)),
                      ),
                      const SizedBox(width: 8),
                      Text('บาท',
                          style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TickBox extends StatelessWidget {
  const _TickBox({required this.checked, required this.onTap});

  final bool checked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: checked ? const Color(0xFFD92323) : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFD92323), width: 2),
        ),
        alignment: Alignment.center,
        child: Icon(Icons.check,
            size: 20, color: checked ? Colors.white : Colors.transparent),
      ),
    );
  }
}
