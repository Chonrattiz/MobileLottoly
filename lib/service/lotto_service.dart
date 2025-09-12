import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

class Env {
  static String get baseUrl {
    // หมายเหตุ:
    // - Android Emulator ใช้ 10.0.2.2 (ชี้ไป host)
    // - iOS Simulator ใช้ localhost ได้
    // - ถ้าเป็นเครื่องจริง (มือถือเชื่อม LAN) ให้เปลี่ยนเป็น IP ของเครื่อง Dev เช่น http://192.168.1.10:8080
    if (kIsWeb) return 'http://localhost:8080';
    if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    if (Platform.isIOS) return 'http://localhost:8080';
    return 'http://localhost:8080';
  }
}

class LottoItem {
  final int lottoId;
  final String lottoNumber;
  final String status;
  final double price;
  final int? createdBy;

  LottoItem({
    required this.lottoId,
    required this.lottoNumber,
    required this.status,
    required this.price,
    required this.createdBy,
  });

  List<int> get digits {
    final num = (lottoNumber.length < 6)
        ? ('000000' + lottoNumber).substring(
            ('000000' + lottoNumber).length - 6,
          )
        : lottoNumber.substring(0, 6);
    return num.split('').map((e) => int.tryParse(e) ?? 0).toList();
  }

  factory LottoItem.fromJson(Map<String, dynamic> j) {
    return LottoItem(
      lottoId: (j['lotto_id'] as num).toInt(),
      lottoNumber: j['lotto_number'] as String,
      status: j['status'] as String,
      price: (j['price'] as num).toDouble(),
      createdBy: j['created_by'] == null
          ? null
          : (j['created_by'] as num).toInt(),
    );
  }
}

/// ใช้เก็บผล Preview ที่จะ "อัปเดต" (ไม่ใช่ insert)
/// server ส่งกลับมาเป็น mapping lotto_id เดิม -> เลขใหม่ (ที่ไม่ซ้ำ DB)
class DraftUpdateItem {
  final int lottoId;
  final String oldNumber;
  final String newNumber;

  DraftUpdateItem({
    required this.lottoId,
    required this.oldNumber,
    required this.newNumber,
  });

  factory DraftUpdateItem.fromJson(Map<String, dynamic> j) {
    return DraftUpdateItem(
      lottoId: (j['lotto_id'] as num).toInt(),
      oldNumber: (j['lotto_number_old'] ?? '').toString(),
      newNumber: (j['lotto_number_new'] ?? '').toString(),
    );
  }

  List<int> get digits => newNumber
      .padLeft(6, '0')
      .substring(0, 6)
      .split('')
      .map((e) => int.tryParse(e) ?? 0)
      .toList();
}

class LottoService {
  // ----------------------------------------
  // พื้นฐาน
  // ----------------------------------------
  static Future<List<LottoItem>> fetchAllAsc() async {
    final uri = Uri.parse('${Env.baseUrl}/lotto');
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

  // 🔍 ค้นหา (รับ q=1..6 หลัก, ถ้า 2-5 จะเช็ค N ตัวท้าย, 6=ตรงทั้งเลข)
  static Future<List<LottoItem>> search(
    String q, {
    String? status,
    int limit = 200,
  }) async {
    final qp = <String, String>{'q': q, 'limit': '$limit'};
    if (status != null && status.isNotEmpty) qp['status'] = status;
    final uri = Uri.parse(
      '${Env.baseUrl}/lotto/search',
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

  // 🎲 สุ่มจากฐานข้อมูล (ค่าเริ่มต้นสุ่มเฉพาะ sell)
  static Future<LottoItem?> random({bool sellOnly = true}) async {
    final uri = Uri.parse(
      '${Env.baseUrl}/lotto/random',
    ).replace(queryParameters: {'sell_only': sellOnly.toString()});
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    if (map['data'] == null) return null;
    return LottoItem.fromJson(map['data'] as Map<String, dynamic>);
  }

  // ----------------------------------------
  // ✅ Flow ใหม่: Preview (อัปเดต) & Release (UPDATE)
  // ----------------------------------------

  /// Preview: สุ่มเลขใหม่ให้ lotto_id ที่มีอยู่ (ไม่บันทึก DB)
  /// server route: POST /lottos/preview-update?count=<N>&status=sell
  static Future<List<DraftUpdateItem>> previewUpdate({
    int count = 100,
    String status = 'sell,sold',
  }) async {
    final uri = Uri.parse(
      '${Env.baseUrl}/lotto/preview-update',
    ).replace(queryParameters: {'count': '$count', 'status': status});
    final res = await http.post(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (map['data'] as List?) ?? <dynamic>[];
    return list
        .map((e) => DraftUpdateItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Release: อัปเดตเลขใหม่ตาม mapping lotto_id -> lotto_number (UPDATE เท่านั้น)
  /// server route: POST /lottos/bulk-update
  static Future<void> bulkUpdateNumbers(List<DraftUpdateItem> items) async {
    final uri = Uri.parse('${Env.baseUrl}/lotto/bulk-update');
    final body = {
      'items': items
          .map((it) => {'lotto_id': it.lottoId, 'lotto_number': it.newNumber})
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
  }

  // นับจำนวนล็อตโต้ทั้งหมด
  static Future<int> countAll() async {
    final uri = Uri.parse('${Env.baseUrl}/lottos/count');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return (map['count'] as num).toInt();
  }

  // seed 100 ชุด (หรือจำนวนกำหนดเอง)
  static Future<int> Generate({int count = 100}) async {
    final uri = Uri.parse(
      '${Env.baseUrl}/lotto/generate',
    ).replace(queryParameters: {'count': '$count'});
    final res = await http.post(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return (map['inserted'] as num?)?.toInt() ?? 0;
  }
}
