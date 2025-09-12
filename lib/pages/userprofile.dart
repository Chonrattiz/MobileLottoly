// lib/pages/profile_page.dart

import 'package:app_oracel999/pages/home.dart';
import 'package:app_oracel999/pages/login.dart';
import 'package:app_oracel999/pages/profile_models.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// --- Imports ที่สะอาดและเป็นระเบียบ ---
import '../api/api_service.dart';
import 'navmenu.dart';

class ProfilePage extends StatefulWidget {
  final String userId;
  final String username;

  const ProfilePage({super.key, required this.userId, required this.username});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _apiService = ApiService();
  late Future<UserProfile> _userProfileFuture;
  late Future<List<PurchasedLotto>> _purchasesFuture;

  @override
  void initState() {
    super.initState();
    // 1. เรียก API ทั้งสองเส้นทางแค่ครั้งเดียวตอนเปิดหน้า
    _userProfileFuture = _apiService.fetchUserProfile(widget.userId);
    _purchasesFuture = _apiService.fetchUserPurchases(widget.userId);
  }

  void _logout() {
    // กลับไปหน้า Login และล้างทุกหน้าก่อนหน้าออกจาก Stack
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/bg4.png'), // รูปพื้นหลัง
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('โปรไฟล์', style: GoogleFonts.itim(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
          centerTitle: false,
          backgroundColor: const Color(0xFFED10400), // ทำให้ AppBar โปร่งใส
          elevation: 0,
          toolbarHeight: 80.0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
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
        // 2. ใช้ FutureBuilder ตัวแรกสำหรับโหลดข้อมูลโปรไฟล์
        body: FutureBuilder<UserProfile>(
          future: _userProfileFuture,
          builder: (context, userSnapshot) {
            // --- สถานะ: กำลังโหลด ---
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            // --- สถานะ: เกิดข้อผิดพลาด ---
            if (userSnapshot.hasError) {
              return Center(child: Text('เกิดข้อผิดพลาดในการโหลดโปรไฟล์: ${userSnapshot.error}'));
            }
            // --- สถานะ: ไม่มีข้อมูล ---
            if (!userSnapshot.hasData) {
              return const Center(child: Text('ไม่พบข้อมูลโปรไฟล์'));
            }

            final userProfile = userSnapshot.data!;

            // --- เมื่อโหลดโปรไฟล์เสร็จแล้ว ให้แสดงเนื้อหาหลัก ---
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _userProfileFuture = _apiService.fetchUserProfile(widget.userId);
                  _purchasesFuture = _apiService.fetchUserPurchases(widget.userId);
                });
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildProfileCard(userProfile),
                      const SizedBox(height: 24),
                      // 3. ใช้ FutureBuilder ตัวที่สองสำหรับโหลดประวัติการซื้อ
                      _buildPurchasesSection(),
                      const SizedBox(height: 40.0),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        bottomNavigationBar: MyBottomNavigationBar(
          username: widget.username,
          userId: widget.userId,
        ),
      ),
    );
  }

  // --- โค้ดส่วน UI ที่เหลือ (Widgets) ---

  Widget _buildProfileCard(UserProfile profile) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: _buildCardDecoration(),
      child: Column(
        children: [
          Text('ข้อมูลของคุณ', style: GoogleFonts.itim(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildInputField(Icons.person, TextEditingController(text: profile.username)),
          const SizedBox(height: 16),
          _buildInputField(Icons.email, TextEditingController(text: profile.email)),
          const SizedBox(height: 24),
          _buildLogoutButton(),
        ],
      ),
    );
  }

  Widget _buildPurchasesSection() {
    return FutureBuilder<List<PurchasedLotto>>(
      future: _purchasesFuture,
      builder: (context, snapshot) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: _buildCardDecoration(),
          child: Column(
            children: [
              Text('รายการสั่งซื้อ', style: GoogleFonts.itim(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              if (snapshot.connectionState == ConnectionState.waiting)
                const CircularProgressIndicator(color: Colors.white),
              if (snapshot.hasError)
                Text('ไม่สามารถโหลดประวัติการซื้อได้', style: const TextStyle(color: Colors.yellow)),
              if (snapshot.hasData)
                if (snapshot.data!.isEmpty)
                  const Text('คุณยังไม่มีรายการสั่งซื้อ', style: TextStyle(color: Colors.white70))
                else
                  // ใช้ ListView.separated เพื่อเพิ่มเส้นคั่นระหว่างรายการ
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) => _buildOrderItem(snapshot.data![index]),
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                  ),
            ],
          ),
        );
      },
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
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          spreadRadius: 1,
          blurRadius: 5,
          offset: const Offset(0, 3),
        ),
      ],
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _logout,
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

  Widget _buildOrderItem(PurchasedLotto item) {
    final statusColor = _getStatusColor(item.status);
    final statusText = _getStatusText(item.status);
    final statusTextColor = _getStatusTextColor(item.status);

    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: const Color(0xFFB71C1C),
        border: Border.all(color: const Color(0xFFE3BB66), width: 3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ชุดที่ ${item.lottoId}',
                style: GoogleFonts.itim(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: GoogleFonts.itim(color: statusTextColor, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.lottoNumber.split('').join(' '),
              textAlign: TextAlign.center,
              style: GoogleFonts.itim(fontWeight: FontWeight.bold, fontSize: 28, color: Colors.black87, letterSpacing: 2.0),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ถูก':
        return const Color(0xFF4CAF50);
      case 'ไม่ถูก':
        return const Color(0xFFF44336);
      case 'ยัง':
      default:
        return Colors.white;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'ถูก':
      case 'ไม่ถูก':
        return Colors.white;
      case 'ยัง':
      default:
        return Colors.black54;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'ถูก':
        return 'ถูกรางวัล';
      case 'ไม่ถูก':
        return 'ไม่ถูกรางวัล';
      case 'ยัง':
      default:
        return 'ยังไม่ประกาศ';
    }
  }
}