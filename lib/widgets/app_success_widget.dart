import 'package:creatoo/core.dart';

class AppSuccessWidget extends StatefulWidget {
  final String message;

  const AppSuccessWidget({super.key, this.message = "Congratulations!"});

  @override
  State<AppSuccessWidget> createState() => _AppSuccessWidgetState();
}

class _AppSuccessWidgetState extends State<AppSuccessWidget> {
  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 3), () {
      Navigator.popUntil(context, (route) => route.isFirst);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Icon(
              Icons.check_circle,
              color: Colors.green,
              size: 120.h,
            ),
            SizedBox(height: 10.h),
            Text(
              widget.message,
              style: TextStyle(
                fontSize: 30.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
