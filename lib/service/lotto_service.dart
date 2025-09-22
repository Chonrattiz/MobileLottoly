// lotto_service.dart
import 'dart:convert';
import 'package:app_oracel999/config/app_config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_oracel999/model/response/lotto_item.dart';
import 'package:app_oracel999/model/response/updateitem.dart';
import 'package:app_oracel999/model/response/profile_models.dart';
import 'package:app_oracel999/model/response/reward_data.dart';


class LottoService {
  // Basic Functions
  static Future<List<LottoItem>> fetchAllAsc() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/lotto');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (map['data'] as List?) ?? <dynamic>[];
    return list
        .map((e) => LottoItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Search Function
  static Future<List<LottoItem>> search(
    String q, {
    String? status,
    int limit = 200,
  }) async {
    final qp = <String, String>{'q': q, 'limit': '$limit'};
    if (status != null && status.isNotEmpty) qp['status'] = status;
    final uri = Uri.parse(
      '${AppConfig.baseUrl}/lotto/search',
    ).replace(queryParameters: qp);

    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (map['data'] as List?) ?? <dynamic>[];
    return list
        .map((e) => LottoItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Random Function
  static Future<LottoItem?> random({bool sellOnly = true}) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}/lotto/random',
    ).replace(queryParameters: {'sell_only': sellOnly.toString()});
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    if (map['data'] == null) return null;
    return LottoItem.fromJson(map['data'] as Map<String, dynamic>);
  }

  // Preview & Release Functions
  static Future<List<DraftUpdateItem>> previewUpdate({
    int count = 100,
    String status = 'sell',
  }) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}/lotto/preview-update',
    ).replace(queryParameters: {'count': '$count', 'status': status});

    final res = await http.post(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (map['items'] as List?) ?? <dynamic>[];

    // map -> DraftUpdateItem
    return list.map((e) {
      return DraftUpdateItem(
        lottoId: e['lotto_id'] != null ? (e['lotto_id'] as num).toInt() : 0,
        oldNumber: e['lotto_number_old']?.toString() ?? '',
        newNumber: e['lotto_number']?.toString() ?? e['lotto_number_new'] ?? '',
      );
    }).toList();
  }

  // Generate: reset table + insert ชุดใหม่
  // POST /lotto/generate
  // ----------------------------------------
  static Future<int> generateNew(List<DraftUpdateItem> items) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/lotto/generate');

    final body = {
      'items':
          items
              .map(
                (it) => {
                  'lotto_number': it.newNumber,
                  'status': 'sell',
                  'price': 80,
                  'created_by': null,
                },
              )
              .toList(),
    };

    final res = await http
        .post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }

    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return (map['inserted'] as num?)?.toInt() ?? 0;
  }

  // ✅ ดึงข้อมูลโปรไฟล์
  Future<UserProfile> fetchProfile(String userId) async {
    try {
      final url = Uri.parse('${AppConfig.baseUrl}/profile?user_id=$userId');
      final response = await http.get(url).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserProfile.fromJson(data);
      } else {
        throw Exception(
          'Failed to load profile. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('เกิดข้อผิดพลาด: $e');
    }
  }

  // ✅ ลบข้อมูลทั้งหมด (เฉพาะ Admin)
  Future<void> deleteAllData(String adminUserId) async {
    final url = Uri.parse('${AppConfig.baseUrl}/admin/clearData');

    final response = await http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'admin_user_id': adminUserId}),
        )
        .timeout(const Duration(seconds: 30));

    if (response.statusCode != 200) {
      throw Exception(
        'ล้มเหลว: ${jsonDecode(response.body)['message'] ?? response.reasonPhrase}',
      );
    }
  }

  // -----------------------
  // ดึงรางวัลปัจจุบัน
  // GET /rewards/currsent
  // -----------------------
  static Future<List<RewardData>> fetchCurrentRewards() async {
    final url = Uri.parse('${AppConfig.baseUrl}/rewards/currsent');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List<dynamic> data = body['data'];
      return data.map((json) => RewardData.fromJson(json)).toList();
    } else {
      throw Exception(
        'Failed to load rewards: Server responded with status code ${response.statusCode}',
      );
    }
  }

  // -----------------------
  // สุ่มรางวัล (Preview)
  // GET /rewards/generate-preview
  // -----------------------
  static Future<List<RewardData>> generatePreview() async {
    final url = Uri.parse('${AppConfig.baseUrl}/rewards/generate-preview');
    final response = await http.get(url);
    final body = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final List<dynamic> data = body['data'];
      return data.map((json) => RewardData.fromPreviewJson(json)).toList();
    } else {
      final message = body['message'] ?? 'เกิดข้อผิดพลาดในการสุ่มรางวัล';
      throw Exception(message);
    }
  }

  // -----------------------
  // ปล่อยรางวัล (Release)
  // POST /rewards/release
  // -----------------------
  static Future<String> releaseRewards(
    List<RewardData> previewRewards, {
    Map<int, double>? customPrizes,
  }) async {
    if (previewRewards.isEmpty) {
      throw Exception('กรุณาสุ่มเลขรางวัลก่อนทำการปล่อยรางวัล');
    }

    final rewardsPayload =
        previewRewards.map((reward) {
          return {
            'lotto_id': reward.lottoId,
            'prize_tier': reward.prizeTier,
            'prize_money': customPrizes?[reward.prizeTier] ?? reward.prizeMoney,
          };
        }).toList();

    final requestBody = jsonEncode({'rewards': rewardsPayload});
    final url = Uri.parse('${AppConfig.baseUrl}/rewards/release');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: requestBody,
    );

    final body = jsonDecode(response.body);
    if (response.statusCode == 200) {
      return body['message'] ?? 'ปล่อยรางวัลสำเร็จ!';
    } else {
      throw Exception(body['message'] ?? 'ปล่อยรางวัลล้มเหลว');
    }
  }

  // ✅ ฟังก์ชันที่เพิ่มเข้ามาใหม่
  // สำหรับเรียก POST /lotto/clear
  static Future<void> clearLottoData() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/lotto/clear');
    final res = await http.post(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    // ✅ log เมื่อสำเร็จ
    debugPrint('[LottoService] ลบข้อมูลสำเร็จ555 -> ${res.body}');
  }
}
