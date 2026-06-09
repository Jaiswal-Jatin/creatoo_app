import 'package:creatoo/core.dart';

class CustomBackButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color iconColor;
  final double size;

  const CustomBackButton({
    super.key,
    this.onTap,
    this.backgroundColor = Colors.white,
    this.iconColor = Colors.black,
    this.size = 34,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => Navigator.pop(context),
      child: Container(
        height: size.h,
        width: size.h,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new,
            size: (size * 0.45).sp,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
