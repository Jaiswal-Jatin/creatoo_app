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
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isSmall = h < 700;
    
    return GestureDetector(
      onTap: (isLoading || isDisabled) ? null : onTap,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          Container(
            height: isSmall ? h * 0.05 : height.h,
            padding: EdgeInsets.symmetric(horizontal: w * 0.025, vertical: h * 0.01),
            decoration: BoxDecoration(
                color: (isLoading || isDisabled) ? AppColor.primaryDisabled : buttonColor,
                borderRadius: BorderRadius.circular(isSmall ? 10 : 15),
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
                          fontSize: isSmall ? w * 0.035 : 16.sp,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        softWrap: true,
                      ),
                    ),
            ),
          ),
          Visibility(
            visible: isIconEnabled,
            child: Positioned(
              right: w * 0.025,
              child: Icon(
                Icons.arrow_forward,
                color: (isLoading || isDisabled) ? AppColor.white.withOpacity(0.7) : AppColor.white,
                size: isSmall ? w * 0.04 : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
