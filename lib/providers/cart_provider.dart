// lib/providers/cart_provider.dart

import 'package:app_oracel999/model/response/cart_entry.dart';
import 'package:flutter/material.dart';

import '../model/response/lotto_item.dart';

// Provider สำหรับจัดการตะกร้า
class CartProvider with ChangeNotifier {
  final List<CartEntry> _items = [];

  List<CartEntry> get items => _items;

  int get itemCount => _items.length;

  double get totalPrice {
    return _items.fold(0.0, (sum, entry) => sum + entry.lotto.price);
  }

  bool isItemInCart(LottoItem lotto) {
    return _items.any((entry) => entry.lotto.lottoId == lotto.lottoId);
  }

  void addItem(CartEntry entry) {
    if (!isItemInCart(entry.lotto)) {
      _items.add(entry);
      notifyListeners();
    }
  }

  void removeItem(LottoItem lotto) {
    _items.removeWhere((entry) => entry.lotto.lottoId == lotto.lottoId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}