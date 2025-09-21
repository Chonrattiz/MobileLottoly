// lib/pages/cart_page.dart

import 'package:app_oracel999/model/response/cart_entry.dart';
import 'package:app_oracel999/model/request/purchase_request.dart';
import 'package:app_oracel999/pages/home.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

// --- Imports ที่สะอาดและเป็นระเบียบ ---
import '../api/api_service.dart';
import '../providers/cart_provider.dart';
import 'navmenu.dart';

class CartPage extends StatefulWidget {
  final String userId;
  final String username;

  const CartPage({super.key, required this.userId, required this.username});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  final _apiService = ApiService(); // สร้าง Instance ของ ApiService

  // --- ฟังก์ชันยืนยันการซื้อที่สั้น, สะอาด, และอ่านง่าย ---
  Future<void> _createPurchase() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    if (cart.items.isEmpty) {
      _showSnackbar('ตะกร้าของคุณว่างเปล่า', isError: true);
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1. สร้าง Request Model จากข้อมูลใน Provider
      final request = PurchaseRequest(
        userId: int.parse(widget.userId),
        lottoIds: cart.items.map((entry) => entry.lotto.lottoId).toList(),
        totalPrice: cart.totalPrice,
      );

      // 2. เรียกใช้ ApiService
      await _apiService.createPurchase(request);

      // 3. ถ้าสำเร็จ
      cart.clear(); // ล้างตะกร้า
      if (mounted) {
        Navigator.pop(context); // ปิด loading
        _showSuccessDialog();
      }

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // ปิด loading
        _showSnackbar(e.toString(), isError: true);
      }
    }
  }

  void _showSnackbar(String message, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message.replaceFirst('Exception: ', '')),
          backgroundColor: isError ? Colors.redAccent : Colors.green,
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle_outline, color: Colors.green, size: 60),
        title: Text('สั่งซื้อสำเร็จ', textAlign: TextAlign.center, style: GoogleFonts.itim(fontWeight: FontWeight.bold, fontSize: 22)),
        content: Text('การสั่งซื้อของคุณเสร็จสมบูรณ์แล้ว', textAlign: TextAlign.center, style: GoogleFonts.itim(color: Colors.black54, fontSize: 16)),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomeScreen(username: widget.username, userId: widget.userId)),
              );
            },
            child: Text('กลับสู่หน้าแรก', style: GoogleFonts.itim()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final red = const Color(0xFFAD0101);
    final green = const Color.fromARGB(255, 8, 224, 62);

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/image/bg4.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: red,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
          toolbarHeight: 80,
          title: Text('ตะกร้า', style: GoogleFonts.itim(fontWeight: FontWeight.bold, fontSize: 30, color: Colors.white)),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => HomeScreen(username: widget.username, userId: widget.userId)),
            ),
          ),
        ),
        body: cartProvider.items.isEmpty
            ? Center(child: Text('ตะกร้าของคุณว่างเปล่า', style: GoogleFonts.itim(fontSize: 24, color: Colors.white)))
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                children: [
                  Text('รายการ', style: GoogleFonts.itim(fontWeight: FontWeight.bold, fontSize: 25, color: const Color(0xFFAD0101))),
                  const SizedBox(height: 16),
                  ...cartProvider.items.map(
                    (entry) => _CartItemTile(
                      entry: entry,
                      onRemove: () => cartProvider.removeItem(entry.lotto),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _summaryRow('จำนวน', '${cartProvider.itemCount} รายการ'),
                  const SizedBox(height: 12),
                  _summaryRow('ราคารวม', '${cartProvider.totalPrice.toStringAsFixed(0)} บาท'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: green,
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    onPressed: cartProvider.items.isEmpty ? null : _createPurchase,
                    child: const Text('ดำเนินการสั่งซื้อ', style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
        bottomNavigationBar: MyBottomNavigationBar(
          username: widget.username,
          userId: widget.userId,
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 227, 187, 102),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }
}

// --- Widget แสดงรายการในตะกร้า (ควรย้ายไปไฟล์ Widgets) ---
class _CartItemTile extends StatelessWidget {
  final CartEntry entry;
  final VoidCallback onRemove;

  const _CartItemTile({required this.entry, required this.onRemove});

  Color _getCardColor(String colorType) =>
      colorType == 'yellow' ? const Color.fromARGB(255, 253, 214, 108) : const Color(0xFFAD0101);

  Color _getBorderColor(String colorType) =>
      colorType == 'yellow' ? const Color.fromARGB(255, 252, 184, 35) : const Color(0xFFE3BB66);

  @override
  Widget build(BuildContext context) {
    final lottoItem = entry.lotto;
    final cardColor = _getCardColor(entry.colorType);
    final borderColor = _getBorderColor(entry.colorType);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ชุดที่ ${lottoItem.lottoId}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
                    child: Text(
                      lottoItem.lottoNumber.split('').join(' '),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${lottoItem.price.toStringAsFixed(0)} บาท', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.white, size: 28),
                  onPressed: onRemove,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}