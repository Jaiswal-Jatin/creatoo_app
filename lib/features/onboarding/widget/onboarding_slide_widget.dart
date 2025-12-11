import '../../../core.dart';

class OnboardingSlide extends StatelessWidget {
  final String description;
  final String image;
  final bool isFirstSlide;
  final bool isLastSlide;
  final Function()? onNext;

  const OnboardingSlide({
    required this.description,
    required this.image,
    required this.isFirstSlide,
    required this.isLastSlide,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Expanded(
            flex: 5,
            child: Container(
              width: SizeConfig.screenWidth,
              child: SvgPicture.asset(
                image,
                fit: BoxFit.contain,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Expanded(
            flex: 4,
            child: Container(
              margin: EdgeInsets.only(bottom: 16.h),
              width: MediaQuery.sizeOf(context).width,
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          description,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.montserrat(
                            textStyle: Theme.of(context).textTheme.displayLarge,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      AppButton(
                        onTap: onNext,
                        isIconEnabled: false,
                        text: isLastSlide ? "Get Started" : "Next",
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
