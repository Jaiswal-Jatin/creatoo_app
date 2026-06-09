import 'package:creatoo/core.dart';

class AppForm extends StatefulWidget {
  final String title;
  final List<String> hintTexts;
  final Function(List<String> data) onDataChanged;
  final int? maxLength;
  final TextCapitalization capitaliseText;
  final Color? textColor;
  final Color? textFieldBackgroundColor;

  const AppForm({
    Key? key,
    required this.title,
    required this.hintTexts,
    required this.onDataChanged,
    this.maxLength,
    this.capitaliseText = TextCapitalization.sentences,
    this.textColor,
    this.textFieldBackgroundColor,
  }) : super(key: key);

  @override
  State<AppForm> createState() => _AppFormState();
}

class _AppFormState extends State<AppForm> {
  bool isInitialised = false;
  late List<String> formData;
  late List<FocusNode> focusNodes;
  late List<bool> hasError;

  TextInputType getTextInputType(String name) {
    if (name.toLowerCase().contains("mail")) {
      return TextInputType.emailAddress;
    }
    if (name.toLowerCase().contains("mobile") || name.toLowerCase().contains("phone")) {
      return TextInputType.number;
    }
    return TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialised) {
      formData = List.filled(widget.hintTexts.length, '');
      focusNodes = List.generate(widget.hintTexts.length, (index) => FocusNode());
      hasError = List.filled(widget.hintTexts.length, false);
      isInitialised = true;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ...List.generate(
          widget.hintTexts.length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 4.w),
                  child: Text(
                    widget.hintTexts[index],
                    style: GoogleFonts.montserrat(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: widget.textColor?.withOpacity(0.7) ?? AppColor.premiumTextSecondary,
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
                AppTextField(
                  hintText: "Enter ${widget.hintTexts[index].toLowerCase()}",
                  textInputType: getTextInputType(widget.hintTexts[index]),
                  backgroundColor: widget.textFieldBackgroundColor ?? Colors.white.withOpacity(0.05),
                  textColor: widget.textColor ?? Colors.white,
                  cursorColor: AppColor.premiumAccent,
                  borderColor: Colors.white.withOpacity(0.1),
                  focusedBorderColor: AppColor.premiumAccent,
                  borderRadius: 16,
                  textStyle: GoogleFonts.montserrat(
                    color: widget.textColor ?? Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  hintStyle: GoogleFonts.montserrat(
                    color: (widget.textColor ?? Colors.white).withOpacity(0.2),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
                  disableBorder: false,
                  maxLength: widget.maxLength,
                  capitaliseText: widget.capitaliseText,
                  onChanged: (value) {
                    formData[index] = value.toString().trim();
                    widget.onDataChanged(formData);
                  },
                  validator: (value) => Validator.validate(
                      value.toString().trim(), widget.hintTexts[index]),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
