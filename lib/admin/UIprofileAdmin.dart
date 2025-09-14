import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:myproject/api/api_service.dart';
import 'package:myproject/pages/login.dart';
import 'package:myproject/services/api_service.dart';
// แก้ไข: เปลี่ยนที่อยู่การ import ให้ถูกต้อง
import 'package:myproject/model/response/profile_models.dart';

class ProfilePageUI extends StatefulWidget {
  final String userId;
  final String role;

  const ProfilePageUI({super.key, required this.userId, required this.role});

  @override
  State<ProfilePageUI> createState() => _ProfilePageUIState();
}

class _ProfilePageUIState extends State<ProfilePageUI> {
  late Future<UserProfile> _futureProfile;
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isDeleting = false;
  final ApiService _apiService = ApiService(); // สร้าง instance ของ ApiService

  @override
  void initState() {
    super.initState();
    // แก้ไข: เรียกใช้ service จาก _apiService แทน
    _futureProfile = _apiService.fetchProfile(widget.userId);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // ฟังก์ชันสำหรับเตรียมข้อมูลและ UI ก่อนเรียกใช้ service
  Future<void> _confirmAndDeleteAllData() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ยืนยันการลบข้อมูล', style: GoogleFonts.itim()),
          content: Text(
            'คุณแน่ใจหรือไม่ว่าต้องการลบข้อมูลทั้งหมด (ยกเว้นผู้ใช้ที่เป็น Admin)? การกระทำนี้ไม่สามารถย้อนกลับได้',
            style: GoogleFonts.itim(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('ยกเลิก', style: GoogleFonts.itim()),
              onPressed: () {
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text('ยืนยันลบ', style: GoogleFonts.itim()),
              onPressed: () {
                Navigator.of(context).pop(true);
              },
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _deleteAllData();
    }
  }

  // ฟังก์ชันนี้จะเรียก service และจัดการสถานะ UI
  Future<void> _deleteAllData() async {
    setState(() {
      _isDeleting = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('กำลังลบข้อมูลทั้งหมด...', style: GoogleFonts.itim()),
        backgroundColor: Colors.blue,
      ),
    );

    try {
      // แก้ไข: เรียกใช้ service จาก _apiService แทน
      await _apiService.deleteAllData(widget.userId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('ลบข้อมูลทั้งหมดสำเร็จ!', style: GoogleFonts.itim()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e', style: GoogleFonts.itim()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDeleting = false;
        });
      }
    }
  }

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
          elevation: 0,
          toolbarHeight: 80.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
            side: BorderSide(color: Color.fromARGB(255, 0, 0, 0), width: 1),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(0.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
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
                FutureBuilder<UserProfile>(
                  future: _futureProfile,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(50.0),
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'เกิดข้อผิดพลาด:\n${snapshot.error}',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.itim(
                            color: Colors.yellow,
                            fontSize: 16,
                          ),
                        ),
                      );
                    } else if (snapshot.hasData) {
                      _usernameController.text = snapshot.data!.username;
                      _emailController.text = snapshot.data!.email;
                      return _buildProfileCard();
                    } else {
                      return const Center(
                        child: Text(
                          'ไม่พบข้อมูล',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                  },
                ),
                _buildActionButtons(),
                const SizedBox(height: 40.0),
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
          _buildInputField(Icons.person, _usernameController),
          const SizedBox(height: 16),
          _buildInputField(Icons.email, _emailController),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildActionButton(
            text: 'ลบข้อมูลทั้งหมด',
            onPressed: _isDeleting ? null : _confirmAndDeleteAllData,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({required String text, VoidCallback? onPressed}) {
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
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.withOpacity(0.5),
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

  Widget _buildInputField(IconData icon, TextEditingController controller) {
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
        controller: controller,
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
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
            (Route<dynamic> route) => false,
          );
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
          'Log Out',
          style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
