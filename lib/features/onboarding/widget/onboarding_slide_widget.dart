import 'dart:ui';
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
      children: <Widget>[
        Expanded(
          flex: 6,
          child: Container(
            padding: EdgeInsets.all(24.w),
            width: double.infinity,
            child: SvgPicture.asset(
              image,
              fit: BoxFit.contain,
            ),
          ),
        ),
        
        Expanded(
          flex: 4,
          child: Container(
            padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 40.h),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                child: Container(
                  padding: EdgeInsets.all(30.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.1),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          child: Text(
                            description,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.montserrat(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: Colors.white.withOpacity(0.9),
                              height: 1.5,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h),
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
        ),
      ],
    );
  }
}
