import 'package:flutter/foundation.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/features/creator_wallet/model/creator_creatoo_transaction_response.dart';
import '../repository/user_points_repository.dart';

class UserPointsViewModel extends ChangeNotifier {
  final UserPointsRepository _repository = UserPointsRepository();

  bool _isLoading = false;
  String? _error;
  CreatorCreatooPointTransactionResponse? _response;

  bool get isLoading => _isLoading;
  String? get error => _error;
  CreatorCreatooPointTransactionResponse? get response => _response;

  num? get totalPoints => _response?.data?.creatooPoints;
  List<BusinessTransaction>? get businessTransactions => _response?.data?.businessTransactions;
  int get totalBusinesses => _response?.data?.businessTransactions?.length ?? 0;

  Future<void> loadPoints() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _repository.fetchPointsTransactions();
    result.fold(
      (error) {
        _error = error.message;
        _isLoading = false;
        notifyListeners();
      },
      (response) {
        _response = response;
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  String formatPoints(dynamic points) {
    final val = (points is int) ? points.toDouble() : (points as num?)?.toDouble() ?? 0.0;
    return val.toCommaSeparated();
  }
}
