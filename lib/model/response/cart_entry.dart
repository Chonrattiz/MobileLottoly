// lib/model/cart_entry.dart

import 'package:app_oracel999/model/response/lotto_item.dart';

// คลาสนี้จะเก็บทั้งข้อมูลสลาก (LottoItem) และชนิดของสี (colorType)
class CartEntry {
  final LottoItem lotto;
  final String colorType; // เช่น 'red' หรือ 'yellow'

  CartEntry({required this.lotto, required this.colorType});
}