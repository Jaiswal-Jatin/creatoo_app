import 'package:creatoo/core.dart';

class AppValidator extends StatefulWidget {
  final Widget child;
  final bool validator;
  final bool isValidating;
  final bool enableErrorBorder;
  final String errorMessage;
  final BoxShape borderShape;
  final double borderRadius;
  final Alignment alignment;

  const AppValidator({
    Key? key,
    required this.child,
    required this.validator,
    this.errorMessage = "",
    this.isValidating = false,
    this.enableErrorBorder = false,
    this.borderShape = BoxShape.rectangle,
    this.borderRadius = 10,
    this.alignment = Alignment.centerLeft,
  }) : super(key: key);

  @override
  _AppValidatorState createState() => _AppValidatorState();
}

class _AppValidatorState extends State<AppValidator> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: EdgeInsets.symmetric(vertical: 5),
          decoration: widget.enableErrorBorder
              ? BoxDecoration(
                  shape: widget.borderShape,
                  borderRadius: widget.borderShape == BoxShape.circle
                      ? BorderRadius.zero
                      : BorderRadius.circular(widget.borderRadius),
                  border: (widget.isValidating && widget.validator)
                      ? Border.all(color: AppColor.darkRed)
                      : null,
                )
              : null,
          child: widget.child,
        ),
        SizedBox(height: 10.h),
        if (widget.isValidating &&
            widget.validator &&
            widget.errorMessage.isNotEmpty)
          Container(
            padding: EdgeInsets.only(left: 20),
            alignment: widget.alignment,
            child: Text(
              widget.errorMessage,
              style: TextStyle(
                color: AppColor.darkRed,
                fontSize: 14.sp,
              ),
            ),
          ),
      ],
    );
  }
}
