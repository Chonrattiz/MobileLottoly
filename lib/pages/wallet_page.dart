import 'package:flutter/material.dart';
import 'package:lotto_application/pages/home.dart';
import 'package:lotto_application/pages/navmenu.dart';
import 'package:google_fonts/google_fonts.dart';

class WalletPage extends StatefulWidget {
  const WalletPage({super.key});

  @override
  State<WalletPage> createState() => WalletState();
}

class WalletState extends State<WalletPage> {
  @override
  Widget build(BuildContext context) {
    final red = const Color(0xFFAD0101); //สีของบาร์ด้านบน
    final green = const Color.fromARGB(255, 1, 173, 10);
    final gold = const Color(0xFFE3BB66); // สีทองกรอบนอก

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
          title: const Text(
            'กระเป๋า',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
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
          children: [
            const SizedBox(height: 30),
            Container(
              // กรอบนอกสีทอง
              width: 350, // ✅ ขนาดวงกลมใหญ่ขึ้น
              height: 350,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: gold,
                shape: BoxShape.circle, // ✅ วงกลม
              ),

              child: Container(
                // กรอบในสีเขียว
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                decoration: BoxDecoration(
                  color: green,
                  shape: BoxShape.circle, // ✅ วงกลม
                ),

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'ยอดเงิน',
                      style: GoogleFonts.itim(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'คงเหลือ',
                      style: GoogleFonts.itim(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '5,000,000',
                      style: GoogleFonts.itim(
                        color: Colors.white,
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar:
            const MyBottomNavigationBar(), //เรียกบาร์ด้านล่างมา
      ),
    );
  }
}
