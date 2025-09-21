class RewardData {
  final int? lottoId;
  final int prizeTier;
  final String lottoNumber;
  final double prizeMoney;

  RewardData({
    this.lottoId,
    required this.prizeTier,
    required this.lottoNumber,
    required this.prizeMoney,
  });

  // Factory สำหรับข้อมูลรางวัลปัจจุบัน
  factory RewardData.fromJson(Map<String, dynamic> json) {
    return RewardData(
      prizeTier: json['prize_tier'],
      lottoNumber: json['lotto_number'],
      prizeMoney: (json['prize_money'] as num).toDouble(),
    );
  }

  // Factory สำหรับ Preview (ดึง lotto_id ด้วย)
  factory RewardData.fromPreviewJson(Map<String, dynamic> json) {
    return RewardData(
      lottoId: json['winning_lotto']['lotto_id'],
      prizeTier: json['prize_tier'],
      lottoNumber: json['winning_lotto']['lotto_number'],
      prizeMoney: (json['prize_money'] as num).toDouble(),
    );
  }
}
