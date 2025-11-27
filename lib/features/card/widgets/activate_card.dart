import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/app_button.dart';
import 'package:creatoo/widgets/app_textfield.dart';
import 'package:creatoo/data/services/shared_preference_service.dart';
import 'package:creatoo/features/verify_otp/model/verify_otp_model.dart';
import 'package:creatoo/features/card/data/activate_card_request_model.dart';
import 'package:creatoo/features/card/view_model/card_view_model.dart';
import 'package:provider/provider.dart';

class ActivateCardModal extends StatefulWidget {
  const ActivateCardModal({super.key});

  @override
  State<ActivateCardModal> createState() => _ActivateCardModalState();
}

class _ActivateCardModalState extends State<ActivateCardModal> {
  late TextEditingController nameController;
  late TextEditingController cardCodeController;
  late CardViewModel viewModel;
  UserData? userData;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    cardCodeController = TextEditingController();
    viewModel = Provider.of<CardViewModel>(context, listen: false);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    userData = await SharedPreferencesService().getUserData();
    if (userData != null && userData!.name != null) {
      nameController.text = userData!.name!;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    cardCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final defaultPinTheme = PinTheme(
      width: 60.h,
      height: 60.h,
      padding: EdgeInsets.zero,
      textStyle: TextStyle(
        fontSize: 24.sp,
        color: const Color(0xFF161616),
        fontWeight: FontWeight.w600,
      ),
      decoration: BoxDecoration(
        color: AppColor.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColor.primary),
      borderRadius: BorderRadius.circular(10),
    );

    final errorPinTheme = defaultPinTheme.copyDecorationWith(
      border: Border.all(color: AppColor.error),
      borderRadius: BorderRadius.circular(10),
    );

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColor.lightButtonGrey,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(
                  Icons.close,
                  color: AppColor.black,
                ),
              ),
            ),
            Text(
              'Activate Your Card',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 25.h),
            AppTextField(
              controller: nameController,
              hintText: 'Name',
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 15, right: 10),
                child: Icon(Icons.person_outline, color: AppColor.black.withOpacity(0.7)),
              ),
              disableBorder: false,
              borderColor: AppColor.black.withOpacity(0.5),
              textColor: AppColor.black,
              contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 0),
              textAlign: TextAlign.start,
              readOnly: true, // Make name field read-only
            ),
            SizedBox(height: 15.h),
            Text(
              'Enter Card Code',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: AppColor.black,
              ),
            ),
            SizedBox(height: 10.h),
            Pinput(
              autofocus: true,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              length: 4, // 4-digit card code
              controller: cardCodeController,
              isCursorAnimationEnabled: true,
              animationCurve: Curves.linear,
              animationDuration: const Duration(milliseconds: 100),
              closeKeyboardWhenCompleted: true,
              cursor: Text(
                '-',
                style: TextStyle(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
              mouseCursor: MouseCursor.defer,
              showCursor: true,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              errorPinTheme: errorPinTheme,
              hapticFeedbackType: HapticFeedbackType.heavyImpact,
              pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
              useNativeKeyboard: true,
              textInputAction: TextInputAction.done,
              pinContentAlignment: Alignment.center,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter card code';
                } else if (value.length != 4) {
                  return 'Card code must be 4 digits';
                }
                return null;
              },
            ),
            SizedBox(height: 25.h),
            Consumer<CardViewModel>(
              builder: (context, cardViewModel, child) {
                return AppButton(
                  text: 'Activate Card',
                  onTap: () {
                    if (cardCodeController.text.length == 4) {
                      cardViewModel.activeCard(
                        context, // Pass the context from the widget
                        ActivateCardRequestModel(
                          name: nameController.text, // User's actual name
                          number: cardCodeController.text, // Card code as number
                        ),
                      );
                    } else {
                      Utils.flushBar('Please enter a 4-digit card code', result: Result.error);
                    }
                  },
                  buttonColor: AppColor.primary,
                  height: 50,
                  isIconEnabled: false,
                  isLoading: cardViewModel.activeCardResponse.status == Status.loading,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
