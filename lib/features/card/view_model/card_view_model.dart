import 'package:creatoo/core.dart';
import 'package:creatoo/data/response/api_response.dart';
import 'package:creatoo/features/card/data/activate_card_request_model.dart';
import 'package:creatoo/features/card/data/activate_card_response_model.dart'; // Import the new response model
import 'package:creatoo/features/card/data/card_check_response_model.dart';
import 'package:creatoo/features/card/data/user_tier_history_response_model.dart';
import 'package:creatoo/features/card/repository/card_repository.dart';
import 'package:creatoo/widgets/status_dialog.dart'; // Import the custom status dialog

class CardViewModel with ChangeNotifier {
  final CardRepository _myRepo = CardRepository();

  ApiResponse<ActivateCardResponseModel> activeCardResponse =
      ApiResponse.initial();
  ApiResponse<CardCheckResponseModel> cardCheckResponse = ApiResponse.initial();
  ApiResponse<UserTierHistoryResponseModel> userTierHistoryResponse =
      ApiResponse.initial();

  ActivateCardResponseModel?
      _activatedCard; // Property to store activated card data
  CardData? _cardData; // Property to store card data from check

  ActivateCardResponseModel? get activatedCard => _activatedCard;
  CardData? get cardData => _cardData;

  setActivatedCard(ActivateCardResponseModel? card) {
    _activatedCard = card;
    if (card != null) {
      _cardData = CardData(
        cardNumber: card.cardNumber?.toString(),
        name: card.name,
        status: card.status == true ? 'active' : 'inactive',
        userId: card.userId,
      );
    }
    notifyListeners();
  }

  setCardData(CardData? card) {
    _cardData = card;
    notifyListeners();
  }

  setActivateCardResponse(ApiResponse<ActivateCardResponseModel> response) {
    activeCardResponse = response;
    notifyListeners();
  }

  setCardCheckResponse(ApiResponse<CardCheckResponseModel> response) {
    cardCheckResponse = response;
    if (response.data?.status == true && response.data?.data != null) {
      _cardData = response.data!.data;
    }
    notifyListeners();
  }

  setUserTierHistoryResponse(
      ApiResponse<UserTierHistoryResponseModel> response) {
    if (userTierHistoryResponse != response) {
      userTierHistoryResponse = response;
      // Use postFrameCallback to avoid setState during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) {
          notifyListeners();
        }
      });
    }
  }

  Future<void> activeCard(
      BuildContext context, ActivateCardRequestModel requestBody) async {
    setActivateCardResponse(ApiResponse.loading());
    _myRepo.activeCardApi(requestBody).then((value) {
      value.fold(
        (l) {
          setActivateCardResponse(ApiResponse.error(l.message));
          showStatusDialog(
            context,
            DialogStatus.error,
            l.message.toString(),
            title: "Activation Failed",
          );
        },
        (r) {
          if (r.status == true) {
            Navigator.pop(context);
            setActivateCardResponse(ApiResponse.completed(r));
            setActivatedCard(r);
            showStatusDialog(
              context,
              DialogStatus.success,
              r.message.toString(),
              title: "Card Activated",
            );
          } else {
            Navigator.pop(context);
            setActivateCardResponse(ApiResponse.error(r.message.toString()));
            showStatusDialog(
              context,
              DialogStatus.error,
              r.message.toString(),
              title: "Activation Failed",
            );
          }
        },
      );
    });
  }

  Future<void> checkCard(BuildContext context) async {
    setCardCheckResponse(ApiResponse.loading());
    try {
      final result = await _myRepo.checkCardApi();
      result.fold(
        (l) {
          setCardCheckResponse(ApiResponse.error(l.message));
          // Don't show error dialog for "no card" case, just log it
          debugPrint('Card check failed: ${l.message}');
        },
        (r) {
          if (r.status == true && r.data != null) {
            setCardCheckResponse(ApiResponse.completed(r));
            setCardData(r.data);
          } else {
            setCardCheckResponse(ApiResponse.completed(r));
            // Clear card data if no active card
            setCardData(null);
          }
        },
      );
    } catch (e) {
      setCardCheckResponse(ApiResponse.error(e.toString()));
      debugPrint('Error checking card: $e');
    }
  }

  Future<void> getUserTierHistory() async {
    try {
      // Only update if not already loading to avoid unnecessary rebuilds
      if (userTierHistoryResponse.status != Status.loading) {
        setUserTierHistoryResponse(ApiResponse.loading());
      }

      final result = await _myRepo.getUserTierHistoryApi();

      // Ensure we're still mounted before proceeding
      if (!hasListeners) return;

      result.fold(
        (error) {
          // Handle error case
          final errorMessage = error.message;

          setUserTierHistoryResponse(ApiResponse.error(errorMessage));
          debugPrint('❌ User tier history failed: $errorMessage');
        },
        (response) {
          // Handle successful response
          if (response.status == true) {
            // Only update if the data has actually changed
            if (userTierHistoryResponse.data?.toJson().toString() !=
                response.toJson().toString()) {
              setUserTierHistoryResponse(ApiResponse.completed(response));
              debugPrint('✅ User tier history updated successfully');
              debugPrint('📊 Tier history data: ${response.toJson()}');
            }
          } else {
            final errorMessage =
                'Failed to load tier history. Please try again.';
            setUserTierHistoryResponse(ApiResponse.error(errorMessage));
            debugPrint('❌ User tier history failed: API returned status false');
          }
        },
      );
    } catch (e) {
      if (hasListeners) {
        final errorMessage = 'An unexpected error occurred: ${e.toString()}';
        setUserTierHistoryResponse(ApiResponse.error(errorMessage));
        debugPrint('❌ Error fetching user tier history: $e');
      }
    }
  }
}
