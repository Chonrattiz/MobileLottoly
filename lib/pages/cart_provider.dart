import 'package:flutter/material.dart';

// 🧾 Model ของสินค้าในตะกร้า
class CartItem {
  CartItem({
    required this.id,
    required this.price,
    required this.colorType, // เพิ่ม final String colorType;
    this.selected = true,
    this.number = '',
  });

  final String id;
  final int price;
  final String colorType; // เพิ่มตัวแปรนี้เพื่อเก็บสี
  bool selected;
  String number;
}

// 🛒 Provider สำหรับจัดการตะกร้า
class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  // ➕ เพิ่มสินค้า
  void addItem(CartItem item) {
    if (!_items.any((e) => e.id == item.id)) {
      _items.add(item);
      notifyListeners();
    }
  }

  // ❌ ลบสินค้า
  void removeItem(String id) {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
  }

  // 🔄 toggle เลือก/ไม่เลือก
  void toggleItem(String id, bool value) {
    final item = _items.firstWhere((e) => e.id == id);
    item.selected = value;
    notifyListeners();
  }

  // ✏️ อัปเดตเลข
  void updateNumber(String id, String number) {
    final item = _items.firstWhere((e) => e.id == id);
    item.number = number;
    notifyListeners();
  }

  // ✅ ตรวจสอบว่าสินค้าอยู่ในตะกร้าหรือยัง
  bool isItemInCart(String id) {
    return _items.any((e) => e.id == id);
  }

  // 🗑 ล้างตะกร้า
  void clear() {
    _items.clear();
    notifyListeners();
  }

  int get selectedCount => _items.where((e) => e.selected).length;
  int get total =>
      _items.where((e) => e.selected).fold(0, (sum, e) => sum + e.price);
}
