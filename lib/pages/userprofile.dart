import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:app_oracel999/pages/home.dart';
import 'package:app_oracel999/pages/login.dart';
import 'package:app_oracel999/pages/navmenu.dart';
import 'profile_models.dart'; // <<< import โมเดลที่เราสร้าง

// 1. เปลี่ยนเป็น StatefulWidget
class ProfilePage extends StatefulWidget {
  final String userId;
  final String username;

  const ProfilePage({
    super.key,
    required this.userId,
    required this.username,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // 2. สร้าง State Variables
  UserProfile? _userProfile;
  List<PurchasedLotto> _purchasedLottos = [];
  bool _isLoading = true;
  String? _errorMessage;

  // Controller สำหรับแสดงข้อมูลในช่อง Text Field
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  // 3. ฟังก์ชันดึงข้อมูลจาก API ทั้ง 2 เส้น
  Future<void> _fetchProfileData() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final profileUrl = Uri.parse('http://192.168.6.1:8080/profile?user_id=${widget.userId}');
      final purchasesUrl = Uri.parse('http://192.168.6.1:8080/users/purchases?user_id=${widget.userId}');

      final responses = await Future.wait([
        http.get(profileUrl),
        http.get(purchasesUrl),
      ]);

      if (responses[0].statusCode == 200) {
        _userProfile = UserProfile.fromJson(jsonDecode(responses[0].body));
        // อัปเดตข้อมูลใน Controller
        _usernameController.text = _userProfile!.username;
        _emailController.text = _userProfile!.email;
      } else {
        throw Exception('ไม่สามารถโหลดข้อมูลโปรไฟล์ได้');
      }

      if (responses[1].statusCode == 200) {
        final data = jsonDecode(responses[1].body);
        final List<dynamic> itemsJson = data['data'] ?? [];
        _purchasedLottos = itemsJson.map((json) => PurchasedLotto.fromJson(json)).toList();
      } else {
        throw Exception('ไม่สามารถโหลดรายการสั่งซื้อได้');
      }

    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      if (mounted) {
        setState(() { _isLoading = false; });
      }
    }
  }
  
  // 4. ฟังก์ชันสำหรับ Log Out
  void _logout() {
    // กลับไปหน้า Login และล้างทุกหน้าก่อนหน้าออกจาก Stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false, // เงื่อนไขนี้จะลบทุก Route
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text('โปรไฟล์', style: GoogleFonts.itim(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        centerTitle: false,
        backgroundColor: const Color(0xFFE4222C),
        elevation: 0,
        toolbarHeight: 80.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () { // แก้ไข: ลบ onPressed ที่ซ้อนกันออก
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!))
              : _buildContent(), // แยก Content ออกมา
      bottomNavigationBar: MyBottomNavigationBar(
        username: widget.username,
        userId: widget.userId,
      ),
    );
  }
  
  // Widget สำหรับแสดงเนื้อหาหลัก
  Widget _buildContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileCard(),
            const SizedBox(height: 24),
            _buildPurchasesCard(),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }

  // Widget สำหรับการ์ดข้อมูลโปรไฟล์
  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Text('ข้อมูลของคุณ', style: GoogleFonts.itim(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInputField(Icons.person, 'Username', _usernameController),
          const SizedBox(height: 16),
          _buildInputField(Icons.email, 'Email', _emailController),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  // Widget สำหรับการ์ดรายการสั่งซื้อ
  Widget _buildPurchasesCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Text('รายการสั่งซื้อ', style: GoogleFonts.itim(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          if (_purchasedLottos.isEmpty)
            const Text('คุณยังไม่มีรายการสั่งซื้อ', style: TextStyle(color: Colors.white70))
          else
            ..._purchasedLottos.map((item) => _buildOrderItem(item)),
        ],
      ),
    );
  }

  // --- Widgets ย่อยสำหรับสร้าง UI ---
  
  BoxDecoration _buildCardDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.red[800]!, Colors.orange[800]!],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      borderRadius: BorderRadius.circular(10),
      boxShadow: [
        BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3)),
      ],
      border: Border.all(color: const Color.fromARGB(255, 255, 215, 0), width: 5),
    );
  }

  Widget _buildInputField(IconData icon, String hintText, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color.fromARGB(255, 255, 215, 0), width: 5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: TextField(
        controller: controller,
        readOnly: true, // ทำให้แก้ไขไม่ได้
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          hintStyle: GoogleFonts.itim(color: Colors.grey),
        ),
      ),
    );
  }

   Widget _buildLogoutButton() {
     return Container(
       width: 250,
       decoration: BoxDecoration(
         border: Border.all(color: const Color.fromARGB(255, 255, 215, 0), width: 3),
         borderRadius: BorderRadius.circular(30),
         gradient: LinearGradient(colors: [Colors.red[800]!, Colors.red[900]!]),
         boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), spreadRadius: 1, blurRadius: 5, offset: const Offset(0, 3))],
       ),
       child: ElevatedButton(
         onPressed: _logout, // <<< เรียกฟังก์ชัน Log Out
         style: ElevatedButton.styleFrom(
           backgroundColor: Colors.transparent,
           foregroundColor: Colors.white,
           minimumSize: const Size(double.infinity, 50),
           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
           elevation: 0,
         ),
         child: Text('Log Out', style: GoogleFonts.itim(fontSize: 16, fontWeight: FontWeight.bold)),
       ),
     );
   }

  Widget _buildOrderItem(PurchasedLotto item) {
    final statusColor = _getStatusColor(item.status);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFAD0101),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color.fromARGB(255, 255, 215, 0), width: 6),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('รหัสสลาก: ${item.lottoId}', style: GoogleFonts.itim(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5)),
                  child: Text(
                    item.lottoNumber.split('').join(' '),
                    style: GoogleFonts.itim(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(5)),
            child: Text(
              item.status,
              style: GoogleFonts.itim(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
  
  // ฟังก์ชันช่วยเปลี่ยนสีตามสถานะ
  Color _getStatusColor(String status) {
    switch (status) {
      case 'ถูก':
        return Colors.green;
      case 'ไม่ถูก':
        return Colors.red;
      case 'ยัง':
      default:
        return Colors.grey;
    }
  }
}
