import 'package:creatoo/core.dart';
import 'package:creatoo/features/add_post_payment_summary/model/add_post_response_model.dart';
import 'package:creatoo/features/add_post_payment_summary/model/setting_response_model.dart';
import 'package:creatoo/features/auth/model/otp_reponse_model.dart';
import 'package:creatoo/features/bill_payment/model/create_order_response_model.dart';
import 'package:creatoo/features/bill_payment/model/payment_status_response.dart';
import 'package:creatoo/features/bill_payment/model/process_payment_status_response.dart';
import 'package:creatoo/features/business_profile/model/business_description_response_model.dart';
import 'package:creatoo/features/business_profile/model/set_discount_response_model.dart';
import 'package:creatoo/features/category/model/BusinessTypeResponseModel.dart';
import 'package:http/http.dart' as http;

import '../../features/add_post_payment_summary/model/add_business_wallet_transaction_response.dart';
import '../../features/add_post_payment_summary/model/payment_response_model.dart';
import '../../features/bill_payment/model/apply_offers_response_model.dart';
import '../../features/business_profile/model/business_profile_response.dart';
import '../../features/creator_contact/model/creator_contact_response.dart';
import '../../features/creator_home/model/creator_home_response_model.dart';
import '../../features/creator_profile/model/creator_profile_response.dart';
import '../../features/creator_profile/model/insta_verification_response.dart';
import '../../features/creator_wallet/model/creator_creatoo_transaction_response.dart';
import '../../features/creator_wallet/model/creator_wallet_response.dart';
import '../../features/creator_wallet/model/creator_withdraw_balance_response.dart';
import '../../features/earn_creatoo_points/model/business_list_response.dart';
import '../../features/earn_creatoo_points/model/creatoo_points_response.dart';
import '../../features/feedback/model/feedback_response_model.dart';
import '../../features/feedback/model/skip_feedback_response_model.dart';
import '../../features/home/model/home_screen_response_model.dart';
import '../../features/notification/model/notification_response_model.dart';
import '../../features/opportunity/model/opportunity_response_model.dart';
import '../../features/opportunity/model/report_response.dart';
import '../../features/payment_details/model/payment_detail_response.dart';
import '../../features/post/model/release_payment_to_creator.dart';
import '../../features/post/model/view_my_post_response.dart';
import '../../features/post_detail/model/post_detail_response.dart';
import '../../features/qr_pay/model/transfer_points_response_model.dart';
import '../../features/qr_pay/model/validate_points_response_model.dart';
import '../../features/qr_pay/model/view_profile_response_model.dart';
import '../../features/register_business/model/business_type_response.dart';
import '../../features/register_business/model/register_business_response_model.dart';
import '../../features/register_creator/model/register_creator_response%20_model.dart';
import '../../features/register_creator/model/user_insta_response.dart';
import '../../features/review/model/reviews_response_model.dart';
import '../../features/scanner/model/scanner_model_response.dart';
import '../../features/search/model/business_details_response_model.dart';
import '../../features/search/model/search_business_model.dart';
import '../../features/search/model/search_creator_model.dart';
import '../../features/settings/model/logout_model.dart';
import '../../features/shortlist/model/post_application_response.dart';
import '../../features/verify_otp/model/verify_otp_model.dart';
import '../../features/wallet/model/business_wallet_transaction_point_response.dart';
import '../../features/wallet/model/business_wallet_transaction_response.dart';

class Parser {
  static Future<Either<AppException, Q>> parseResponse<Q, R>(http.Response response, ComputeCallback<String, R> callback) async {
    log('callback : ${callback.toString()}');
    log('response.statusCode : ${response.statusCode}');
    log('response.body : ${response.body}');
    String message = "";

    try {
      if (response.statusCode != HttpStatus.ok) {
        dynamic body = jsonDecode(response.body);
        if (body["status"] == HttpStatus.unauthorized) {
          message = body["error"] ?? "";
        } else {
          message = body["message"] ?? "";
        }
      }

      switch (response.statusCode) {
        case HttpStatus.ok || HttpStatus.created:
          {
            dynamic result = await compute(callback, response.body.toString());
            if (result.status == false) {
              return Left(Error(message: result.message));
            }
            return Right(result as Q);
          }
        case HttpStatus.badRequest:
          {
            // Parse the response body
            final body = jsonDecode(response.body);
            final dataValue = body['data']; // Extract the 'data' field
            final message = body['message'] ?? 'Bad request';

            return Left(ForbiddenError(
              statusCode: response.statusCode,
              message: message,
              data: dataValue, // Assign the parsed 'data' value
            ));
          }

        case HttpStatus.unauthorized:
          await Utils.clearLocalData();

          return Left(ForbiddenError(statusCode: response.statusCode, message: message));

        case HttpStatus.forbidden:
          return Left(UnAuthorizedError(statusCode: response.statusCode, message: message));

        case HttpStatus.notFound:
          return Left(ServerError(statusCode: response.statusCode, message: message));
        case HttpStatus.unprocessableEntity:
          return Left(UserExists(statusCode: response.statusCode, message: message));
        case HttpStatus.internalServerError:
          return Left(ServerError(statusCode: response.statusCode, message: message));
        default:
          return Left(UnknownError());
      }
    } catch (e) {
      log(e.toString());
      return Left(UnknownError());
    }
  }

