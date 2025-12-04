import 'package:flutter/services.dart';

import '../core.dart';

class AppTextField extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool showSuffixIcon;
  final TextCapitalization capitaliseText;
  final bool autofocus;
  final EdgeInsetsGeometry? contentPadding;
  final FormFieldValidator? validator;
  final TextInputType textInputType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final Function(dynamic value)? onChanged;
  final Function()? onTap;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final bool disableBorder;
  final GlobalKey<FormFieldState<String>>? fieldKey;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final double borderRadius;
  final bool disallowZero; // New flag to disallow zero input
  final double? textSize; // New parameter for text size
  final Color? backgroundColor; // New parameter for background color
  final FontWeight? fontWeight;
  final TextAlign textAlign;
  final Color? textColor;
  final Color? cursorColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final TextStyle? hintStyle;
  final TextStyle? textStyle;

  AppTextField({
    super.key,
    this.controller,
    this.hintText,
    this.showSuffixIcon = false,
    this.validator,
    this.textInputType = TextInputType.text, // Default accepts all types
    this.inputFormatters,
    this.maxLength,
    this.onChanged,
    this.suffixIcon,
    this.textAlign = TextAlign.start,
    this.fieldKey,
    this.capitaliseText = TextCapitalization.sentences,
    this.autofocus = false,
    this.prefixIcon,
    this.disableBorder = true,
    this.focusNode,
    this.contentPadding = const EdgeInsets.only(left: 10),
    this.maxLines,
    this.minLines,
    this.onTap,
    this.readOnly = false,
    this.borderRadius = 15,
    this.disallowZero = false,
    this.textSize,
    this.backgroundColor,
    this.fontWeight,
    this.textColor,
    this.cursorColor,
    this.borderColor = AppColor.moreLighterDd,
    this.focusedBorderColor,
    this.hintStyle,
    this.textStyle,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final h = MediaQuery.of(context).size.height;
    final isSmall = h < 700;
    
    return TextFormField(
      textAlign: widget.textAlign,
      autofocus: widget.autofocus,
      key: widget.fieldKey,
      onTap: widget.onTap,
      controller: widget.controller,
      focusNode: widget.focusNode,
      validator: widget.validator,
      keyboardType: widget.textInputType,
      maxLength: widget.maxLength,
      minLines: widget.minLines,
      readOnly: widget.readOnly,
      maxLines: widget.maxLines,
      onChanged: widget.onChanged,
      textCapitalization: widget.capitaliseText,
      cursorColor: widget.cursorColor ?? widget.textColor ?? Colors.black,
      style: widget.textStyle ?? TextStyle(
        fontSize: widget.textSize ?? (isSmall ? w * 0.035 : null),
        fontWeight: widget.fontWeight,
        color: widget.textColor ?? Colors.black,
      ),
      decoration: InputDecoration(
        fillColor: widget.backgroundColor ?? Colors.white,
        filled: true,
        hintText: widget.hintText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        contentPadding: widget.contentPadding ?? EdgeInsets.only(left: isSmall ? w * 0.025 : 10),
        counterText: '',
        prefixIconConstraints: BoxConstraints.tightForFinite(width: isSmall ? w * 0.3 : 120, height: isSmall ? h * 0.025 : 20),
        suffixIconConstraints: BoxConstraints.tightForFinite(width: isSmall ? w * 0.15 : 60, height: isSmall ? h * 0.025 : 20),
        hintStyle: widget.hintStyle ?? GoogleFonts.montserrat(
          fontWeight: FontWeight.w500,
          fontSize: isSmall ? w * 0.032 : 14.sp,
          color: Colors.black.withOpacity(0.5),
        ),
        errorStyle: TextStyle(fontSize: isSmall ? w * 0.032 : 14.sp),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isSmall ? 12 : widget.borderRadius),
          gapPadding: isSmall ? 12 : 16,
          borderSide: widget.disableBorder ? BorderSide.none : BorderSide(width: 5, style: BorderStyle.solid, color: widget.borderColor!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isSmall ? 12 : widget.borderRadius),
          borderSide: widget.disableBorder 
              ? BorderSide.none 
              : BorderSide(color: widget.borderColor!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(isSmall ? 12 : widget.borderRadius),
          borderSide: BorderSide(
            color: widget.focusedBorderColor ?? widget.borderColor ?? AppColor.kPrimary,
            width: 1.5,
          ),
        ),
      ),
      inputFormatters: widget.inputFormatters ??
          [
            if (widget.textInputType == TextInputType.number) FilteringTextInputFormatter.digitsOnly,
            if (widget.disallowZero) FilteringTextInputFormatter.allow(RegExp(r'[^0]')),
            if (widget.maxLength != null) LengthLimitingTextInputFormatter(widget.maxLength),
          ],
    );
  }
}
