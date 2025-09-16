// draft_update_item.dart
class DraftUpdateItem {
  final int lottoId;
  final String oldNumber;
  final String newNumber;

  DraftUpdateItem({
    required this.lottoId,
    required this.oldNumber,
    required this.newNumber,
  });

  factory DraftUpdateItem.fromJson(Map<String, dynamic> j) {
    return DraftUpdateItem(
      lottoId: (j['lotto_id'] as num).toInt(),
      oldNumber: (j['lotto_number_old'] ?? '').toString(),
      newNumber: (j['lotto_number_new'] ?? '').toString(),
    );
  }

  List<int> get digits =>
      newNumber
          .padLeft(6, '0')
          .substring(0, 6)
          .split('')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
}
