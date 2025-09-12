// lib/model/request/cash_in_request.dart

class CashInRequest {
  final int userId;
  final String lottoNumber;

  CashInRequest({
    required this.userId,
    required this.lottoNumber,
  });

  Map<String, dynamic> toJson() => { //toJson ส่งไปให้ Backend
        'user_id': userId,
        'lotto_number': lottoNumber,
      };
}