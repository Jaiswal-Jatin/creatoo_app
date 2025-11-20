import 'package:creatoo/core.dart';
import 'package:creatoo/features/register_creator/model/register_creator_model.dart';

import '../../verify_otp/model/verify_otp_model.dart';
import '../model/creator_profile_response.dart';
import '../repository/creator_profile_repository.dart';

class EditCreatorProfileViewModel with ChangeNotifier {
  final CreatorProfileRepository _myRepo = CreatorProfileRepository();
  TextEditingController? nameController;
  TextEditingController? addressController;
  TextEditingController? emailController;
  TextEditingController? phoneController;

  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool isEditing = false;
  late RegisterCreator model = RegisterCreator();

  enableEditing(value) {
    isEditing = value;
    notifyListeners();
  }

  ApiResponse<CreatorProfileResponse> profileResponse = ApiResponse.loading();

  setResponse(ApiResponse<CreatorProfileResponse> response) {
    profileResponse = response;
  }

  init() async {
    formKey = GlobalKey<FormState>();
    await fetchProfile();
  }

  Future<void> fetchProfile() async {
    setResponse(ApiResponse.loading());
    var data = {"id": userId, "role_id": roleId};
    var response = await _myRepo.fetchCreatorProfileApi(data);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setResponse(ApiResponse.completed(r));
        // Utils.toastMessage(r.message.toString());
        updateFields();
      },
    );
    notifyListeners();
  }

  updateFields() {
    var item = profileResponse.data!.data!;
    nameController = TextEditingController(text: item.name.toString());
    addressController = TextEditingController(text: item.address.toString());
    emailController = TextEditingController(text: item.email.toString());
    phoneController = TextEditingController(text: item.mobile.toString());
  }

  Future<void> updateProfile() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    model.name = nameController!.text;
    model.email = emailController!.text;
    model.address = addressController!.text;
    model.roleId = roleId;

    var response = await _myRepo.updateCreatorProfileApi(model);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        var oldToken = token;
        setResponse(ApiResponse.completed(r));
        Utils.toastMessage(r.message.toString());
        enableEditing(false);
        await saveUserData(r.data!);
        token = oldToken;
        Navigator.pop(navigatorKey.currentContext!, true);
        notifyListeners();
      },
    );
    notifyListeners();
  }

  saveUserData(Data data) async {
    final SharedPreferencesService prefs = SharedPreferencesService();
    prefs.saveUserData(
      UserData(
        id: data.id,
        email: data.email,
        name: data.name,
        address: data.address,
      ),
      skip: true,
    );
  }

  Future<void> getImageAttachment() async {
    File? file = await ImageHelper.pickImage();
    if (file != null) {
      model.userImage = file.path;
      // profileResponse.data!.data!.businessImage = file.path;
      notifyListeners();
    } else {
      Utils.toastMessage("Failed to attach image");
    }
    notifyListeners();
  }
}
