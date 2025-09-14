// --- โมเดลสำหรับข้อมูลโปรไฟล์จาก /profile ---
class UserProfile {
  final String username;
  final String email;

  UserProfile({required this.username, required this.email});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // สมมติว่า JSON ที่ได้กลับมามีลักษณะเป็น { "user": { "username": "...", "email": "..." } }
    final userJson = json['user'] ?? {};
    return UserProfile(
      username: userJson['username'] ?? 'N/A',
      email: userJson['email'] ?? 'N/A',
    );
  }
}

// --- โมเดลสำหรับรายการที่ซื้อจาก /users/purchases ---
class PurchasedLotto {
  final int lottoId;
  final String lottoNumber;
  final String status;

  PurchasedLotto({
    required this.lottoId,
    required this.lottoNumber,
    required this.status,
  });

  factory PurchasedLotto.fromJson(Map<String, dynamic> json) {
    return PurchasedLotto(
      lottoId: json['lotto_id'] ?? 0,
      lottoNumber: json['lotto_name'] ?? '', // Backend ใช้ lotto_name
      status: json['status'] ?? 'ยัง',
    );
  }
}
