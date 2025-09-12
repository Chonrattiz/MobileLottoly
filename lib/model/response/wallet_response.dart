// lib/model/response/wallet.dart

class Wallet {
  final int balance;

  Wallet({required this.balance});

  // Factory constructor นี้จะรับผิดชอบในการดึงข้อมูล 'wallet'
  // ออกมาจาก JSON ที่มีโครงสร้างซ้อนกันอยู่
  factory Wallet.fromJson(Map<String, dynamic> json) {
    try {
      // เข้าไปใน object 'user' ก่อน แล้วค่อยดึง 'wallet'
      final balance = json['user']?['wallet'];

      if (balance is int) {
        return Wallet(balance: balance);
      } else {
        // กรณีที่ key 'wallet' ไม่ใช่ตัวเลข int
        throw const FormatException('รูปแบบข้อมูล wallet ไม่ถูกต้อง');
      }
    } catch (e) {
      throw Exception('ไม่พบข้อมูล wallet ในการตอบกลับจากเซิร์ฟเวอร์');
    }
  }
}