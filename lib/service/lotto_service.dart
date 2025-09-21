// lotto_service.dart
import 'dart:convert';
import 'package:app_oracel999/config/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:app_oracel999/model/response/lotto_item.dart';
import 'package:app_oracel999/model/response/updateitem.dart';

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
    String status = 'sell,sold',
  }) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}/lotto/preview-update',
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

  static Future<void> bulkUpdateNumbers(List<DraftUpdateItem> items) async {
    final uri = Uri.parse('${AppConfig.baseUrl}/lotto/bulk-update');
    final body = {
      'items':
          items
              .map(
                (it) => {'lotto_id': it.lottoId, 'lotto_number': it.newNumber},
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
  }

  // Count & Generate Functions
  static Future<int> countAll() async {
    final uri = Uri.parse('${AppConfig.baseUrl}/lottos/count');
    final res = await http.get(uri).timeout(const Duration(seconds: 10));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return (map['count'] as num).toInt();
  }

  static Future<int> Generate({int count = 100}) async {
    final uri = Uri.parse(
      '${AppConfig.baseUrl}/lotto/generate',
    ).replace(queryParameters: {'count': '$count'});
    final res = await http.post(uri).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}: ${res.body}');
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return (map['inserted'] as num?)?.toInt() ?? 0;
  }
  
}
