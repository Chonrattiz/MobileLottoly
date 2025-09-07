import 'package:flutter/foundation.dart';
import 'lotto_item.dart';

// --- 1. สร้างคลาสใหม่สำหรับเก็บข้อมูลในตะกร้าโดยเฉพาะ ---
// คลาสนี้จะเก็บทั้งข้อมูลสลาก (LottoItem) และชนิดของสี (colorType)
class CartEntry {
  final LottoItem lotto;
  final String colorType; // เช่น 'red' หรือ 'yellow'

  CartEntry({required this.lotto, required this.colorType});
}

// 🛒 Provider สำหรับจัดการตะกร้า
class CartProvider with ChangeNotifier {
  // 2. เปลี่ยน: ให้ List เก็บข้อมูลชนิด CartEntry แทน
  final List<CartEntry> _items = [];

  // Getter สำหรับเข้าถึงรายการ (คืนค่าเป็น CartEntry)
  List<CartEntry> get items => _items;

  // Getter สำหรับนับจำนวน (ไม่ต้องแก้ไข)
  int get itemCount => _items.length;

  // Getter สำหรับรวมราคา (แก้ไขเล็กน้อยให้คำนวณจาก entry.lotto)
  double get totalPrice {
    return _items.fold(0.0, (sum, entry) => sum + entry.lotto.price);
  }

  // 3. อัปเกรด: ฟังก์ชันตรวจสอบของในตะกร้า (ยังคงรับ LottoItem เพื่อความสะดวก)
  bool isItemInCart(LottoItem lotto) {
    return _items.any((entry) => entry.lotto.lottoId == lotto.lottoId);
  }

  // 4. อัปเกรด: ฟังก์ชันเพิ่มของลงตะกร้า (เปลี่ยนให้รับ CartEntry)
  void addItem(CartEntry entry) {
    // ตรวจสอบจากข้อมูล lotto ที่อยู่ใน entry
    if (!isItemInCart(entry.lotto)) {
      _items.add(entry);
      notifyListeners();
    }
  }

  // 5. อัปเกรด: ฟังก์ชันลบของออกจากตะกร้า (ยังคงรับ LottoItem เพื่อความสะดวก)
  void removeItem(LottoItem lotto) {
    _items.removeWhere((entry) => entry.lotto.lottoId == lotto.lottoId);
    notifyListeners();
  }

  // ฟังก์ชันล้างตะกร้า (ไม่ต้องแก้ไข)
  void clear() {
    _items.clear();
    notifyListeners();
  }
}

