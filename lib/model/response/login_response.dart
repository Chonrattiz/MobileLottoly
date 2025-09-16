// lib/model/response/user.dart

//สร้างตัวเก็บข้อมูลที่จะดึงBackend 
class User {
  final String userId;
  final String username;
  final String role; //adminหรือuser

  User({// บังคับว่าห้ามข้อมูลขาดนะ
    required this.userId,
    required this.username,
    required this.role, 
  });

  factory User.fromJson(Map<String, dynamic> json) {//"ตัวแปลงข้อมูล" ทำหน้าที่รับข้อมูลดิบที่เซิร์ฟเวอร์ส่งมา แล้วแปลงให้เป็นข้อมูล User
    final userObject = json['user'] ?? json['data']?['user'];
    String? foundUserId;//ตัวรับค่า
    String? foundUsername;
    String? foundRole; 

// 4. ค้นหาข้อมูล
    if (userObject != null && userObject is Map) {// ค้นหาข้อมูลจากตัวแปร userObject
      foundUsername = userObject['username']?.toString();
      foundUserId = userObject['user_id']?.toString() ?? userObject['id']?.toString();
      foundRole = userObject['role']?.toString(); 
    } else {
      foundUsername = json['username']?.toString(); //ค้นหาข้อมูลจากตัวแปร json
      foundUserId = json['user_id']?.toString() ?? json['id']?.toString();
      foundRole = json['role']?.toString(); 
    }
  //เป็นการเช็คให้แน่ใจว่าได้รับ userId มาจริงๆ 
    if (foundUserId == null || foundUserId.isEmpty) {
      throw Exception('ไม่ได้รับ User ID จาก Server');
    }

    return User(
      userId: foundUserId,
      username: foundUsername ?? 'ผู้ใช้',
      role: foundRole ?? 'member',
    );
  }
}