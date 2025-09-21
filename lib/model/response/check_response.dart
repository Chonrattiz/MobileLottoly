// lib/model/response/reward_models.dart

class CurrentReward {
  final int prizeTier;
  final double prizeMoney;
  final String lottoNumber;

  CurrentReward({
    required this.prizeTier,
    required this.prizeMoney,
    required this.lottoNumber,
  });

  factory CurrentReward.fromJson(Map<String, dynamic> json) {
    return CurrentReward(
      prizeTier: json['prize_tier'] ?? 0,
      prizeMoney: (json['prize_money'] as num?)?.toDouble() ?? 0,
      lottoNumber: json['lotto_number'] ?? '',
    );
  }
}

// --- Model สำหรับรับผลการตรวจสลาก ---
class CheckResult {
  final bool isWinner;
  final String message;
  final String lottoNumber;
  final double prizeMoney;
  final int prizeTier;

  CheckResult({
    required this.isWinner,
    required this.message,
    required this.lottoNumber,
    required this.prizeMoney,
    required this.prizeTier,
  });

  factory CheckResult.fromJson(Map<String, dynamic> json) {
    //json มาแปลงร่างให้เป็นข้อมูลที่พร้อมใช้งาน แล้วนำไปเก็บไว้เพื่อรอแสดงผลบนหน้าจอ
    return CheckResult(
      isWinner: json['is_winner'] ?? false,
      message: json['message'] ?? 'เกิดข้อผิดพลาด',
      lottoNumber: json['lotto_number'] ?? '',
      prizeMoney: (json['prize_money'] as num?)?.toDouble() ?? 0.0,
      prizeTier: json['prize_tier'] ?? 0,
    );
  }
}
