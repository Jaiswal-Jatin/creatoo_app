import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/app_text_widget.dart';
import '../resources/images.dart';

class AppLoadingWidget extends StatefulWidget {
  final bool isApi;
  const AppLoadingWidget({super.key, this.isApi = false});

  @override
  State<AppLoadingWidget> createState() => _AppLoadingWidgetState();
}

class _AppLoadingWidgetState extends State<AppLoadingWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isApi) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColor.premiumAccent,
          strokeWidth: 3,
        ),
      );
    }

    return AppScaffold(
      useGradient: false,
      backgroundColor: Colors.transparent, // Inherit gradient
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Premium Glowing Spinner
            SizedBox(
              width: 32.w,
              height: 32.w,
              child: CircularProgressIndicator(
                color: AppColor.premiumAccent,
                strokeWidth: 2.5,
                backgroundColor: AppColor.premiumAccent.withOpacity(0.1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
