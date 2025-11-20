import 'package:creatoo/core.dart';
import 'package:creatoo/features/add_post_payment_summary/model/add_post_response_model.dart';
import 'package:creatoo/features/add_post/repository/add_post_repository.dart';

import '../model/add_post_model.dart';


class AddPostViewModel with ChangeNotifier{
  final AddPostRepository _myRepo = AddPostRepository();

  late AddPostModel model;
  int? radioValue;
  int creatorRequired = 1;
  bool isValidating = false;
  List<WorkMode> radioValues = WorkMode.values;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  late TextEditingController postExpiryController;
  late TextEditingController postNameController;
  late TextEditingController postDescriptionController ;
  late TextEditingController postMinInstaController;
  late TextEditingController postDeliverablesController;
  late TextEditingController postAmountController ;
  late TextEditingController postDurationController ;

  ApiResponse<AddPostResponseModel> postResponse = ApiResponse.loading();

  setResponse(ApiResponse<AddPostResponseModel> response) {
    postResponse = response;
  }

  init() async {
    model = AddPostModel();
    radioValue = null;
    isValidating = false;
    creatorRequired = 1;
    isValidating = false;
    postExpiryController = TextEditingController();
    postNameController = TextEditingController();
    postDescriptionController = TextEditingController();
    postMinInstaController = TextEditingController();
    postDeliverablesController = TextEditingController();
    postAmountController = TextEditingController();
    postDurationController = TextEditingController();
  }

  updateCreatorRequired(int value){
    creatorRequired = value;
    model.creatorRequired = value;
    notifyListeners();
  }

  updateMode(int value){
    radioValue = value;
    notifyListeners();
  }

  setValidatingStatus(status){
    isValidating = status;
    notifyListeners();
  }
}
