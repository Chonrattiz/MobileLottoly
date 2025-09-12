// lib/model/response/reward_models.dart

// --- Model สำหรับรับข้อมูลผลรางวัลล่าสุด ---
class LatestRewards {
  final List<String> prize1;
  final List<String> prize2;
  final List<String> prize3;
  final String last3;
  final String last2;

  LatestRewards({
    this.prize1 = const [],
    this.prize2 = const [],
    this.prize3 = const [],
    this.last3 = "------",
    this.last2 = "--",
  });

  factory LatestRewards.fromJson(Map<String, dynamic> json) {
    return LatestRewards(
      prize1: List<String>.from(json['prize_1'] ?? []),
      prize2: List<String>.from(json['prize_2'] ?? []),
      prize3: List<String>.from(json['prize_3'] ?? []),
      last3: json['last_3'] ?? "---",
      last2: json['last_2'] ?? "--",
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

  factory CheckResult.fromJson(Map<String, dynamic> json) { //json มาแปลงร่างให้เป็นข้อมูลที่พร้อมใช้งาน แล้วนำไปเก็บไว้เพื่อรอแสดงผลบนหน้าจอ 
    return CheckResult(
      isWinner: json['is_winner'] ?? false,
      message: json['message'] ?? 'เกิดข้อผิดพลาด',
      lottoNumber: json['lotto_number'] ?? '',
      prizeMoney: (json['prize_money'] as num?)?.toDouble() ?? 0.0,
      prizeTier: json['prize_tier'] ?? 0,
    ); 
  }
}