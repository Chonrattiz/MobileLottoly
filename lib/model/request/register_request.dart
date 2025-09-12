class RegisterRequest {
  final String username;
  final String email;
  final String password;
  final double wallet;

  RegisterRequest({
    required this.username,
    required this.email,
    required this.password,
    required this.wallet,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'password': password,
      "role": "member", // กำหนดค่า role เป็น member โดยอัตโนมัติ
      'wallet': wallet,
    };
  }
}

