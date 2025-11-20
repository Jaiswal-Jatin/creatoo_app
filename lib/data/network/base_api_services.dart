import '../../core.dart';

abstract class BaseApiServices {
  Future<Either<AppException, Q>> callPostAPI<Q, R>(String apiURL, Map<String, String> headers, ComputeCallback<String, R> callback,
      {body, disableTokenValidityCheck = false});

  Future<Either<AppException, Q>> callGetAPI<Q, R>(String apiURL, Map<String, String> headers, ComputeCallback<String, R> callback,
      {disableTokenValidityCheck = false});

  Future<Either<AppException, Q>> callPostAPIForm<Q, R>(String apiURL, Map<String, String> headers, ComputeCallback<String, R> callback,
      {body, required String path, required String imageFieldName, disableTokenValidityCheck = true});

  Future<Either<AppException, String>> downloadImageToDevice(String imageUrl, Map<String, String> headers);

  Future<Either<AppException, Q>> callPostAPIFormMultipleFiles<Q, R>(
      String apiURL, Map<String, String> headers, ComputeCallback<String, R> callback,
      {body, required List<Map<String, String>> filePaths, disableTokenValidityCheck = true});
}
