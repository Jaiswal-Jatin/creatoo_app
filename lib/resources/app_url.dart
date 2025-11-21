String baseUrl = "${AppUrl.host}/storage/app/";

class AppUrl {
  //TODO: Change Url before Deploying

//old - will be removed later
  // static const String host = 'https://staging.creatoo.co.in';
  // static const String host = 'http://192.168.0.36:8000';

  static const String host = 'https://portal.creatoo.co.in';
  // static const String host = 'https://api.tapbill.in/api'; 



  static const String baseUrl = '$host/api';
  static const String razorpayOrderId = 'https://api.razorpay.com/v1/orders';

// // New api endpoints
//   static const String creatorLogin = '$baseUrl/auth/creatorLogin';
//   static const String resendCreatorOtp = '$baseUrl/auth/resendCreatorOtp';
//   static const String businessLogin = '$baseUrl/auth/businessLogin';
//   static const String resendBusinessOtp = '$baseUrl/auth/resendBusinessOtp';
//   static const String registerBusiness = '$baseUrl/auth/businessRegister';
//   static const String registerCreator = '$baseUrl/auth/creatorRegister';

// old api endpoints 
  static const String creatorLogin = '$baseUrl/creatorLogin';
  static const String resendCreatorOtp = '$baseUrl/resendCreatorOtp';
  static const String businessLogin = '$baseUrl/businessLogin';
  static const String resendBusinessOtp = '$baseUrl/resendBusinessOtp';
  static const String registerBusiness = '$baseUrl/businessRegister';
  static const String registerCreator = '$baseUrl/creatorRegister';


  static const String fetchInstaUser = '$baseUrl/fetchInstaUser';
  static const String homeData = '$baseUrl/getHomeData';
  static const String searchUser = '$baseUrl/searchUser';
  static const String searchBusinessAndCreator = '$baseUrl/searchBusinessAndCreator';
  static const String inactiveUser = '$baseUrl/inactiveUser';
  static const String logout = '$baseUrl/logout';
  static const String viewMyPost = '$baseUrl/myPost';
  static const String viewProfile = '$baseUrl/viewProfile';
  static const String editBusinessProfile = '$baseUrl/editBusinessProfile';
  static const String editCreatorProfile = '$baseUrl/editCreatorProfile';
  static const String instaVerificationApi = '$baseUrl/submitInstaVerification';
  static const String getBusinessTypes = '$baseUrl/getBusinessTypes';
  static const String businessWalletTransaction = '$baseUrl/businessWalletTransaction';
  static const String addPost = '$baseUrl/addPost';
  static const String postPaymentStatus = '$baseUrl/postPaymentStatus';
  static const String getPostApplicationList = '$baseUrl/getPostApplicationList';
  static const String addCreatorToCart = '$baseUrl/addCart';
  static const String shortlistCreator = '$baseUrl/addShortlist';
  static const String settingApi = '$baseUrl/setting';
  static const String releasePaymentToCreatorApi = '$baseUrl/paymentReleaseToCreator';
  static const String creatorHomeApi = '$baseUrl/getCreatorHome';
  static const String getPostOpportunitiesApi = '$baseUrl/getAllOpportunities';
  static const String postReportRequestApi = '$baseUrl/postReportRequest';
  static const String postInterestApi = '$baseUrl/postInterest';
  static const String opportunityDetailsApi = '$baseUrl/getOpportunityDetails';
  static const String creatorWalletTransaction = '$baseUrl/creatorWalletTransaction';
  static const String creatorWithdrawRequestApi = '$baseUrl/creatorWithdrawRequest';
  static const String creatooPointsTransactionApi = '$baseUrl/creatooPointsTransaction';
  static const String addBusinessWalletTransactionApi = '$baseUrl/addBusinessWalletTransaction';
  static const String getBusinessListApi = '$baseUrl/getBusinessList';
  static const String creatooRequestApi = '$baseUrl/creatooRequest';
  static const String paymentDetailsApi = '$baseUrl/paymentDetails';
  static const String getPaymentDetailApi = '$baseUrl/getPaymentDetail';
  static const String creatorContactApi = '$baseUrl/getCreatorContact';
  static const String validatePointsApi = '$baseUrl/validateCreatooPoints';
  static const String transferPointsApi = '$baseUrl/transferCreatooPoints';
  static const String businessPointsTransaction = '$baseUrl/businessPointsTransaction';
  static const String businessSetting = '$baseUrl/businessSetting';
  static const String getBusinessSetting = '$baseUrl/getBusinessSetting';
  static const String editBusinessDiscount = '$baseUrl/setDiscount';
  static const String editBusinessDescription = '$baseUrl/businessDescription';
  static const String sendFeedback = '$baseUrl/reviewSubmit';
  static const String skipFeedback = '$baseUrl/skipReview';
  static const String getNotificationApi = '$baseUrl/NewNotificationList';
  static const String createOrderApi = '$baseUrl/createOrder';
  static const String applyOffers = '$baseUrl/applyOffers';
  static const String paymentStatus = '$baseUrl/paymentSuccess';
  static const String reviewList = '$baseUrl/ListOfAllReview';
  static const String processPayment = '$baseUrl/processPayment';
  static const String checkTransactionStatus = '$baseUrl/checkTransactionStatus';
}
