String baseUrl = "${AppUrl.host}/storage/app/";

class AppUrl {
  // Base URLs

 
  // static const String host = 'http://dev-api.creatoo.co.in';
  static const String host = 'http://192.168.29.40:3000';
  // static const String host = 'https://api.creatoo.co.in';



  static const String baseUrl = '$host/api';
  static const String razorpayOrderId = 'https://api.razorpay.com/v1/orders';

  // New api endpoints

  //auth endpoints
  static const String creatorLogin = '$baseUrl/auth/creatorLogin'; //done
  static const String resendCreatorOtp =
      '$baseUrl/auth/resendCreatorOtp'; //done
  static const String verifyCreatorOtp =
      '$baseUrl/auth/verifyCreatorOtp'; //done
  static const String businessLogin = '$baseUrl/auth/businessLogin'; //done
  static const String resendBusinessOtp =
      '$baseUrl/auth/resendBusinessOtp'; //done
  static const String verifyBusinessOtp =
      '$baseUrl/auth/verifyBusinessOtp'; //done
  static const String registerBusiness =
      '$baseUrl/auth/businessRegister'; //done
  static const String registerCreator = '$baseUrl/auth/creatorRegister'; //done
  static const String logout = '$baseUrl/auth/logout'; //done
  static const String inactiveUser = '$baseUrl/users/inactiveUser';
  static const String getBusinessByUpiId = '$baseUrl/users/getBusinessByUpiId';

  // User Profile Endpoints
  static const String viewProfile = '$baseUrl/auth/viewProfile'; //done
  static const String editBusinessProfile =
      '$baseUrl/auth/editBusinessProfile'; //done
  static const String editCreatorProfile =
      '$baseUrl/auth/editCreatorProfile'; //done
  static const String instaVerificationApi = '$baseUrl/submitInstaVerification';
  static const String fetchInstaUser = '$baseUrl/fetchInstaUser';
  static const String creatorContactApi = '$baseUrl/home/getCreatorContact';

  // Home & Search Endpoints
  static const String homeData = '$baseUrl/home/getHomeData'; //done
  static const String creatorHomeApi = '$baseUrl/home/getCreatorHome'; //done
  static const String searchUser = '$baseUrl/users/search'; //done
  static const String searchBusinessAndCreator =
      '$baseUrl/users/searchBusinessAndCreator'; //done
  static const String turfOptions = '$baseUrl/turf/options';
  static const String getMyExclusiveOffers = '$baseUrl/exclusiveOffer/by-business';
  static const String saveExclusiveOffers = '$baseUrl/exclusiveOffer/save';
  static const String getBusinessListApi = '$baseUrl/business/getBusinessList';
  static const String getBusinessTypes =
      '$baseUrl/businessType/getBusinessTypes'; //done

//card api
  static const String cardCheck = '$baseUrl/cards/check'; // done
  static const String activeCard = '$baseUrl/cards/verify'; //done
  static const String autoAssignCard = '$baseUrl/cards/auto-assign'; //done
  static const String todayVisitCount = '$baseUrl/visit/today-count'; //done
  static const String visitByRestaurant = '$baseUrl/visit/user-history'; //done
  static const String userTierHistory =
      '$baseUrl/visit/user-all-history'; //done
  static const String visitCheck = '$baseUrl/visit?'; //done
  static const String Addvisit = '$baseUrl/visit'; //done
  static const String busineesHistory =
      '$baseUrl/visit/history?mobile=true'; //done
  static const String businessVisits =
      '$baseUrl/visit/business-visits';

  // Post & Opportunities Endpoints
  static const String viewMyPost = '$baseUrl/post/myPost';
  static const String addPost = '$baseUrl/post/add';
  static const String postInterestApi = '$baseUrl/post/postInterest';
  static const String postReportRequestApi = '$baseUrl/post/postReportRequest';
  static const String getPostApplicationList =
      '$baseUrl/post/getPostApplicationList';
  static const String getPostOpportunitiesApi =
      '$baseUrl/opportunity/getAllOpportunities';
  static const String opportunityDetailsApi =
      '$baseUrl/opportunity/getOpportunityDetails';

  // Payment & Wallet Endpoints
  static const String businessWalletTransaction =
      '$baseUrl/walletTransaction/businessWalletTransaction'; //done
  static const String creatorWalletTransaction =
      '$baseUrl/walletTransaction/creatorWalletTransaction'; //done
  static const String addBusinessWalletTransactionApi =
      '$baseUrl/walletTransaction/addBusinessWalletTransaction';
  static const String creatorWithdrawRequestApi =
      '$baseUrl/WithdrawRequest/add';
  static const String paymentDetailsApi = '$baseUrl/payment/paymentDetails';
  static const String getPaymentDetailApi = '$baseUrl/payment/getPaymentDetail';
  static const String releasePaymentToCreatorApi =
      '$baseUrl/payment/paymentReleaseToCreator';
  static const String postPaymentStatus = '$baseUrl/post/postPaymentStatus';
  static const String paymentStatus = '$baseUrl/payment/paymentSuccess';

