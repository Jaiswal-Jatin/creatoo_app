import 'dart:async';

import 'package:http/http.dart' as http;

import '../../core.dart';

Duration apiTimeOut = const Duration(seconds: 90);

class NetworkApiService extends BaseApiServices {
  @override
  Future<Either<AppException, Q>> callGetAPI<Q, R>(String apiURL, Map<String, String> headers, ComputeCallback<String, R> callback,
      {disableTokenValidityCheck = false}) async {
    try {
      log('apiURL : $apiURL');
      log('headers : ${jsonEncode(headers)}');
      await checkForValidSession(disableTokenValidityCheck);
      http.Response response = await http.get(Uri.parse(apiURL), headers: headers).timeout(apiTimeOut);
      if (response != null) {
        return Parser.parseResponse(response, callback);
      }
    } on SocketException {
      return Left(NoInternetError());
    } on TimeoutException {
      return Left(TimeoutError());
    } on HandshakeException {
      return Left(HandshakeError());
    } on SessionExpiry {
      return Left(SessionExpiry());
    }
    return Left(UnknownError());
  }

  @override
  Future<Either<AppException, Q>> callPostAPI<Q, R>(String apiURL, Map<String, String> headers, ComputeCallback<String, R> callback,
      {body, disableTokenValidityCheck = false}) async {
    try {
      var requestBody = jsonEncode(body);
      log('apiURL : $apiURL');
      log('headers : ${jsonEncode(headers)}');
      log('body : $requestBody');
      await checkForValidSession(disableTokenValidityCheck);
      http.Response response = await http.post(Uri.parse(apiURL), body: requestBody, headers: headers).timeout(apiTimeOut);
      if (response != null) {
        return Parser.parseResponse(response, callback);
      }
    } on SocketException {
      return Left(NoInternetError());
    } on TimeoutException {
      return Left(TimeoutError());
    } on HandshakeException {
      return Left(HandshakeError());
    } on SessionExpiry {
      return Left(SessionExpiry());
    }
    return Left(UnknownError());
  }

  @override
  Future<Either<AppException, Q>> callPostAPIForm<Q, R>(String apiURL, Map<String, String> headers, ComputeCallback<String, R> callback,
      {body, required String path, required String imageFieldName, disableTokenValidityCheck = false}) async {
    try {
      log('apiURL : $apiURL');
      log('headers : ${jsonEncode(headers)}');
      log('body : ${jsonEncode(body)}');
      await checkForValidSession(disableTokenValidityCheck);
      var request = http.MultipartRequest("POST", Uri.parse(apiURL));
      request.headers.addAll(headers);
      if (path.isNotEmpty) {
        var multipartFile = await http.MultipartFile.fromPath(imageFieldName, path);
        request.files.add(multipartFile);
      }

      if (body != null) {
        body.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
          print('Key: $key, Value: $value');
        });
      }
      var response = await http.Response.fromStream(await request.send());

      return Parser.parseResponse(response, callback);
    } on SocketException {
      return Left(NoInternetError());
    } on TimeoutException {
      return Left(TimeoutError());
    } on HandshakeException {
      return Left(HandshakeError());
    } on SessionExpiry {
      return Left(SessionExpiry());
    }
  }

  // New method to download the image to the device
  @override
  Future<Either<AppException, String>> downloadImageToDevice(String imageUrl, Map<String, String> headers) async {
    try {
      log('Downloading image from: $imageUrl');
      http.Response response = await http.get(Uri.parse(imageUrl), headers: headers).timeout(apiTimeOut);

      if (response.statusCode == 200) {
        // Get the application documents directory
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/creatoo_QR.jpg';
        final File file = File(filePath);

        // Save the image to the device
        await file.writeAsBytes(response.bodyBytes);
        log('Image saved at: $filePath');
        return Right(filePath);
      } else {
        return Left(ServerError());
      }
    } on SocketException {
      return Left(NoInternetError());
    } on TimeoutException {
      return Left(TimeoutError());
    } on Exception catch (e) {
      log('Error downloading image: $e');
      return Left(UnknownError());
    }
  }

  @override
  Future<Either<AppException, Q>> callPostAPIFormMultipleFiles<Q, R>(
      String apiURL, Map<String, String> headers, ComputeCallback<String, R> callback,
      {body, required List<Map<String, String>> filePaths, disableTokenValidityCheck = true}) async {
    try {
      log('apiURL : $apiURL');
      log('headers : ${jsonEncode(headers)}');
      log('body : ${jsonEncode(body)}');

      await checkForValidSession(disableTokenValidityCheck);
      var request = http.MultipartRequest("POST", Uri.parse(apiURL));
      request.headers.addAll(headers);

      // Add multiple images
      for (var file in filePaths) {
        String fieldName = file["fieldName"]!;
        String filePath = file["filePath"]!;
        if (filePath.isNotEmpty) {
          var multipartFile = await http.MultipartFile.fromPath(fieldName, filePath);
          request.files.add(multipartFile);
        }
      }

      // Add additional form fields
      if (body != null) {
        body.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
      }

      var response = await http.Response.fromStream(await request.send());
      return Parser.parseResponse(response, callback);
    } on SocketException {
      return Left(NoInternetError());
    } on TimeoutException {
      return Left(TimeoutError());
    } on HandshakeException {
      return Left(HandshakeError());
    } on SessionExpiry {
      return Left(SessionExpiry());
    }
  }

  Future<void> checkForValidSession(disableTokenValidityCheck) async {
    if (!disableTokenValidityCheck) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token!);
      print(decodedToken["name"]);
      bool isTokenExpired = await JwtDecoder.isExpired(token!);

      if (isTokenExpired) {
        await Utils.clearLocalData();
      }
    }
  }
}
