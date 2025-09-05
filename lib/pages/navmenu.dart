import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyBottomNavigationBar extends StatelessWidget {
  const MyBottomNavigationBar({super.key});

  // สร้าง Widget สำหรับแต่ละไอเทมในเมนู
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
            _buildNavItem(
              icon: Icons.account_balance_wallet,
              label: 'กระเป๋า',
              color: Colors.green,
            ),
            _buildNavItem(
              icon: Icons.verified,
              label: 'ตรวจรางวัล',
              color: Colors.blue,
            ),
            _buildNavItem(
              icon: Icons.search,
              label: 'ค้นหาเลข',
              color: Colors.brown,
            ),
            _buildNavItem(
              icon: Icons.shopping_cart,
              label: 'ตะกร้า',
              color: Colors.purple,
            ),
          ],
        ),
      ),
    );
  }
}
