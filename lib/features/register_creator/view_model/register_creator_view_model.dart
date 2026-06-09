import 'package:creatoo/core.dart';
import 'package:creatoo/features/register_creator/model/register_creator_model.dart';
import 'package:creatoo/features/register_creator/model/register_creator_response _model.dart';
import 'package:creatoo/features/register_creator/repository/register_creator_repository.dart';
import 'package:creatoo/features/verify_otp/model/verify_otp_model.dart';
import 'package:creatoo/utils/deep_link_service.dart';
import 'package:creatoo/features/card/view_model/card_view_model.dart';
import 'package:provider/provider.dart';
class RegisterCreatorViewModel with ChangeNotifier {
  final RegisterCreatorRepository _myRepo = RegisterCreatorRepository();
  late RegisterCreator model;
  bool isValidating = false;
  bool userVerified = false;
  bool isLoading = false;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  late TextEditingController instaUserController = TextEditingController();

  ApiResponse<RegisterCreatorResponse> creatorResponse = ApiResponse.initial();

  setResponse(ApiResponse<RegisterCreatorResponse> response) {
    creatorResponse = response;
  }

  setValidatingStatus(status) {
    isValidating = status;
    notifyListeners();
  }

  init(String phone) async {
    isValidating = false;
    userVerified = false;
    isLoading = false;
    instaUserController = TextEditingController();
    model = RegisterCreator();
    model.roleId = roleId;
    model.mobile = phone;
  }

  Future<void> registerCreator() async {
    setResponse(ApiResponse.loading());
    notifyListeners();
    model.instagramUsername = instaUserController.text.trim();
    model.instagramLink = "instagram.com/${instaUserController.text.trim()}";
    var response = await _myRepo.registerCreator(model);
    response.fold(
      (l) {
        setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        setResponse(ApiResponse.completed(r));
        Utils.toastMessage(r.message.toString());
        Navigator.pushNamedAndRemoveUntil(navigatorKey.currentContext!,
            RoutesName.homePage, (route) => false);
        await saveUserData(r.data!);

        // Auto-assign a card to the new creator
        try {
          final cardViewModel = Provider.of<CardViewModel>(navigatorKey.currentContext!, listen: false);
          await cardViewModel.autoAssignCard(navigatorKey.currentContext!);
        } catch (e) {
          debugPrint("Card auto-assign failed: $e");
        }

        // Check for pending deep link navigation after successful registration
        await Future.delayed(const Duration(milliseconds: 500));
        DeepLinkService.checkPendingNavigation();
      },
    );
    notifyListeners();
  }

  Future<void> fetchInstaUser() async {
    isLoading = true;
    // setResponse(ApiResponse.loading());
    notifyListeners();
    var response =
        await _myRepo.fetchInstaUser({"username": instaUserController.text});
    response.fold(
      (l) {
        // setResponse(ApiResponse.error(l.message));
        Utils.toastMessage(l.message.toString());
      },
      (r) async {
        isLoading = false;
        log(r.data!.toJson().toString());
        AppDialog.showInstagramConfirmationDialog(
          user: r.data!,
          onPressed: () {
            if (r.data!.username == instaUserController.text.trim()) {
              userVerified = true;
              Navigator.pop(navigatorKey.currentContext!);
            }
            notifyListeners();
          },
        );
        notifyListeners();
      },
    );
    isLoading = false;
    notifyListeners();
  }

  saveUserData(Data data) async {
    final SharedPreferencesService prefs = SharedPreferencesService();
    token = data.token;
    userId = data.id;
    await prefs.saveToken(data.token!);
    await prefs.saveUserId(data.id!);
    prefs.saveUserData(
      UserData(
        id: data.id,
        email: data.email,
        mobile: data.mobile,
        token: data.token,
        name: data.name,
        address: data.address,
        // isActive: int.parse(data.isActive ?? "1"),
      ),
    );
  }

  Future<void> getImageAttachment() async {
    File? file = await ImageHelper.pickImage();
    if (file != null) {
      model.userImage = file.path;
    } else {
      Utils.toastMessage("Failed to attach image");
    }
    notifyListeners();
  }

  void updateForm(List<String> data) {
    model.name = data[0];
    // model.mobile = data[1];
    // model.email = data[1];
    model.address = data[1];
    notifyListeners();
  }
}
