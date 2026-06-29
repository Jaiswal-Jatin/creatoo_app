import '../../../core.dart';
import '../view_model/qr_pay_view_model.dart';

class PayTransferView extends StatefulWidget {
  const PayTransferView({super.key});

  @override
  State<PayTransferView> createState() => _PayTransferViewState();
}

class _PayTransferViewState extends State<PayTransferView> {
  late QrPayViewModel viewModel;

  @override
  void initState() {
    viewModel = Provider.of<QrPayViewModel>(context, listen: false);

    viewModel.showError = false;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await viewModel.fetchBusinessBonusInfo();
      await viewModel.validatePointsApiCall();

      // Show the bottom sheet after initial API call
      _showFixedBottomSheet(
        businessName: viewModel.businessData?.businessName ?? '',
        points: viewModel.pointsController.text,
      );
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<QrPayViewModel>(context);
    return buildMobileBody();
  }

  Widget buildMobileBody() {
    return (viewModel.validateResponse.status == ApiResponse.loading())
        ? AppLoadingWidget()
        : AppScaffold(
            appBar: AppBarWidget(),
            body: Form(
              child: Container(
                width: SizeConfig.screenWidth,
                margin: const EdgeInsets.only(top: 20),
                child: SingleChildScrollView(
                  child: Column(
                    // spacing: 8.h,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: AppImageWidget(
                          imageUrl: viewModel.businessData?.businessImage ?? '',
                          height: 150,
                          width: 150,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          'Paying to',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20.w),
                          child: Text(
                            textAlign: TextAlign.center,
                            viewModel.businessData?.businessName ?? '',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 5.h,
                      ),
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 26.0),
                          child: Text(
                            viewModel.businessData?.businessAddress ?? '',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w100),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        viewModel.pointsController.text,
                        style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        'Creatoo points',
                        style: TextStyle(fontSize: 12),
                      ),
                      SizedBox(height: 15),
                      Consumer<QrPayViewModel>(
                        builder: (context, vm, _) {
                          if (!vm.isFirstVisit || vm.signupBonusPoints == 0) {
                            return SizedBox.shrink();
                          }
                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                            decoration: BoxDecoration(
                              color: AppColor.mangoYellow.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColor.mangoYellow.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.card_giftcard, color: AppColor.mangoYellow, size: 16.sp),
                                SizedBox(width: 8.w),
                                Text(
                                  "Signup Bonus: +${vm.signupBonusPoints} points for this business!",
                                  style: GoogleFonts.montserrat(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w600,
                                    color: AppColor.mangoYellow,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 8.h),
                      if (viewModel.validateResponse.status == Status.loading)
                        AppLoadingWidget(
                          isApi: true,
                        ),
                      if (viewModel.showError)
                        Text(
                          viewModel.errorMessage ?? '! Error message display here',
                          style: TextStyle(fontSize: 12, color: AppColor.darkRed),
                        ),
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  /// Show a fixed bottom sheet that cannot be dismissed by dragging
  void _showFixedBottomSheet({required String businessName, required String points}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      barrierColor: AppColor.black.withOpacity(0.5),
      enableDrag: false,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(45)),
      ),
      builder: (context) {
        var viewModel = Provider.of<QrPayViewModel>(context);
        return WillPopScope(
          onWillPop: () async {
            Navigator.pop(context);
            return true;
          },
          child: Container(
            padding: EdgeInsets.all(20),
            height: 260.h,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(45),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.black,
                  width: 1.0,
                ),
              ),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40, right: 16, left: 16, bottom: 8),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            child: Image.asset(
                              "assets/images/card.png",
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 20),
                          Flexible(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  businessName,
                                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                                  maxLines: 2,
                                ),
                                SizedBox(
                                  height: 10.h,
                                ),
                                Text(
                                  'Creatoo Balance : ${viewModel.roundToTwoDecimalPlaces(viewModel.creatooBalance?.toDouble() ?? 0.0)}',
                                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                                ),
                                Consumer<QrPayViewModel>(
                                  builder: (context, vm, _) {
                                    if (vm.signupBonusMessage.isEmpty) return SizedBox.shrink();
                                    return Padding(
                                      padding: EdgeInsets.only(top: 4.h),
                                      child: Text(
                                        vm.signupBonusMessage,
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: AppColor.mangoYellow,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      AppButton(
                        isDisabled: viewModel.showError,
                        text: 'Transfer Now',
                        isLoading: viewModel.isLoading,
                        onTap: () async {
                          await viewModel.transferPointsApiCall();
                        },
                      ),
                    ],
                  ),
                ),

                // Close Icon in the Top-Right Corner
                Positioned(
                  top: -6,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
