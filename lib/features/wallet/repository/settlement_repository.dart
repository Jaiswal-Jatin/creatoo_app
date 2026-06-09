import 'package:creatoo/core.dart';
import '../model/settlement_response_model.dart';

class SettlementRepository {
  final BaseApiServices _apiServices = NetworkApiService();

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };

  Future<Either<AppException, WalletSummaryResponse>> getWalletSummary({String? filter}) async {
    try {
      String url = AppUrl.businessWalletSummary;
      if (filter != null) url += '?filter=$filter';
      final response = await _apiServices.callGetAPI<WalletSummaryResponse, WalletSummaryResponse>(
        url,
        _headers,
        (r) => WalletSummaryResponse.fromJson(parseJson(r)),
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, List<WalletTransactionItem>>> getTransactions({
    String? status,
    String? source,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      String url = AppUrl.businessWalletTransactions;
      final params = <String>[];
      if (status != null) params.add('status=$status');
      if (source != null) params.add('source=$source');
      if (fromDate != null) params.add('from_date=$fromDate');
      if (toDate != null) params.add('to_date=$toDate');
      if (params.isNotEmpty) url += '?${params.join('&')}';

      final response = await _apiServices.callGetAPI<List<WalletTransactionItem>, List<WalletTransactionItem>>(
        url,
        _headers,
        (r) {
          final json = parseJson(r);
          final list = json['data'] as List<dynamic>? ?? [];
          return list.map((e) => WalletTransactionItem.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, List<SettlementHistoryItem>>> getSettlementHistory() async {
    try {
      final response = await _apiServices.callGetAPI<List<SettlementHistoryItem>, List<SettlementHistoryItem>>(
        AppUrl.businessSettlementHistory,
        _headers,
        (r) {
          final json = parseJson(r);
          final list = json['data'] as List<dynamic>? ?? [];
          return list.map((e) => SettlementHistoryItem.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }

  Future<Either<AppException, List<WalletTransactionItem>>> getAdvancePayments() async {
    try {
      final response = await _apiServices.callGetAPI<List<WalletTransactionItem>, List<WalletTransactionItem>>(
        AppUrl.businessAdvancePayments,
        _headers,
        (r) {
          final json = parseJson(r);
          final list = json['data'] as List<dynamic>? ?? [];
          return list.map((e) => WalletTransactionItem.fromJson(e as Map<String, dynamic>)).toList();
        },
      );
      return response;
    } on AppException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(AppException(0, e.toString()));
    }
  }
}

Map<String, dynamic> parseJson(String raw) {
  try {
    return Map<String, dynamic>.from(RegExp(r'\{.*\}').hasMatch(raw)
        ? (raw is String ? (const JsonDecoder().convert(raw) as Map) : {})
        : {});
  } catch (_) {
    return {};
  }
}
