import 'package:flutter/material.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/data/app_exceptions.dart';
import '../model/business_visit_model.dart';
import '../repository/business_visits_repository.dart';

class BusinessVisitsViewModel extends ChangeNotifier {
  final BusinessVisitsRepository _repo = BusinessVisitsRepository();

  List<BusinessVisit> _visits = [];
  List<BusinessVisit> get visits => _visits;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  Future<void> loadVisits({String? search, String? from, String? to}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final result = await _repo.getVisits(search: search, from: from, to: to);
    result.fold((error) {
      _error = error.message;
    }, (response) {
      _visits = response.data;
    });
    _isLoading = false;
    notifyListeners();
  }

  void setSearch(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  List<BusinessVisit> get filteredVisits {
    if (_searchQuery.isEmpty) return _visits;
    final q = _searchQuery.toLowerCase();
    return _visits.where((v) =>
      (v.userName?.toLowerCase().contains(q) ?? false) ||
      (v.cardName?.toLowerCase().contains(q) ?? false) ||
      (v.userMobile?.contains(q) ?? false)
    ).toList();
  }

  Map<String, List<BusinessVisit>> get visitsByDate {
    final map = <String, List<BusinessVisit>>{};
    for (final v in filteredVisits) {
      final date = _extractDate(v.time);
      map.putIfAbsent(date, () => []);
      map[date]!.add(v);
    }
    return map;
  }

  String _extractDate(String timeStr) {
    try {
      return timeStr.split(' ').first;
    } catch (_) {
      return timeStr;
    }
  }

  int get totalVisits => filteredVisits.length;
}
