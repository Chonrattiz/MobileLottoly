// lotto_item.dart
class LottoItem {
  final int lottoId;
  final String lottoNumber;   // ใช้ชื่อนี้ให้ตรงกับ key JSON
  final String status;
  final double price;
  final int? createdBy;

  LottoItem({
    required this.lottoId,
    required this.lottoNumber,
    required this.status,
    required this.price,
    this.createdBy,
  });

  /// คืนค่าเป็น list ของตัวเลขแยกออกมา เช่น "123456" -> [1,2,3,4,5,6]
  List<int> get digits {
    final num = (lottoNumber.length < 6)
        ? ('000000' + lottoNumber).substring(
            ('000000' + lottoNumber).length - 6,
          )
        : lottoNumber.substring(0, 6);
    return num.split('').map((e) => int.tryParse(e) ?? 0).toList();
  }

  /// Factory constructor สำหรับสร้าง LottoItem object จากข้อมูล JSON
  factory LottoItem.fromJson(Map<String, dynamic> json) {
    return LottoItem(
      lottoId: (json['lotto_id'] as num?)?.toInt() ?? 0,
      lottoNumber: json['lotto_number'] as String? ?? '',
      status: json['status'] as String? ?? 'sell',
      price: (json['price'] as num?)?.toDouble() ?? 80.0,
      createdBy: (json['created_by'] as num?)?.toInt(),
    );
  }

  /// แปลง object เป็น JSON (เผื่อใช้ตอน POST/PUT)
  Map<String, dynamic> toJson() {
    return {
      'lotto_id': lottoId,
      'lotto_number': lottoNumber,
      'status': status,
      'price': price,
      'created_by': createdBy,
    };
  }
}
