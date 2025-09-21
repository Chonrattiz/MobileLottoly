// lib/api/api_service.dart

import 'dart:convert';
import 'package:app_oracel999/model/request/cash_in_request.dart';
import 'package:app_oracel999/model/request/purchase_request.dart';
import 'package:app_oracel999/model/response/profile_models.dart';
import 'package:http/http.dart' as http;

// --- Imports สำหรับ Models และ Config ---
import '../config/app_config.dart';
import '../model/request/login_request.dart';
import '../model/request/register_request.dart'; // 👈 1. Import RegisterRequest Model
import '../model/response/user_response.dart';
import '../model/response/lotto_item.dart';
import '../model/response/wallet_response.dart';
import '../model/response/check_response.dart';

class ApiService {
  // --- ฟังก์ชัน Login (ของเดิม) ---
  Future<User> login(LoginRequest request) async {
    final url = Uri.parse('${AppConfig.baseUrl}/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['status'] == 'success') {
        return User.fromJson(responseData);
      } else {
        final message = responseData['message'] ?? 'ข้อมูลเข้าระบบไม่ถูกต้อง';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('การเชื่อมต่อล้มเหลว กรุณาลองใหม่อีกครั้ง');
    }
  }

  // --- 👇 2. เพิ่มฟังก์ชัน Register หน้าสมัครสมาชิก เข้าไปใหม่ ---
  Future<void> register(RegisterRequest request) async {
    final url = Uri.parse('${AppConfig.baseUrl}/register');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      // ตรวจสอบว่า API ตอบกลับมาว่าไม่สำเร็จหรือไม่
      // (สังเกตว่าฟังก์ชันนี้เป็น Future<void> เพราะไม่ต้องคืนค่าอะไรกลับไป)
      if (response.statusCode != 200 || responseData['status'] != 'ok') {
        final message = responseData['message'] ?? 'ไม่สามารถสมัครสมาชิกได้';
        throw Exception(message);
      }
    } catch (e) {
      // จัดการ Error อื่นๆ เช่น Timeout, การเชื่อมต่อล้มเหลว
      throw Exception('การเชื่อมต่อล้มเหลว: ${e.toString()}');
    }
  }

  // --- 3. เพิ่มฟังก์ชัน home  ---

  Future<Map<String, List<LottoItem>>> fetchHomePageData() async {
    final luckyUrl = Uri.parse('${AppConfig.baseUrl}/lotto/lucky');
    final auspiciousUrl = Uri.parse('${AppConfig.baseUrl}/lotto/Auspicious');

    try {
      // ยิง API 2 เส้นพร้อมกันเพื่อความรวดเร็ว
      final responses = await Future.wait([
        http.get(luckyUrl).timeout(const Duration(seconds: 10)),
        http.get(auspiciousUrl).timeout(const Duration(seconds: 10)),
      ]);

      // ตรวจสอบว่าทั้ง 2 requests สำเร็จหรือไม่
      if (responses[0].statusCode == 200 && responses[1].statusCode == 200) {
        final luckyData = jsonDecode(responses[0].body);
        final List<dynamic> luckyJson = luckyData['data'] ?? [];
        final luckyLottos = luckyJson.map((json) => LottoItem.fromJson(json)).toList();

        final auspiciousData = jsonDecode(responses[1].body);
        final List<dynamic> auspiciousJson = auspiciousData['data'] ?? [];
        final auspiciousLottos = auspiciousJson.map((json) => LottoItem.fromJson(json)).toList();

        // ส่งข้อมูลกลับไปเป็น Map ที่มี key ชัดเจน
        return {
          'luckyLottos': luckyLottos,
          'auspiciousLottos': auspiciousLottos,
        };
      } else {
        // ถ้ามี request ใด request หนึ่งไม่สำเร็จ
        throw Exception('ไม่สามารถโหลดข้อมูลสลากได้');
      }
    } catch (e) {
      throw Exception('การเชื่อมต่อล้มเหลว: ${e.toString()}');
    }
  }

  // --- 4. เพิ่มฟังก์ชัน Wallet  ---
  Future<Wallet> fetchWalletBalance(String userId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/wallet?user_id=$userId');

    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // ให้ Wallet Model จัดการแปลง JSON เป็น Object
        return Wallet.fromJson(data);
      } else {
        // ถ้าสถานะไม่ใช่ 200
        throw Exception('ไม่สามารถโหลดข้อมูลได้: ${response.statusCode}');
      }
    } catch (e) {
      // จัดการ Error อื่นๆ
      throw Exception('การเชื่อมต่อล้มเหลว: ${e.toString()}');
    }
  }

  // --- 5. เพิ่มฟังก์ชันดึงผลรางวัลล่าสุด ---
  Future<List<CurrentReward>> fetchLatestRewards() async {
  final url = Uri.parse('${AppConfig.baseUrl}/rewards/currsent');
  try {
    final response = await http.get(url).timeout(const Duration(seconds: 10));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body)['data'] as List;
      return data.map((e) => CurrentReward.fromJson(e)).toList();
    } else {
      throw Exception('โหลดผลรางวัลไม่สำเร็จ (รหัส: ${response.statusCode})');
    }
  } catch (e) {
    throw Exception('การเชื่อมต่อล้มเหลว: ${e.toString()}');
  }
}


  // --- 6. เพิ่มฟังก์ชันตรวจรางวัล ---
  Future<CheckResult> checkLottoNumber(String number) async {
    final url = Uri.parse('${AppConfig.baseUrl}/rewards/check?number=$number');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        // ให้ Model จัดการแปลง JSON จาก key 'data'
        return CheckResult.fromJson(jsonDecode(response.body)['data']);
      } else {
        throw Exception('ไม่สามารถตรวจรางวัลได้ (รหัส: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('การเชื่อมต่อล้มเหลว: ${e.toString()}');
    }
  }

  // ---  เพิ่มฟังก์ชันสำหรับดึงข้อมูลโปรไฟล์ ---
  Future<UserProfile> fetchUserProfile(String userId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/profile?user_id=$userId');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        return UserProfile.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('ไม่สามารถโหลดข้อมูลโปรไฟล์ได้');
      }
    } catch (e) {
      throw Exception('การเชื่อมต่อล้มเหลว: ${e.toString()}');
    }
  }

  // --- เพิ่มฟังก์ชันสำหรับดึงประวัติการซื้อ ---
  Future<List<PurchasedLotto>> fetchUserPurchases(String userId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/users/purchases?user_id=$userId');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> itemsJson = data['data'] ?? [];
        return itemsJson.map((json) => PurchasedLotto.fromJson(json)).toList();
      } else {
        throw Exception('ไม่สามารถโหลดรายการสั่งซื้อได้');
      }
    } catch (e) {
      throw Exception('การเชื่อมต่อล้มเหลว: ${e.toString()}');
    }
  }

   // --- สำหรับการยืนยันการสั่งซื้อเข้าไป ---
  Future<void> createPurchase(PurchaseRequest request) async {
    final url = Uri.parse('${AppConfig.baseUrl}/purchases');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      final responseData = jsonDecode(response.body);

      if (response.statusCode != 200 || responseData['status'] != 'success') {
        final message = responseData['message'] ?? 'เกิดข้อผิดพลาดในการสั่งซื้อ';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('การเชื่อมต่อล้มเหลว: ${e.toString()}');
    }
  }

  // --- 👇 เพิ่มฟังก์ชันนี้สำหรับ "ค้นหา" ---
  Future<List<LottoItem>> searchLotto(String query) async {
    final url = Uri.parse('${AppConfig.baseUrl}/lotto/search?number=$query');
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> itemsJson = data['data'] ?? [];
        return itemsJson.map((json) => LottoItem.fromJson(json)).toList();
      } else {
        throw Exception('ไม่สามารถค้นหาได้ (รหัส: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('การเชื่อมต่อล้มเหลว: ${e.toString()}');
    }
  }

  // --- 👇 เพิ่มฟังก์ชันนี้สำหรับ "สุ่มตัวเลข" ---
  Future<LottoItem> getRandomLotto() async {
    final url = Uri.parse('${AppConfig.baseUrl}/lotto/random?sell_only=true');//
    try {
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null) {
          return LottoItem.fromJson(data['data']);
        } else {
          throw Exception('ไม่พบสลากที่ว่างสำหรับสุ่ม');
        }
      } else {
        throw Exception('ไม่สามารถสุ่มเลขได้ (รหัส: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('การเชื่อมต่อล้มเหลว: ${e.toString()}');
    }
  }
 // --- ขึ้นเงินแล้วจะอัพเดรต ---
  Future<void> cashInPrize(CashInRequest request) async {
    final url = Uri.parse('${AppConfig.baseUrl}/rewards/cashIn'); // ใช้ baseUrl จาก Config
    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        final responseBody = jsonDecode(response.body);
        final errorMessage = responseBody['error'] ?? 'เกิดข้อผิดพลาดในการขึ้นเงิน';
        throw Exception(errorMessage);
      }
      // ถ้าสำเร็จ (status 200) ไม่ต้องทำอะไร
    } catch (e) {
      throw Exception('การเชื่อมต่อผิดพลาด: ${e.toString()}');
    }
  }
  
}
