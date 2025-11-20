import 'package:creatoo/features/category/repository/category_repository.dart';

import '../../../core.dart';
import '../model/BusinessTypeResponseModel.dart';

class CategoryViewModel with ChangeNotifier {
  final CategoryRepository _myRepo = CategoryRepository();
  ApiResponse categoryResponse = ApiResponse.completed("data");
  List<BusinessType> businessTypeList = [];

  setCategoryResponse(ApiResponse response) {
    categoryResponse = response;
  }

  init() async {
    await getBusinessTypes();
  }

  Future<void> getBusinessTypes() async {
    setCategoryResponse(ApiResponse.loading());
    var response = await _myRepo.getBusinessTypesApi();
    response.fold(
      (l) {
        setCategoryResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setCategoryResponse(ApiResponse.completed(r));
        // Utils.toastMessage(r.message.toString());
        businessTypeList = categoryResponse.data!.data!;
      },
    );
    notifyListeners();
  }
}
