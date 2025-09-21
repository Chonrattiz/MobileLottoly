// lib/model/response/user.dart

class User {
  final String userId;
  final String username;
  final String role; // ✅ เพิ่ม role

  User({
    required this.userId,
    required this.username,
    required this.role,  // ✅ บังคับว่าต้องมี role ด้วย
  });

  factory User.fromJson(Map<String, dynamic> json) {
    final userObject = json['user'] ?? json['data']?['user'];
    String? foundUserId;
    String? foundUsername;
    String? foundRole;

    if (userObject != null && userObject is Map) {
      foundUsername = userObject['username']?.toString();
      foundUserId = userObject['user_id']?.toString() ?? userObject['id']?.toString();
      foundRole = userObject['role']?.toString();  // ✅ ดึง role
    } else {
      foundUsername = json['username']?.toString();
      foundUserId = json['user_id']?.toString() ?? json['id']?.toString();
      foundRole = json['role']?.toString();       // ✅ ดึง role
    }

    if (foundUserId == null || foundUserId.isEmpty) {
      throw Exception('ไม่สามารถหา User ID จากข้อมูลที่เซิร์ฟเวอร์ส่งมาได้');
    }

    return User(
      userId: foundUserId,
      username: foundUsername ?? 'ผู้ใช้',
      role: foundRole ?? 'member',   // ✅ ถ้าไม่มี role ให้ default = member
    );
  }
}
