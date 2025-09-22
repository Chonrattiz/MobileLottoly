// navmenu.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_oracel999/pages/cart_page.dart';
import 'package:app_oracel999/pages/check.dart';
import 'package:app_oracel999/pages/search_page.dart';
import 'package:app_oracel999/pages/wallet_page.dart';

class MyBottomNavigationBar extends StatelessWidget {
  // 1. เพิ่มตัวแปร userId เพื่อรับค่าเข้ามาใน Widget นี้
  final String userId;
  final String username;

  // 2. แก้ไข constructor ให้รับ userId เข้ามาตอนสร้าง Widget
  const MyBottomNavigationBar({
    super.key,
    required this.userId,
    required this.username,// กำหนดให้ต้องส่ง userId มาเสมอ
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.red[800],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                // 3. ส่ง userId ไปยัง WalletPage (และลบ const ออก)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => WalletPage(username: username, userId: userId)),
                );
              },
              child: _buildNavItem(
                icon: Icons.account_balance_wallet,
                label: 'กระเป๋า',
                color: Colors.green,
              ),
            ),
            GestureDetector(
              onTap: () {
                // 3. ส่ง userId ไปยัง LotteryCheckerPage (และลบ const ออก)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => LotteryCheckerPage(username: username, userId: userId),
                  ),
                );
              },
              child: _buildNavItem(
                icon: Icons.verified,
                label: 'ตรวจรางวัล',
                color: Colors.blue,
              ),
            ),
            GestureDetector(
              onTap: () {
                // 3. ส่ง userId ไปยัง SearchPage (และลบ const ออก)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => SearchPage(username: username, userId: userId)),
                );
              },
              child: _buildNavItem(
                icon: Icons.search,
                label: 'ค้นหาเลข',
                color: Colors.brown,
              ),
            ),
            GestureDetector(
              onTap: () {
                // 3. ส่ง userId ไปยัง CartPage (และลบ const ออก)
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => CartPage(username: username, userId: userId)),
                );
              },
              child: _buildNavItem(
                icon: Icons.shopping_cart,
                label: 'ตะกร้า',
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // สร้าง Widget สำหรับแต่ละไอเทมในเมนู (ไม่ต้องแก้ไขส่วนนี้)
  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.itim(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
