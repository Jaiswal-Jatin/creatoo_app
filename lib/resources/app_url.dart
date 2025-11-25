String baseUrl = "${AppUrl.host}/storage/app/";

class AppUrl {
  // Base URLs
       static const String host = 'https://api.tapbill.in';
    // static const String host = 'https://portal.creatoo.co.in';



  static const String baseUrl = '$host/api';
  static const String razorpayOrderId = 'https://api.razorpay.com/v1/orders';

  // Authentication Endpoints
  // static const String creatorLogin = '$baseUrl/creatorLogin';
  // static const String resendCreatorOtp = '$baseUrl/resendCreatorOtp';
  // static const String businessLogin = '$baseUrl/businessLogin';
  // static const String resendBusinessOtp = '$baseUrl/resendBusinessOtp';
  // static const String registerBusiness = '$baseUrl/businessRegister';
  // static const String registerCreator = '$baseUrl/creatorRegister';


  // New api endpoints
  static const String creatorLogin = '$baseUrl/auth/creatorLogin';
  static const String resendCreatorOtp = '$baseUrl/auth/resendCreatorOtp';
  static const String verifyCreatorOtp = '$baseUrl/auth/verifyCreatorOtp';
  static const String businessLogin = '$baseUrl/auth/businessLogin';
  static const String resendBusinessOtp = '$baseUrl/auth/resendBusinessOtp';
  static const String verifyBusinessOtp = '$baseUrl/auth/verifyBusinessOtp';
  static const String registerBusiness = '$baseUrl/auth/businessRegister';
  static const String registerCreator = '$baseUrl/auth/creatorRegister';



  static const String logout = '$baseUrl/auth/logout';
  static const String inactiveUser = '$baseUrl/inactiveUser';

  // User Profile Endpoints
  static const String viewProfile = '$baseUrl/viewProfile';
  static const String editBusinessProfile = '$baseUrl/editBusinessProfile';
  static const String editCreatorProfile = '$baseUrl/editCreatorProfile';
  static const String instaVerificationApi = '$baseUrl/submitInstaVerification';
  static const String fetchInstaUser = '$baseUrl/fetchInstaUser';
  static const String creatorContactApi = '$baseUrl/getCreatorContact';

  // Home & Search Endpoints
  // static const String homeData = '$baseUrl/getHomeData';
    static const String homeData = '$baseUrl/home/getHomeData';

  static const String creatorHomeApi = '$baseUrl/getCreatorHome';
  static const String searchUser = '$baseUrl/searchUser';
  static const String searchBusinessAndCreator = '$baseUrl/searchBusinessAndCreator';
  static const String getBusinessListApi = '$baseUrl/getBusinessList';
  // static const String getBusinessTypes = '$baseUrl/getBusinessTypes';
    static const String getBusinessTypes = '$baseUrl/businessType/getBusinessTypes';


  // Post & Opportunities Endpoints
  static const String viewMyPost = '$baseUrl/myPost';
  static const String addPost = '$baseUrl/addPost';
  static const String getPostOpportunitiesApi = '$baseUrl/getAllOpportunities';
  static const String opportunityDetailsApi = '$baseUrl/getOpportunityDetails';
  static const String postInterestApi = '$baseUrl/postInterest';
  static const String postReportRequestApi = '$baseUrl/postReportRequest';
  static const String getPostApplicationList = '$baseUrl/getPostApplicationList';

  // Payment & Wallet Endpoints
  static const String businessWalletTransaction = '$baseUrl/businessWalletTransaction';
  static const String creatorWalletTransaction = '$baseUrl/creatorWalletTransaction';
  static const String addBusinessWalletTransactionApi = '$baseUrl/addBusinessWalletTransaction';
  static const String creatorWithdrawRequestApi = '$baseUrl/creatorWithdrawRequest';
  static const String paymentDetailsApi = '$baseUrl/paymentDetails';
  static const String getPaymentDetailApi = '$baseUrl/getPaymentDetail';
  static const String releasePaymentToCreatorApi = '$baseUrl/paymentReleaseToCreator';
  static const String postPaymentStatus = '$baseUrl/postPaymentStatus';
  static const String paymentStatus = '$baseUrl/paymentSuccess';
  
  // Creatoo Points Endpoints
  static const String creatooPointsTransactionApi = '$baseUrl/creatooPointsTransaction';
  static const String businessPointsTransaction = '$baseUrl/businessPointsTransaction';
  static const String validatePointsApi = '$baseUrl/validateCreatooPoints';
  static const String transferPointsApi = '$baseUrl/transferCreatooPoints';

  // Business Settings Endpoints
  static const String businessSetting = '$baseUrl/businessSetting';
  static const String getBusinessSetting = '$baseUrl/getBusinessSetting';
  static const String editBusinessDiscount = '$baseUrl/setDiscount';
  static const String editBusinessDescription = '$baseUrl/businessDescription';

  // Cart & Shortlist Endpoints
  static const String addCreatorToCart = '$baseUrl/addCart';
  static const String shortlistCreator = '$baseUrl/addShortlist';

  // Order & Checkout Endpoints
  static const String createOrderApi = '$baseUrl/createOrder';
  static const String applyOffers = '$baseUrl/applyOffers';
  static const String processPayment = '$baseUrl/processPayment';
  static const String checkTransactionStatus = '$baseUrl/checkTransactionStatus';

  // Review & Feedback Endpoints
  static const String sendFeedback = '$baseUrl/reviewSubmit';
  static const String skipFeedback = '$baseUrl/skipReview';
  static const String reviewList = '$baseUrl/ListOfAllReview';

  // Notification Endpoint
  static const String getNotificationApi = '$baseUrl/NewNotificationList';

  // Other Endpoints
  static const String settingApi = '$baseUrl/setting';
  static const String creatooRequestApi = '$baseUrl/creatooRequest';
}
