import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lotto_application/pages/home.dart';
import 'package:lotto_application/pages/navmenu.dart';
import 'package:provider/provider.dart';
import 'package:lotto_application/pages/cart_provider.dart';

class SearchItem {
  // 📦 Model สำหรับรายการแต่ละชุด
  SearchItem({required this.id, required this.price});

  final String id; // 🆔 เลขชุด
  final int price; // 💰 ราคา
}

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => SearchState();
}

class SearchState extends State<SearchPage> {
  //
  final List<SearchItem> _items = [
    // 📋 รายการ mock
    SearchItem(id: '60', price: 80),
    SearchItem(id: '99', price: 80),
    SearchItem(id: '80', price: 80),
  ];

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(
      context,
      listen: false,
    ); // เพิ่มบรรทัดนี้
    final red = const Color(0xFFAD0101); //สีของบาร์ด้านบน

    return Container(
      // ✅ รูปพื้นหลัง
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/bg4.png'), // ✅ รูปพื้นหลัง
          fit: BoxFit.cover, // ให้เต็มจอ
        ),
      ),

      child: Scaffold(
        backgroundColor: Colors.transparent, // 🔹 ทำ Scaffold โปร่งใส
        appBar: AppBar(
          //บาร์ส่วนบน
          backgroundColor: red,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
          ),
          toolbarHeight: 80, //  ความสูงแถบหัว
          title: Text(
            'ค้นหาเลข',
            style: GoogleFonts.itim(
              fontWeight: FontWeight.bold,
              fontSize: 25,
              color: Colors.white,
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
            const SizedBox(height: 10),

            //การ์ดตรงค้นหาหวย
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 20), // ห่างจากด้านบน
                padding: const EdgeInsets.all(30), // ความยาวของด้านล่าง
                decoration: BoxDecoration(
                  color: Color.fromARGB(255, 250, 250, 250), // สี
                  borderRadius: BorderRadius.circular(15), // ความโค้งของมุม
                  // 👉 เส้นขอบ
                  boxShadow: [
                    BoxShadow(
                      // ignore: deprecated_member_use
                      color: Colors.grey.withOpacity(0.5), // สีเงา
                      spreadRadius: 3, // การกระจายของเงา
                      blurRadius: 6, // ความเบลอของเงา
                      offset: Offset(0, 4), // ตำแหน่งเงา (x=0, y=4 → เงาล่าง)
                    ),
                  ],
                ),

                child: Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // จัดตำแหน่งในแนวตั้ง
                  crossAxisAlignment:
                      CrossAxisAlignment.center, // จัดตำแหน่งในแนวนอน
                  mainAxisSize: MainAxisSize.min, // ขนาดตามเนื้อหา ไม่เต็มจอ
                  children: [
                    const Text(
                      "ค้นหาหมายเลขของสลากฯ",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color.from(
                          alpha: 1,
                          red: 0.757,
                          green: 0.22,
                          blue: 0.18,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ช่องกรอก
                    Container(
                      width: 300,
                      height: 40,

                      child: TextField(
                        textAlign: TextAlign.center, // ทำให้ข้อความอยู่ตรงกลาง
                        style: const TextStyle(
                          fontSize: 20, // ขนาดฟอนต์ของข้อความที่ผู้ใช้พิมพ์
                          color: Colors.black,
                          fontWeight:
                              FontWeight.bold, // สามารถปรับน้ำหนักตัวอักษรได้
                        ),
                        decoration: InputDecoration(
                          hintText: 'x x x x x',
                          hintStyle: const TextStyle(
                            fontSize: 20, // ขนาดฟอนต์ของ hintText
                            color: Colors.black54, // สีของ hintText
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

                    // ปุ่ม
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // สุ่มตัวเลข
                        SizedBox(
                          width: 105,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              print("สุ่มตัวเลข Pressed");
                            },
                            child: Text('สุ่มตัวเลข'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                6,
                                110,
                                195,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        // ล้างค่า
                        SizedBox(
                          width: 90,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              print("ล้างค่า Pressed");
                            },
                            child: Text('ล้างค่า'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                196,
                                4,
                                4,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),

                        // ค้นหา
                        SizedBox(
                          width: 100,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              print("ค้นหา Pressed");
                            },
                            child: Text('ค้นหา'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                5,
                                174,
                                2,
                              ),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
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
            ..._items.map(
              //วนลูปหวย
              (item) => SearchItemTile(item: item),
            ),
          ],
        ),
        bottomNavigationBar:
            const MyBottomNavigationBar(), //เรียกบาร์ด้านล่างมา
      ),
    );
  }
}

//class กรอบหวย
class SearchItemTile extends StatelessWidget {
  const SearchItemTile({required this.item});

  final SearchItem item; // ข้อมูลชุด

  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFAD0101); // สีแดงในภาพ
    final gold = const Color(0xFFE3BB66); // สีทองกรอบนอก
    // เพิ่มบรรทัดนี้ใน build method ของ SearchItemTile
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,

      children: [
        Expanded(
          child: Container(
            //กรอบนอกสีทอง
            margin: const EdgeInsets.only(bottom: 10), // ช่องว่างระหว่างรายการ
            padding: const EdgeInsets.all(6), //ความสูงของกรอบนอกสีทอง
            decoration: BoxDecoration(
              color: gold,
              borderRadius: BorderRadius.circular(24), //เรเดี่ยนของกรอบนอก
            ),

            child: Container(
              //กรอบในสีแดง
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              decoration: BoxDecoration(
                color: red,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ข้อมูลภายในกรอบ
                  Text(
                    //แสดงเลขชุด
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
                          height: 40, //ความสูงของกรอบเลข
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black26,
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.centerLeft,
                          child: Center(
                            child: Text(
                              '1 2 3 4 5 6',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 20,
                                color: Color.fromARGB(255, 0, 0, 0),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // ช่องว่างระหว่างกล่องกับราคา
                      const Text(
                        'ราคา',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(width: 8), // ช่องว่างระหว่างราคาdyเลข

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15, //ยาวกรอบขาวราคา
                          vertical: 5, //สูงกรอบขาวราคา
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '${item.price}', //ราคาของหวย
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8), // ช่องว่างระหว่างราคา
                      const Text(
                        'บาท',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),

                      // แก้ไขตรงปุ่มรถเข็น
                      GestureDetector(
                        onTap: () {
                          // โค้ดสำหรับเพิ่มสินค้าลงตะกร้า
                          final newItem = CartItem(
                            id: item.id,
                            price: item.price,
                            number: '123456',
                          );
                          cartProvider.addItem(newItem);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'เพิ่มชุดที่ ${item.id} ลงในตะกร้าแล้ว',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 227, 187, 102),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Icon(
                            Icons.add_shopping_cart,
                            color: Color.fromARGB(255, 255, 255, 255),
                            size: 25,
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
      ],
    );
  }
}
