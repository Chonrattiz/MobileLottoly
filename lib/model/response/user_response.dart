// lib/model/response/user.dart

class User {
  final String userId;
  final String username;

  User({required this.userId, required this.username});

  factory User.fromJson(Map<String, dynamic> json) {
    // ตรรกะการหา user_id และ username ที่ซับซ้อน จะถูกจัดการในนี้ที่เดียว!
    final userObject = json['user'] ?? json['data']?['user'];
    String? foundUserId;
    String? foundUsername;

    if (userObject != null && userObject is Map) {
      foundUsername = userObject['username']?.toString();
      foundUserId = userObject['user_id']?.toString() ?? userObject['id']?.toString();
    } else {
      foundUsername = json['username']?.toString();
      foundUserId = json['user_id']?.toString() ?? json['id']?.toString();
    }

    if (foundUserId == null || foundUserId.isEmpty) {
      throw Exception('ไม่สามารถหา User ID จากข้อมูลที่เซิร์ฟเวอร์ส่งมาได้');
    }

    return User(
      userId: foundUserId,
      username: foundUsername ?? 'ผู้ใช้',
    );
  }
}