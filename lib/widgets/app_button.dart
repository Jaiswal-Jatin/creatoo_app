import '../core.dart';

class AppButton extends StatelessWidget {
  final String text;
  final Function()? onTap;
  final bool isLoading;
  final bool isDisabled;
  final bool enableBorder;
  final bool isIconEnabled;
  final Color textColor;
  final Color buttonColor;
  final double height;

  AppButton({
    super.key,
    required this.onTap,
    this.text = "Sign In",
    this.height = 50,
    this.isLoading = false,
    this.isDisabled = false,
    this.enableBorder = false,
    this.isIconEnabled = true,
    this.textColor = AppColor.white,
    this.buttonColor = AppColor.kPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isLoading || isDisabled) ? null : onTap,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            height: height.h,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
                color: (isLoading || isDisabled) ? AppColor.primaryDisabled : buttonColor,
                borderRadius: BorderRadius.circular(15),
                border: enableBorder ? Border.all(color: AppColor.lightGrey) : null),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator(
                      color: AppColor.white,
                    )
                  : FittedBox(
                      child: Text(
                        text,
                        style: TextStyle(
                          color: (isLoading || isDisabled) ? textColor.withOpacity(0.7) : textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                    ),
            ),
          ),
          Visibility(
            visible: isIconEnabled,
            child: Positioned(
              right: 10,
              child: Icon(
                Icons.arrow_forward,
                color: (isLoading || isDisabled) ? AppColor.white.withOpacity(0.7) : AppColor.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
