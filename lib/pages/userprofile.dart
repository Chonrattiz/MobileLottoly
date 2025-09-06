import 'package:flutter/material.dart';
import 'package:myproject/pages/home.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/pages/navmenu.dart';

class LotteryProfile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'โปรไฟล์',
          style: GoogleFonts.itim(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFFE4222C),
        elevation: 0,
        toolbarHeight: 80.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => const HomeScreen(username: ''),
              ),
            );
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  // ส่วนข้อมูลของคุณ
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[800]!, Colors.orange[800]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: const Color.fromARGB(255, 255, 215, 0),
                        width: 5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ข้อมูลของคุณ',
                          style: GoogleFonts.itim(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildInputField(Icons.person, 'Username'),
                        SizedBox(height: 16),
                        _buildInputField(Icons.email, 'Email'),
                        SizedBox(height: 24),
                        // ปุ่ม Log Out
                        Container(
                          width: 250,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color.fromARGB(255, 255, 215, 0),
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(30),
                            gradient: LinearGradient(
                              colors: [Colors.red[800]!, Colors.red[900]!],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 1,
                                blurRadius: 5,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              'Log Out',
                              style: GoogleFonts.itim(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24),
                  // ส่วนรายการสั่งซื้อ
                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red[800]!, Colors.orange[800]!],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: const Color.fromARGB(255, 255, 215, 0),
                        width: 5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'รายการสั่งซื้อ',
                          style: GoogleFonts.itim(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16),
                        _buildOrderItem(
                          'ชุดที่ 3',
                          '9 2 3 6 5 4',
                          'ยังไม่ประกาศ',
                          Colors.white,
                          Colors.black,
                        ),
                        _buildOrderItem(
                          'ชุดที่ 10',
                          '9 2 3 7 4 2',
                          'ถูกรางวัล',
                          Colors.green,
                          Colors.white,
                        ),
                        _buildOrderItem(
                          'ชุดที่ 8',
                          '5 5 1 6 5 4',
                          'ไม่ถูกรางวัล',
                          Colors.red,
                          Colors.white,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 40.0),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const MyBottomNavigationBar(),
    );
  }

  // ฟังก์ชันสร้างช่องใส่ข้อมูล
  Widget _buildInputField(IconData icon, String hintText) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: const Color.fromARGB(255, 255, 215, 0),
          width: 5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          hintStyle: GoogleFonts.itim(color: Colors.grey),
        ),
      ),
    );
  }

  // ฟังก์ชันสร้างรายการสั่งซื้อ
  Widget _buildOrderItem(
    String title,
    String numbers,
    String status,
    Color statusColor,
    Color textColor,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFAD0101),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: const Color.fromARGB(255, 255, 215, 0), // เพิ่มกรอบสีทอง
          width: 6, // กำหนดความหนาของกรอบ
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.itim(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                // เปลี่ยนการแสดงผลตัวเลขเป็นกล่องเดียว
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    numbers,
                    style: GoogleFonts.itim(
                      fontWeight: FontWeight.bold,
                      fontSize: 24, // สามารถเปลี่ยนตัวเลขนี้เพื่อปรับขนาดได้
                      color: const Color.fromARGB(255, 0, 0, 0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              status,
              style: GoogleFonts.itim(
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
