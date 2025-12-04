import 'package:creatoo/core.dart';

class AppForm extends StatefulWidget {
  final String title;
  final List<String> hintTexts;
  final Function(List<String> data) onDataChanged;
  final int? maxLength;
  final TextCapitalization capitaliseText;

  const AppForm({
    Key? key,
    required this.title,
    required this.hintTexts,
    required this.onDataChanged,
    this.maxLength,
    this.capitaliseText = TextCapitalization.sentences,
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
    if (name.toLowerCase().contains("mobile")) {
      return TextInputType.number;
    }
    return TextInputType.text;
  }

  @override
  Widget build(BuildContext context) {
    if (!isInitialised) {
      formData = List.filled(widget.hintTexts.length, '');
      focusNodes =
          List.generate(widget.hintTexts.length, (index) => FocusNode());
      hasError = List.filled(widget.hintTexts.length, false);
      isInitialised = true;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        ...List.generate(
          widget.hintTexts.length,
          (index) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 1.0),
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ' ${widget.hintTexts[index]}',
                  style: GoogleFonts.montserrat(
                    textStyle: Theme.of(context).textTheme.displayLarge,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF191D23),
                  ),
                ),
                SizedBox(height: 8.h),
                AppTextField(
                  hintText: "Enter ${widget.hintTexts[index]}",
                  textInputType: getTextInputType(widget.hintTexts[index]),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 25.w, vertical: 18.h),
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
