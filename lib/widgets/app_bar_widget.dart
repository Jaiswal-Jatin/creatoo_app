import '../core.dart';
import '../features/feedback/view_model/feedback_view_model.dart';
import '../features/home/view/home_page.dart';
import 'app_text_widget.dart';

class AppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? subtitle;
  final Color backgroundColor;
  final double elevation;
  final IconButton? leading;
  final List<Widget>? actions;
  final bool disableLeadingButton;
  final bool useCustomBackButton;
  final bool? centerTile;
  final double? toolBarHeight;
  final bool showSkipButton;
  final Function()? onPop;

  AppBarWidget({
    this.title = '',
    this.centerTile,
    this.subtitle,
    this.backgroundColor = Colors.transparent,
    this.elevation = 0.0,
    this.leading,
    this.toolBarHeight,
    this.actions,
    this.disableLeadingButton = false,
    this.useCustomBackButton = false,
    this.showSkipButton = false,
    this.onPop,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: !disableLeadingButton,
      centerTitle: centerTile ?? true,
      toolbarHeight: toolBarHeight ?? kToolbarHeight,
      backgroundColor: useCustomBackButton ? Colors.transparent : backgroundColor,
      elevation: elevation,
      leading: disableLeadingButton
          ? null
          : useCustomBackButton
              ? GestureDetector(
                  onTap: () {
                    if (onPop != null) {
                      onPop!();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
                      ),
                    ),
                  ),
                )
              : leading ??
                  IconButton(
                    icon: SvgPicture.asset(
                      height: 24.h,
                      width: 24.h,
                      AppIcon.arrowLeft,
                    ),
                    onPressed: () {
                      if (onPop != null) {
                        onPop!();
                      } else {
                        Navigator.pop(context);
                      }
                    },
                  ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 4.w),
            child: Text(
              title,
              style: AppTextStyles.appBarTitleTextStyle,
            ),
          ),
          if (subtitle != null)
            Padding(
              padding: EdgeInsets.only(top: 2, left: 4.w),
              child: Text(
                subtitle!,
                style: AppTextStyles.appBarSubtitleTextStyle,
              ),
            ),
        ],
      ),
      actions: [
        if (showSkipButton)
          Padding(
            padding: EdgeInsets.only(right: 16.w, top: 12.h, bottom: 12.h),
            child: SizedBox(
              height: 20,
              width: 60,
              child: ElevatedButton(
                onPressed: () => _showSkipDialog(context),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  backgroundColor: AppColor.kPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        if (actions != null) ...?actions,
      ],
    );
  }

  Future<void> _showSkipDialog(BuildContext context) async {
    bool? confirmSkip = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: AppTextWidget(
            text: "If you skip the review, you will not get the points. Do you really want to skip the review?",
            fontSize: 14,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: AppTextWidget(text: "No", fontSize: 14),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: AppTextWidget(text: "Yes", fontSize: 14),
            ),
          ],
        );
      },
    );

    if (confirmSkip == true) {
      await _handleSkip(context);
    }
  }

  Future<void> _handleSkip(BuildContext context) async {
    final feedbackViewModel = Provider.of<FeedbackViewModel>(context, listen: false);

    bool isSkipped = await feedbackViewModel.skipFeedback();
    if (isSkipped) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
        (route) => false,
      );
    }
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + (subtitle != null ? 20.h : 0));
}
