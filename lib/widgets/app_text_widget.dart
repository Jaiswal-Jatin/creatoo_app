import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextWidget extends StatelessWidget {
  const AppTextWidget({
    super.key,
    this.text,
    this.fontSize,
    this.color,
    this.textAlign,
    this.fontWeight,
    this.letterSpacing,
    this.textOverflow,
    this.textDecoration,
    this.textDecorationColor,
    this.maxLines,
    this.softWrap,
    this.fontStyle,
    this.onTap, // Added onTap parameter
  });

  final String? text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final TextDecoration? textDecoration;
  final Color? color;
  final TextAlign? textAlign;
  final double? letterSpacing;
  final TextOverflow? textOverflow;
  final Color? textDecorationColor;
  final int? maxLines;
  final bool? softWrap;
  final FontStyle? fontStyle;
  final VoidCallback? onTap; // Added onTap parameter

  @override
  Widget build(BuildContext context) {
    Widget textWidget = Text(
      textAlign: textAlign,
      text ?? "",
      overflow: textOverflow,
      maxLines: maxLines,
      softWrap: softWrap ?? true,
      style: GoogleFonts.inter(
        decoration: textDecoration,
        decorationColor: textDecorationColor,
        fontSize: fontSize ?? 12,
        fontWeight: fontWeight,
        color: color,
        letterSpacing: letterSpacing,
        // fontStyle: fontStyle ?? FontStyle.normal,
      ),
    );

    if (onTap != null) {
      textWidget = InkWell(
        onTap: onTap,
        child: textWidget,
      );
    }

    return textWidget;
  }
}
