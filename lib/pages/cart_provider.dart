//หน้าเก็บตระกร้า


import 'package:flutter/material.dart';

class CartItem {
  CartItem({
    required this.id,
    required this.price,
    this.selected = true,
    this.number = '',
  });

  final String id;
  final int price;
  bool selected;
  String number;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(CartItem item) {
  _items.add(item);
  notifyListeners();
}

  void removeItem(String id) {
    _items.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  void toggleItemSelection(String id, bool selected) {
    final item = _items.firstWhere((i) => i.id == id);
    item.selected = selected;
    notifyListeners();
  }

  int get selectedCount => _items.where((e) => e.selected).length;
  int get total => _items
      .where((e) => e.selected)
      .fold(0, (sum, e) => sum + e.price);
}