  static Future<OtpResponse> parseLogInResponse(String responseBody) async {
    return OtpResponse.fromJson(json.decode(responseBody));
  }

  static Future<OtpResponse> parseResendOtpResponse(String responseBody) async {
    return OtpResponse.fromJson(json.decode(responseBody));
  }

  static Future<VerifyOtpResponse> parseVerifyOtpResponse(String responseBody) async {
    return VerifyOtpResponse.fromJson(json.decode(responseBody));
  }

  static Future<RegisterCreatorResponse> parseRegisterCreatorResponse(String responseBody) async {
    return RegisterCreatorResponse.fromJson(json.decode(responseBody));
  }

  static Future<UserInstaResponse> parseUserInstaResponse(String responseBody) async {
    return UserInstaResponse.fromJson(json.decode(responseBody));
  }

  static Future<RegisterBusinessResponse> parseRegisterBusinessResponse(String responseBody) async {
    return RegisterBusinessResponse.fromJson(json.decode(responseBody));
  }

  static Future<HomeDataResponse> parseHomeDataResponse(String responseBody) async {
    return HomeDataResponse.fromJson(json.decode(responseBody));
  }

  static Future<SearchBusinessResponse> parseSearchBusinessResponse(String responseBody) async {
    return SearchBusinessResponse.fromJson(json.decode(responseBody));
  }

  static Future<SearchCreatorResponse> parseSearchCreatorResponse(String responseBody) async {
    return SearchCreatorResponse.fromJson(json.decode(responseBody));
  }

  static Future<LogoutResponse> parseLogoutResponse(String responseBody) async {
    return LogoutResponse.fromJson(json.decode(responseBody));
  }

  static Future<LogoutResponse> parseInactiveUserResponse(String responseBody) async {
    return LogoutResponse.fromJson(json.decode(responseBody));
  }

  static Future<ViewMyPostResponse> parseViewMyPostResponse(String responseBody) async {
    return ViewMyPostResponse.fromJson(json.decode(responseBody));
  }

  static Future<BusinessProfileResponse> parseBusinessProfileResponse(String responseBody) async {
    return BusinessProfileResponse.fromJson(json.decode(responseBody));
  }

  static Future<CreatorProfileResponse> parseCreatorProfileResponse(String responseBody) async {
    return CreatorProfileResponse.fromJson(json.decode(responseBody));
  }

  static Future<BusinessProfileResponse> parseUpdateBusinessProfileResponse(String responseBody) async {
    return BusinessProfileResponse.fromJson(json.decode(responseBody));
  }

  static Future<CreatorProfileResponse> parseUpdateCreatorProfileResponse(String responseBody) async {
    return CreatorProfileResponse.fromJson(json.decode(responseBody));
  }

  static Future<InstaVerificationResponse> parseInstaVerificationResponse(String responseBody) async {
    return InstaVerificationResponse.fromJson(json.decode(responseBody));
  }

  static Future<BusinessTypeResponse> parseGetBusinessTypesResponse(String responseBody) async {
    return BusinessTypeResponse.fromJson(json.decode(responseBody));
  }

  static Future<BusinessWalletTransactionResponse> parseBusinessWalletTransactionsResponse(String responseBody) async {
    return BusinessWalletTransactionResponse.fromJson(json.decode(responseBody));
  }

  static Future<AddPostResponseModel> parseAddPostResponse(String responseBody) async {
    return AddPostResponseModel.fromJson(jsonDecode(responseBody));
  }

  static Future<PaymentResponse> parseRazorpayPaymentResponse(String responseBody) async {
    return PaymentResponse.fromJson(json.decode(responseBody));
  }

  static Future<PostApplicationResponse> parsePostApplicationListResponse(String responseBody) async {
    return PostApplicationResponse.fromJson(json.decode(responseBody));
  }

  static Future<BaseResponse> parseAddCreatorToCartResponse(String responseBody) async {
    return BaseResponse.fromJson(json.decode(responseBody));
  }

  static Future<BaseResponse> parseShortlistCreatorResponse(String responseBody) async {
    return BaseResponse.fromJson(json.decode(responseBody));
  }

  static Future<SettingResponse> parseSettingResponse(String responseBody) async {
    return SettingResponse.fromJson(json.decode(responseBody));
  }

