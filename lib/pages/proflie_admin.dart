import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_oracel999/pages/home.dart';
import 'package:app_oracel999/pages/navmenu.dart';
import 'package:provider/provider.dart';
import 'package:app_oracel999/pages/cart_provider.dart';

// 🔹 หน้า SearchPage
class ProflieAdmin extends StatefulWidget {
  final String userId;
  final String username;
  

  const ProflieAdmin({super.key, required this.userId, required this.username});

  @override
  State<ProflieAdmin> createState() => ProflieState();
}

class ProflieState extends State<ProflieAdmin> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final red = const Color.fromARGB(255, 255, 31, 31);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/bg3.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            decoration: const BoxDecoration(
              color: Color.fromRGBO(
                247,
                37,
                21,
                1,
              ), // 👉 ใช้สีแทน backgroundColor
              borderRadius: BorderRadius.vertical(
                bottom: Radius.circular(20), // มนเหมือนเดิม
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black54, // 👉 สีเงา
                  blurRadius: 10, // ความฟุ้งของเงา
                  offset: Offset(0, 3), // ตำแหน่งเงา
                ),
              ],
            ),
            child: AppBar(
              backgroundColor: Colors.transparent, // 👉 โปร่งใส
              elevation: 0, // 👉 ตัดค่าเงาออก ใช้จาก Container แทน
              title: Text(
                'โปรไฟล์',
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
                      builder:
                          (context) => HomeScreen(
                            username: widget.username,
                            userId: widget.userId,
                          ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),

        body: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            const SizedBox(height: 30),
            _buildSearchBox(),
            const SizedBox(height: 30),
          ],
        ),
        
        bottomNavigationBar: MyBottomNavigationBar(
          username: widget.username,
          userId: widget.userId,
        ),
      ),
    );
    
  }

  Widget _buildSearchBox() {
    // 👉 ครอบด้วย SingleChildScrollView เพื่อป้องกันเนื้อหาล้นจอ
    return SingleChildScrollView(
      // 👉 ใช้ Column เพื่อวางการ์ดและปุ่มต่างๆ ในแนวตั้ง
      child: Column(
        children: [
          // 🔹 กล่องข้อมูล (การ์ด) เหมือนเดิม
          Center(
            child: Container(
              margin: const EdgeInsets.all(10),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFB71C1C), // แดงเข้ม
                    Color(0xFFFF5722), // ส้ม
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.amber, // เส้นขอบสีทอง
                  width: 3,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "ข้อมูลของคุณ",
                    style: GoogleFonts.itim(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(255, 255, 255, 1),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ช่อง username
                  TextField(
                    
                    controller: TextEditingController(text: "admin"),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person, color: Color.fromARGB(255, 128, 128, 128)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // ช่อง email
                  TextField(
                    
                    controller: TextEditingController(text: "admin@gmail.com"),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.email, color: Color.fromARGB(255, 128, 128, 128)),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 10),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // ปุ่ม Log Out
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 50,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                          side: const BorderSide(color: Colors.amber, width: 3),
                        ),
                      ),
                      onPressed: () {
                        // TODO: ใส่ function logout
                      },
                      child: const Text(
                        "Log Out",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // --- 👇 ส่วนของปุ่มที่เพิ่มเข้ามานอกการ์ด ---
          const SizedBox(height: 30), // ระยะห่างระหว่างการ์ดกับปุ่ม
          // 🔹 ปุ่ม "รีเซ็ตข้อมูล"
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C), // สีแดงเข้ม
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(
                    color: Colors.amber,
                    width: 3,
                  ), // 👉 ขอบทอง
                ),
              ),
              onPressed: () {
                // TODO: ใส่ function รีเซ็ตข้อมูล
              },
              child: const Text(
                "รีเซ็ตข้อมูล",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),

          const SizedBox(height: 15), // ระยะห่างระหว่างปุ่ม
          // 🔹 ปุ่ม "ลบข้อมูล"
          Center(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB71C1C), // สีแดงเข้ม
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                  side: const BorderSide(
                    color: Colors.amber,
                    width: 3,
                  ), // 👉 ขอบทอง
                ),
              ),
              onPressed: () {
                // TODO: ใส่ function ลบข้อมูล
              },
              child: const Text(
                "ลบข้อมูลทั้งหมด",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
