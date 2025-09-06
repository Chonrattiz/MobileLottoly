import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotto_application/pages/home.dart';
import 'package:lotto_application/pages/navmenu.dart';
import 'package:provider/provider.dart';
import 'package:lotto_application/pages/cart_provider.dart';

class CartPage extends StatefulWidget {
  // 📄 หน้า Cart ที่มีสถานะ
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  @override
  Widget build(BuildContext context) {
    // เพิ่มบรรทัดนี้เพื่อเรียกใช้งาน CartProvider
    final cartProvider = Provider.of<CartProvider>(context);
    final red = const Color(0xFFAD0101); // 🎨 สีแดง
    final gold = const Color(0xFFE3BB66); // 🎨 สีทอง
    final green = const Color.fromARGB(255, 8, 224, 62); 

    return Container(
      // // 🖼 ใส่พื้นหลังทั้งหน้า
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/bg4.png'), // ✅ รูปพื้นหลัง
          fit: BoxFit.cover, // ให้เต็มจอ
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // 🔹 ทำ Scaffold โปร่งใส
        appBar: AppBar(
          // 🔺 ส่วนหัวสีแดงด้านบน
          backgroundColor: red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          toolbarHeight: 80, // 📏 ความสูงแถบหัว
          title: Text(
            'ตระกร้า',
            style: GoogleFonts.itim(
              textStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: Colors.white,
              ),
            ),
          ),
          //ย้อนกลับ
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(username: ''),
                ),
              );
            },
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            Text(
              'รายการ',
              style: GoogleFonts.itim(
                textStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 25,
                  color: Color(0xFFAD0101),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // แก้ไขส่วนนี้ให้ดึงข้อมูลจาก provider
            ...cartProvider.items.map(
              (item) => _CartItemTile(
                item: item,
                onChangedSelected: (v) =>
                    cartProvider.toggleItemSelection(item.id, v ?? false),
                onChangedNumber: (text) => setState(() => item.number = text),
              ),
            ),
            const SizedBox(height: 20),
            // แก้ไขส่วนนี้ให้ดึงข้อมูลจาก provider
            _summaryRow('จำนวน', '${cartProvider.selectedCount} รายการ'),
            const SizedBox(height: 12),
            // แก้ไขส่วนนี้ให้ดึงข้อมูลจาก provider
            _summaryRow('ราคารวม', '${cartProvider.total} บาท'),

            // เพิ่มโค้ดส่วนนี้
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // โค้ดสำหรับจัดการเมื่อกดปุ่ม
              },
              child: const Text('ดำเนินการสั่งซื้อ', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
        bottomNavigationBar:
            const MyBottomNavigationBar(), //เรียกบาร์ด้านล่างมา
      ),
    );
  }

  Widget _summaryRow(String label, String value) => Container(
    // 📊 กล่องสรุปจำนวนและราคารวม
    height: 48,
    padding: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: const Color.fromARGB(255, 227, 187, 102), // 🎨 สีพื้นกล่อง
      borderRadius: BorderRadius.circular(14),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ],
    ),
  );
}

class _CartItemTile extends StatelessWidget {
  // 🧾 การ์ดรายการแบบ checkbox อยู่นอกการ์ด
  const _CartItemTile({
    required this.item,
    required this.onChangedSelected,
    required this.onChangedNumber,
  });

  final CartItem item; // ข้อมูลชุด
  final ValueChanged<bool?> onChangedSelected; // toggle เลือก/ไม่เลือก
  final ValueChanged<String>
  onChangedNumber; // เปลี่ยนเลข (ยังคงรับ callback ไว้ เผื่อใช้ในอนาคต)

  // 🔧 ฟังก์ชันจัดรูปแบบตัวเลขให้เป็นเว้นวรรค เช่น "1 2 3 4 5 6"
  String _formatDigits(String s) {
    final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
    final six = digits.length > 6 ? digits.substring(0, 6) : digits;
    return six.split('').join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFAD0101); // สีแดงในภาพ
    final gold = const Color(0xFFE3BB66); // สีทองกรอบนอก

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ⬅️ กล่องติ๊กอยู่ “นอก” การ์ด
        _TickBox(
          checked: item.selected,
          onTap: () => onChangedSelected(!item.selected),
        ),
        const SizedBox(width: 8),

        // 🟨 กรอบทอง + 🟥 กล่องแดง
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
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 2,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            _formatDigits(
                              item.number.isNotEmpty ? item.number : '123456',
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 20,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.clip,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Text(
                        'ราคา',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${item.price}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'บาท',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
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
        child: Icon(
          Icons.check,
          size: 20,
          color: checked ? Colors.white : Colors.transparent,
        ),
      ),
    );
  }
}
