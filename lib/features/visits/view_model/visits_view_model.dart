import 'package:creatoo/core.dart';
import 'package:creatoo/data/response/api_response.dart';
import 'package:creatoo/features/visits/model/visits_response_model.dart';
import 'package:creatoo/features/visits/repository/visits_repository.dart';
import 'package:intl/intl.dart';

class VisitsViewModel with ChangeNotifier {
  final VisitsRepository _myRepo = VisitsRepository();

  ApiResponse<VisitsResponseModel> visitsResponse = ApiResponse.loading();

  // Processed data
  final Map<String, List<Visit>> visitsByDate = {};
  int goldCount = 0;
  int silverCount = 0;
  int bronzeCount = 0;

  void setVisitsResponse(ApiResponse<VisitsResponseModel> response) {
    visitsResponse = response;
    if (response.status == Status.completed && response.data != null) {
      _processData(response.data!);
    }
    notifyListeners();
  }

  void _processData(VisitsResponseModel data) {
    final List<Visit> visits = data.days?.expand<Visit>((d) => d.visits).toList() ?? [];
    
    // Group by date
    visitsByDate.clear();
    for (var visit in visits) {
      final dateKey = DateFormat('EEEE, MMMM d, y').format(visit.dateTime);
      if (!visitsByDate.containsKey(dateKey)) {
        visitsByDate[dateKey] = [];
      }
      visitsByDate[dateKey]!.add(visit);
    }

    // Count by tier
    goldCount = visits.where((v) => v.tier == Tier.premium || v.tier == Tier.newTier).length;
    silverCount = visits.where((v) => v.tier == Tier.elite).length;
    bronzeCount = visits.where((v) => v.tier == Tier.core).length;
  }

  Future<void> fetchBusinessVisitsApi(String token) async {
    log("VisitsViewModel: Fetching business visits API called");
    setVisitsResponse(ApiResponse.loading());
    _myRepo.fetchBusinessVisits(token).then((value) {
      value.fold(
        (error) => setVisitsResponse(ApiResponse.error(error.message.toString())),
        (visitsModel) => setVisitsResponse(ApiResponse.completed(visitsModel)),
      );
    }).onError((error, stackTrace) {
      setVisitsResponse(ApiResponse.error(error.toString()));
    });
  }
}
