// lotto_item.dart
class LottoItem {
  final int lottoId;
  final String lottoNumber;
  final String status;
  final double price;
  final int? createdBy;

  LottoItem({
    required this.lottoId,
    required this.lottoNumber,
    required this.status,
    required this.price,
    required this.createdBy,
  });

  List<int> get digits {
    final num = (lottoNumber.length < 6)
        ? ('000000' + lottoNumber).substring(
            ('000000' + lottoNumber).length - 6,
          )
        : lottoNumber.substring(0, 6);
    return num.split('').map((e) => int.tryParse(e) ?? 0).toList();
  }

  factory LottoItem.fromJson(Map<String, dynamic> j) {
    return LottoItem(
      lottoId: (j['lotto_id'] as num).toInt(),
      lottoNumber: j['lotto_number'] as String,
      status: j['status'] as String,
      price: (j['price'] as num).toDouble(),
      createdBy: j['created_by'] == null ? null : (j['created_by'] as num).toInt(),
    );
  }
}