  // Manual Payment Endpoints
  static const String manualCalculatePayment = '$baseUrl/manual-payment/calculatePayment';
  static const String manualSubmitPayment = '$baseUrl/manual-payment/submitPayment';
  static const String manualConfirmPayment = '$baseUrl/manual-payment/confirmPayment';
  static const String manualCancelPayment = '$baseUrl/manual-payment/cancelPayment';
  static const String manualBusinessPayments = '$baseUrl/manual-payment/businessPayments';
  static const String manualBusinessPaymentStats = '$baseUrl/manual-payment/businessPaymentStats';
  static const String manualBusinessWalletPayments = '$baseUrl/manual-payment/businessWalletPayments';
  static const String manualUserPayments = '$baseUrl/manual-payment/userPayments';
  static const String manualSetPaymentPaidAt = '$baseUrl/manual-payment/setPaymentPaidAt';

  // Creatoo Points Endpoints
  static const String creatooPointsTransactionApi =
      '$baseUrl/points/creatooPointsTransaction'; //done
  static const String businessPointsTransaction =
      '$baseUrl/points/businessPointsTransaction'; //done
  static const String validatePointsApi =
      '$baseUrl/points/validateCreatooPoints';
  static const String transferPointsApi =
      '$baseUrl/points/transferCreatooPoints';

  // Business Settings Endpoints
  static const String businessSetting = '$baseUrl/setting/businessSetting';
  static const String getBusinessSetting =
      '$baseUrl/setting/getBusinessSetting';
  static const String editBusinessDiscount = '$baseUrl/business/setDiscount';
  static const String editBusinessDescription =
      '$baseUrl/business/businessDescription';
  static const String getBusinessSubscription =
      '$baseUrl/subscription/business/current';

  // Cart & Shortlist Endpoints
  static const String addCreatorToCart = '$baseUrl/cart/addCart';
  static const String shortlistCreator = '$baseUrl/cart/addShortlist';

  // Order & Checkout Endpoints
  static const String createOrderApi = '$baseUrl/web/createOrder';
  static const String applyOffers = '$baseUrl/web/applyOffers';
  static const String processPayment = '$baseUrl/payment/processPayment';
  static const String checkTransactionStatus =
      '$baseUrl/walletTransaction/checkTransactionStatus';

  // Review & Feedback Endpoints
  static const String sendFeedback = '$baseUrl/review/reviewSubmit';
  static const String skipFeedback = '$baseUrl/review/skipReview';
  static const String reviewList = '$baseUrl/review/ListOfAllReview';

  // Notification Endpoint
  static const String getNotificationApi =
      '$baseUrl/web/NewNotificationList'; //done

  // Other Endpoints
  static const String settingApi = '$baseUrl/setting/setting';
  static const String creatooRequestApi = '$baseUrl/creatooRequest';

//version verify
  static const String versionVerify = '$baseUrl/version/verify';

  // Settlement / Wallet Endpoints
  static const String businessWalletSummary = '$baseUrl/settlement/business/summary';
  static const String businessWalletTransactions = '$baseUrl/settlement/business/transactions';
  static const String businessSettlementHistory = '$baseUrl/settlement/business/history';
  static const String businessAdvancePayments = '$baseUrl/settlement/business/advance-payments';

  // Booking Endpoints
  static const String createBookingRequest = '$baseUrl/booking/create';
  static const String bookingUserHistory = '$baseUrl/booking/user-history';
  static const String businessBookingList = '$baseUrl/booking/business-list';
  static const String updateBookingStatus = '$baseUrl/booking/update-status';
  static const String cancelBooking = '$baseUrl/booking/cancel';
  static const String createAdvanceOrder = '$baseUrl/booking/create-advance-order';
  static const String verifyAdvancePayment = '$baseUrl/booking/verify-advance-payment';
  static const String advancePaymentSettings = '$baseUrl/setting/advance-payment/public';

  //Exclusive Offers
  static const String getExclusiveOffers =
      '$baseUrl/exclusiveOffer/by-business/:id';

  //old api endpoints

