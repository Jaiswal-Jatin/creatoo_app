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
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          height: SizeConfig.screenWidth - 50,
          width: SizeConfig.screenWidth,
          child: SvgPicture.asset(
            image,
          ),
        ),
        SizedBox(height: 20.h),
        Container(
          margin: EdgeInsets.symmetric(vertical: 20.h),
          height: MediaQuery.sizeOf(context).height * 0.3,
          width: MediaQuery.sizeOf(context).width,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.montserrat(
                      textStyle: Theme.of(context).textTheme.displayLarge,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 24.h),
                  // if (isLastSlide)
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
      ],
    );
  }
}
