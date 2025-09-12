// lib/model/request/login_request.dart

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  // ฟังก์ชันสำหรับแปลง Object นี้ให้เป็น JSON
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}