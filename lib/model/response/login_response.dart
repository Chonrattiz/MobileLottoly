// lib/model/response/user.dart
class AppUser {
  final String userId;
  final String username;
  final String role;

  AppUser({
    required this.userId,
    required this.username,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final userObject = json['user'] ?? json['data']?['user'];

    String? foundUserId;
    String? foundUsername;
    String? foundRole;

    if (userObject != null && userObject is Map) {
      foundUsername = userObject['username']?.toString();
      foundUserId =
          userObject['user_id']?.toString() ?? userObject['id']?.toString();
      foundRole = userObject['role']?.toString();
    } else {
      foundUsername = json['username']?.toString();
      foundUserId = json['user_id']?.toString() ?? json['id']?.toString();
      foundRole = json['role']?.toString();
    }

    if (foundUserId == null || foundUserId.isEmpty) {
      throw Exception('ไม่ได้รับ User ID จาก Server');
    }

    return AppUser(
      userId: foundUserId,
      username: foundUsername ?? 'ผู้ใช้',
      role: foundRole ?? 'member',
    );
  }
}