  // Authentication Endpoints
  // static const String creatorLogin = '$baseUrl/creatorLogin';
  // static const String resendCreatorOtp = '$baseUrl/resendCreatorOtp';
  // static const String businessLogin = '$baseUrl/businessLogin';
  // static const String resendBusinessOtp = '$baseUrl/resendBusinessOtp';
  // static const String registerBusiness = '$baseUrl/businessRegister';
  // static const String registerCreator = '$baseUrl/creatorRegister';
  // static const String logout = '$baseUrl/logout';
  // static const String inactiveUser = '$baseUrl/inactiveUser';

  // User Profile Endpoints
  // static const String viewProfile = '$baseUrl/auth/viewProfile';
  // static const String editBusinessProfile = '$baseUrl/editBusinessProfile';
  // static const String editCreatorProfile ='$baseUrl/editCreatorProfile';
  //  static const String instaVerificationApi = '$baseUrl/submitInstaVerification';
  //   static const String fetchInstaUser = '$baseUrl/fetchInstaUser';
  //   static const String creatorContactApi = '$baseUrl/getCreatorContact';

  // Home & Search Endpoints
  // static const String homeData = '$baseUrl/getHomeData';
  // static const String creatorHomeApi = '$baseUrl/home/getCreatorHome';
  // static const String searchUser = '$baseUrl/searchUser';
  // static const String searchBusinessAndCreator = '$baseUrl/searchBusinessAndCreator';
  // static const String getBusinessTypes = '$baseUrl/getBusinessTypes';
  //  static const String getBusinessListApi = '$baseUrl/getBusinessList';

  // Post & Opportunities Endpoints
  // static const String viewMyPost = '$baseUrl/myPost';
  // static const String addPost = '$baseUrl/addPost';
  // static const String getPostOpportunitiesApi = '$baseUrl/getAllOpportunities';
  // static const String opportunityDetailsApi = '$baseUrl/getOpportunityDetails';
  // static const String postInterestApi = '$baseUrl/postInterest';
  // static const String postReportRequestApi = '$baseUrl/postReportRequest';
  // static const String getPostApplicationList ='$baseUrl/getPostApplicationList';

  // Payment & Wallet Endpoints
  // static const String businessWalletTransaction ='$baseUrl/businessWalletTransaction';
  // static const String creatorWalletTransaction = '$baseUrl/creatorWalletTransaction';
  // static const String addBusinessWalletTransactionApi ='$baseUrl/addBusinessWalletTransaction';
  // static const String creatorWithdrawRequestApi ='$baseUrl/creatorWithdrawRequest';
  // static const String paymentDetailsApi = '$baseUrl/paymentDetails';
  // static const String getPaymentDetailApi = '$baseUrl/getPaymentDetail';
  // static const String releasePaymentToCreatorApi ='$baseUrl/paymentReleaseToCreator';
  // static const String postPaymentStatus = '$baseUrl/postPaymentStatus';
  // static const String paymentStatus = '$baseUrl/paymentSuccess';

  // Creatoo Points Endpoints
  // static const String creatooPointsTransactionApi = '$baseUrl/creatooPointsTransaction';
  // static const String businessPointsTransaction = '$baseUrl/businessPointsTransaction';
  // static const String validatePointsApi = '$baseUrl/validateCreatooPoints';
  // static const String transferPointsApi = '$baseUrl/transferCreatooPoints';

  // Business Settings Endpoints
  // static const String businessSetting = '$baseUrl/businessSetting';
  // static const String getBusinessSetting = '$baseUrl/getBusinessSetting';
  // static const String editBusinessDiscount = '$baseUrl/setDiscount';
  // static const String editBusinessDescription = '$baseUrl/businessDescription';

  // Cart & Shortlist Endpoints
  // static const String addCreatorToCart = '$baseUrl/addCart';
  // static const String shortlistCreator = '$baseUrl/addShortlist';

  // Order & Checkout Endpoints
  // static const String createOrderApi = '$baseUrl/createOrder';
  // static const String applyOffers = '$baseUrl/applyOffers';
  // static const String processPayment = '$baseUrl/processPayment';
  // static const String checkTransactionStatus ='$baseUrl/checkTransactionStatus';

  // Review & Feedback Endpoints
  // static const String sendFeedback = '$baseUrl/reviewSubmit';
  // static const String skipFeedback = '$baseUrl/skipReview';
  // static const String reviewList = '$baseUrl/ListOfAllReview';

  // Notification Endpoint
  // static const String getNotificationApi = '$baseUrl/NewNotificationList';

  // Other Endpoints
  // static const String settingApi = '$baseUrl/setting';
  // static const String creatooRequestApi = '$baseUrl/creatooRequest';
}
