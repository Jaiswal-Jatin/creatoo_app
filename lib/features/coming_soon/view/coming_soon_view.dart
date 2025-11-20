import '../../../core.dart';
import '../../../widgets/app_text_widget.dart';

class ComingSoonView extends StatelessWidget {
  const ComingSoonView({super.key});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBarWidget(
        useCustomBackButton: true,
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SvgPicture.asset(
              height: 350.h,
              width: 350.w,
              AppIcon.comingSoon,
              fit: BoxFit.contain,
            ),
            AppTextWidget(
              text: "Coming Soon...!",
              fontSize: 24.sp,
              fontWeight: FontWeight.w500,
            )
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        margin: EdgeInsets.all(18),
        child: AppButton(
          onTap: () async {
            Navigator.pop(
              context,
            );
          },
          text: "Go to Home",
        ),
      ),
    );
  }
}
