import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePageUI extends StatelessWidget {
  const ProfilePageUI({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/bg3.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
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
          backgroundColor: const Color.fromARGB(255, 224, 7, 7),
          elevation: 0, // ตั้งเป็น 0 เพราะเราจะสร้างเงาเอง
          toolbarHeight: 80.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          shape: const RoundedRectangleBorder(
            // ทำให้บาร์มีขอบมน
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30), // ปรับค่าตามความมนที่ต้องการ
            ),
            side: BorderSide(
              // เพิ่มเส้นขอบด้านล่าง
              color: Color.fromARGB(255, 0, 0, 0), // สีทอง
              width: 1, // ความหนาของเส้นขอบ
            ),
          ),
          bottom: PreferredSize(
            // ใช้ PreferredSize เพื่อเพิ่ม BoxShadow ที่ด้านล่าง
            preferredSize: const Size.fromHeight(
              0.0,
            ), // ไม่เพิ่มความสูงเพิ่มเติม
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5), // สีของเงา
                    spreadRadius: 3, // การกระจายของเงา
                    blurRadius: 7, // ความเบลอของเงา
                    offset: const Offset(0, 3), // ตำแหน่งเงา (X, Y)
                  ),
                ],
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _buildProfileCard(),
                _buildActionButtons(), // เพิ่มปุ่มใหม่ตรงนี้
                const SizedBox(height: 40.0)
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Text(
            'ข้อมูลของคุณ',
            style: GoogleFonts.itim(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildInputField(Icons.person, "username123"),
          const SizedBox(height: 16),
          _buildInputField(Icons.email, "username@mail.com"),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  // Widget ใหม่สำหรับปุ่ม "รีเซ็ตข้อมูล" และ "ลบข้อมูลทั้งหมด"
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          _buildActionButton('รีเซ็ตข้อมูล'),
          const SizedBox(height: 16),
          _buildActionButton('ลบข้อมูลทั้งหมด'),
        ],
      ),
    );
  }

  // Helper Widget สำหรับสร้างปุ่มแต่ละปุ่มเพื่อลดการเขียนโค้ดซ้ำ
  Widget _buildActionButton(String text) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 255, 215, 0),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(30),
        color: const Color(0xFFB71C1C),
      ),
      child: ElevatedButton(
        onPressed: () {
          // ใส่โค้ดสำหรับปุ่มที่นี่
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          text,
          style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.red[800]!, Colors.orange[800]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: const Color.fromARGB(255, 255, 215, 0),
        width: 5,
      ),
    );
  }

  Widget _buildInputField(IconData icon, String text) {
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
        controller: TextEditingController(text: text),
        readOnly: true,
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.grey),
          hintStyle: GoogleFonts.itim(color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: 250,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color.fromARGB(255, 255, 215, 0),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(colors: [Colors.red[800]!, Colors.red[900]!]),
      ),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 0,
        ),
        child: Text(
          'Log Out',
          style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
