import '../../../core.dart';

class AddPostRepository with ChangeNotifier {
  final BaseApiServices _apiServices = NetworkApiService();

  Future<dynamic> addPostApi(dynamic body) async {
    return await _apiServices.callPostAPI(
      AppUrl.addPost,
      {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
      Parser.parseAddPostResponse,
      body: body,
    );
  }
}
