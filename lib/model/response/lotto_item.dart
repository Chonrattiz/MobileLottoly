class LottoItem {
  final int lottoId;
  final String lotteryNumber;
  final String status;
  final double price;
  
  LottoItem({
    required this.lottoId,
    required this.lotteryNumber,
    required this.status,
    required this.price,
  });

  // Factory constructor สำหรับสร้าง LottoItem object จากข้อมูล JSON
  // โดยจะจับคู่ key จาก JSON (เช่น 'lotto_id') มาใส่ในตัวแปรของคลาส
  factory LottoItem.fromJson(Map<String, dynamic> json) {
    return LottoItem(
      lottoId: json['lotto_id'] ?? 0,
      lotteryNumber: json['lotto_number'] ?? '',
      status: json['status'] ?? 'sell',
      // ใช้ (as num?) เพื่อรองรับทั้งเลข int และ double ที่มาจาก JSON
      price: (json['price'] as num?)?.toDouble() ?? 80.0,
    );
  }
}