  static Future<ReleasePaymentToCreatorResponse> parseReleasePaymentToCreatorResponse(String responseBody) async {
    return ReleasePaymentToCreatorResponse.fromJson(json.decode(responseBody));
  }

  static Future<CreatorHomeResponse> parseCreatorHomeResponse(String responseBody) async {
    return CreatorHomeResponse.fromJson(json.decode(responseBody));
  }

  static Future<OpportunityResponse> parsePostApplicationsResponse(String responseBody) async {
    return OpportunityResponse.fromJson(json.decode(responseBody));
  }

  static Future<BaseResponse> parsePostInterestResponse(String responseBody) async {
    return BaseResponse.fromJson(json.decode(responseBody));
  }

  static Future<CreatorWalletTransactionResponse> parseCreatorWalletTransactionResponse(String responseBody) async {
    return CreatorWalletTransactionResponse.fromJson(json.decode(responseBody));
  }

  static Future<CreatorWithdrawBalanceResponse> parseCreatorWithdrawBalanceResponse(String responseBody) async {
    return CreatorWithdrawBalanceResponse.fromJson(json.decode(responseBody));
  }

  static Future<PostDetailResponse> parsePostDetailResponse(String responseBody) async {
    return PostDetailResponse.fromJson(json.decode(responseBody));
  }

  static Future<CreatorCreatooPointTransactionResponse> parseCreatorCreatooPointTransactionResponse(String responseBody) async {
    return CreatorCreatooPointTransactionResponse.fromJson(json.decode(responseBody));
  }

  static Future<AddBusinessWalletTransactionResponse> parseAddBusinessWalletTransactionResponse(String responseBody) async {
    return AddBusinessWalletTransactionResponse.fromJson(json.decode(responseBody));
  }

  static Future<BusinessListResponse> parseBusinessListResponse(String responseBody) async {
    return BusinessListResponse.fromJson(json.decode(responseBody));
  }

  static Future<CreatooPointsResponse> parseCreatooPointsResponse(String responseBody) async {
    return CreatooPointsResponse.fromJson(json.decode(responseBody));
  }

  ///
  static Future<BusinessWalletTransactionPointResponse> parseBusinessCreatooPointsReponse(String responseBody) async {
    return BusinessWalletTransactionPointResponse.fromJson(json.decode(responseBody));
  }

  static Future<PaymentDetailResponse> parsePaymentDetailResponse(String responseBody) async {
    return PaymentDetailResponse.fromJson(json.decode(responseBody));
  }

  static Future<ReportResponse> parseReportResponse(String responseBody) async {
    return ReportResponse.fromJson(json.decode(responseBody));
  }

  static Future<CreatorContactResponse> parseCreatorContactResponse(String responseBody) async {
    return CreatorContactResponse.fromJson(json.decode(responseBody));
  }

  static Future<ViewProfileResponseModel> parseViewProfileResponse(String responseBody) async {
    return ViewProfileResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<ScannerModelResponse> parseBusinessSettingResponse(String responseBody) async {
    return ScannerModelResponse.fromJson(json.decode(responseBody));
  }

  static Future<ValidatePointsResponseModel> parseValidatePointsResponse(String responseBody) async {
    return ValidatePointsResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<TransferPointsResponseModel> parseTransferPointsResponse(String responseBody) async {
    return TransferPointsResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<BusinessTypeResponseModel> parseGetBusinessTypesResponseNew(String responseBody) async {
    return BusinessTypeResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<BusinessDetailsResponseModel> parseGetBusinessDetailsResponse(String responseBody) async {
    return BusinessDetailsResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<SetDiscountResponseModel> parseSetDiscountResponse(String responseBody) async {
    return SetDiscountResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<BusinessDescriptionResponseModel> parseSetBusinessDescriptionResponse(String responseBody) async {
    return BusinessDescriptionResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<FeedbackResponseModel> parseFeedbackResponse(String responseBody) async {
    return FeedbackResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<SkipFeedbackResponseModel> parseSkipFeedbackResponse(String responseBody) async {
    return SkipFeedbackResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<NotificationResponseModel> parseNotificationResponse(String responseBody) async {
    return NotificationResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<CreateOrderResponseModel> parseCreateOrderResponse(String responseBody) async {
    return CreateOrderResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<PaymentStatusResponse> parsePaymentStatusResponse(String responseBody) async {
    return PaymentStatusResponse.fromJson(json.decode(responseBody));
  }

  static Future<ApplyOffersResponseModel> parseApplyOffersResponse(String responseBody) async {
    return ApplyOffersResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<ReviewsResponseModel> parseReviewsResponse(String responseBody) async {
    return ReviewsResponseModel.fromJson(json.decode(responseBody));
  }

  static Future<ProcessPaymentStatusResponse> parseProcessPaymentStatusResponse(String responseBody) async {
    return ProcessPaymentStatusResponse.fromJson(json.decode(responseBody));
  }
}
