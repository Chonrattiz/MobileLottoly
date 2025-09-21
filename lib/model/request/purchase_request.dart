// lib/model/request/purchase_request.dart
//สำหรับรวบรวมข้อมูลทั้งหมดที่จำเป็นในการส่งไปยืนยันการซื้อที่เซิร์ฟเวอร์

class PurchaseRequest {
  final int userId;
  final List<int> lottoIds;
  final double totalPrice;

  PurchaseRequest({
    required this.userId,
    required this.lottoIds,
    required this.totalPrice,
  });

  // ฟังก์ชันสำหรับแปลง Object นี้ให้เป็น JSON
  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'lotto_ids': lottoIds,
        'total_price': totalPrice,
      };
}