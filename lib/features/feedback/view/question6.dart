import 'dart:ui';

import '../../../core.dart';
import '../../../widgets/app_text_widget.dart';
import '../view_model/feedback_view_model.dart';

class Question6 extends StatefulWidget {
  final VoidCallback onSubmit;

  const Question6({super.key, required this.onSubmit});

  @override
  _Question6State createState() => _Question6State();
}

class _Question6State extends State<Question6> {
  late FeedbackViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<FeedbackViewModel>(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 40.h),
          
          AppTextWidget(
            text: "Do you want to write/tell us\nsomething else?",
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
            color: Colors.white,
          ),
          
          SizedBox(height: 40.h),
          
          // Glassmorphic Input Area
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.1),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: viewModel.feedbackTextController,
                      maxLines: 8,
                      minLines: 5,
                      maxLength: 100,
                      style: GoogleFonts.montserrat(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        hintText: "Enter your feedback...",
                        hintStyle: GoogleFonts.montserrat(
                          color: Colors.white38,
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        counterStyle: GoogleFonts.montserrat(
                          color: AppColor.premiumAccent,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SizedBox(height: 120.h), // Space for submit button
        ],
      ),
    );
  }
}
