import '../core.dart';

class AppWalletCardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Path path_0 = Path();
    path_0.moveTo(0, size.height * 0.04206869);
    path_0.cubicTo(0, size.height * 0.01883474, size.width * 0.009637690, 0,
        size.width * 0.02152640, 0);
    path_0.lineTo(size.width * 0.3802544, 0);
    path_0.cubicTo(
        size.width * 0.3888246,
        0,
        size.width * 0.3965760,
        size.height * 0.009933829,
        size.width * 0.3999942,
        size.height * 0.02529206);
    path_0.lineTo(size.width * 0.4362690, size.height * 0.1883086);
    path_0.cubicTo(
        size.width * 0.4424503,
        size.height * 0.2160926,
        size.width * 0.4320322,
        size.height * 0.2471537,
        size.width * 0.4165292,
        size.height * 0.2471537);
    path_0.lineTo(size.width * 0.02152640, size.height * 0.2471537);
    path_0.cubicTo(size.width * 0.009637719, size.height * 0.2471537, 0,
        size.height * 0.2283189, 0, size.height * 0.2050851);
    path_0.lineTo(0, size.height * 0.04206869);
    path_0.close();

    Paint paint_0_fill = Paint()..style = PaintingStyle.fill;
    paint_0_fill.color = Color(0xff9759C4).withOpacity(1.0);
    canvas.drawPath(path_0, paint_0_fill);

    Path path_1 = Path();
    path_1.moveTo(size.width, size.height * 0.9579314);
    path_1.cubicTo(size.width, size.height * 0.9811657, size.width * 0.9903626,
        size.height, size.width * 0.9784737, size.height);
    path_1.lineTo(size.width * 0.6214883, size.height);
    path_1.cubicTo(
        size.width * 0.6129240,
        size.height,
        size.width * 0.6051725,
        size.height * 0.9900743,
        size.width * 0.6017515,
        size.height * 0.9747257);
    path_1.lineTo(size.width * 0.5657485, size.height * 0.8131486);
    path_1.cubicTo(
        size.width * 0.5595556,
        size.height * 0.7853657,
        size.width * 0.5699766,
        size.height * 0.7542857,
        size.width * 0.5854854,
        size.height * 0.7542857);
    path_1.lineTo(size.width * 0.9784737, size.height * 0.7542857);
    path_1.cubicTo(size.width * 0.9903626, size.height * 0.7542857, size.width,
        size.height * 0.7731200, size.width, size.height * 0.7963543);
    path_1.lineTo(size.width, size.height * 0.9579314);
    path_1.close();

    Paint paint_1_fill = Paint()..style = PaintingStyle.fill;
    paint_1_fill.color = Color(0xff9759C4).withOpacity(1.0);
    canvas.drawPath(path_1, paint_1_fill);

    Paint paint_2_fill = Paint()..style = PaintingStyle.fill;
    paint_2_fill.color = Color(0xff9759C4).withOpacity(1.0);
    canvas.drawRRect(
        RRect.fromRectAndCorners(
            Rect.fromLTWH(0, size.height * 0.1028571, size.width,
                size.height * 0.7885714),
            bottomRight: Radius.circular(size.width * 0.03228947),
            bottomLeft: Radius.circular(size.width * 0.03228947),
            topLeft: Radius.circular(size.width * 0.03228947),
            topRight: Radius.circular(size.width * 0.03228947)),
        paint_2_fill);

    Path path_3 = Path();
    path_3.moveTo(size.width * 0.7514620, size.height * 0.7862571);
    path_3.cubicTo(
        size.width * 0.7514620,
        size.height * 0.7377714,
        size.width * 0.7514620,
        size.height * 0.7135257,
        size.width * 0.7591696,
        size.height * 0.6984629);
    path_3.cubicTo(
        size.width * 0.7668772,
        size.height * 0.6834000,
        size.width * 0.7792836,
        size.height * 0.6834000,
        size.width * 0.8040936,
        size.height * 0.6834000);
    path_3.cubicTo(
        size.width * 0.8289035,
        size.height * 0.6834000,
        size.width * 0.8413099,
        size.height * 0.6834000,
        size.width * 0.8490175,
        size.height * 0.6984629);
    path_3.cubicTo(
        size.width * 0.8567251,
        size.height * 0.7135257,
        size.width * 0.8567251,
        size.height * 0.7377714,
        size.width * 0.8567251,
        size.height * 0.7862571);
    path_3.cubicTo(
        size.width * 0.8567251,
        size.height * 0.8347429,
        size.width * 0.8567251,
        size.height * 0.8589886,
        size.width * 0.8490175,
        size.height * 0.8740514);
    path_3.cubicTo(
        size.width * 0.8413099,
        size.height * 0.8891143,
        size.width * 0.8289035,
        size.height * 0.8891143,
        size.width * 0.8040936,
        size.height * 0.8891143);
    path_3.cubicTo(
        size.width * 0.7792836,
        size.height * 0.8891143,
        size.width * 0.7668772,
        size.height * 0.8891143,
        size.width * 0.7591696,
        size.height * 0.8740514);
    path_3.cubicTo(
        size.width * 0.7514620,
        size.height * 0.8589886,
        size.width * 0.7514620,
        size.height * 0.8347429,
        size.width * 0.7514620,
        size.height * 0.7862571);
    path_3.close();

    Paint paint_3_fill = Paint()..style = PaintingStyle.fill;
    paint_3_fill.color = Colors.white.withOpacity(1.0);
    canvas.drawPath(path_3, paint_3_fill);

    Path path_4 = Path();
    path_4.moveTo(size.width * 0.8146199, size.height * 0.8171143);
    path_4.cubicTo(
        size.width * 0.8160731,
        size.height * 0.8171143,
        size.width * 0.8172778,
        size.height * 0.8194400,
        size.width * 0.8169883,
        size.height * 0.8222229);
    path_4.cubicTo(
        size.width * 0.8164795,
        size.height * 0.8271371,
        size.width * 0.8152398,
        size.height * 0.8316971,
        size.width * 0.8133977,
        size.height * 0.8352971);
    path_4.cubicTo(
        size.width * 0.8109298,
        size.height * 0.8401200,
        size.width * 0.8075819,
        size.height * 0.8428286,
        size.width * 0.8040936,
        size.height * 0.8428286);
    path_4.cubicTo(
        size.width * 0.8006023,
        size.height * 0.8428286,
        size.width * 0.7972573,
        size.height * 0.8401200,
        size.width * 0.7947895,
        size.height * 0.8352971);
    path_4.cubicTo(
        size.width * 0.7929474,
        size.height * 0.8316971,
        size.width * 0.7917076,
        size.height * 0.8271371,
        size.width * 0.7911988,
        size.height * 0.8222229);
    path_4.cubicTo(
        size.width * 0.7909094,
        size.height * 0.8194400,
        size.width * 0.7921140,
        size.height * 0.8171143,
        size.width * 0.7935673,
        size.height * 0.8171143);
    path_4.lineTo(size.width * 0.8146199, size.height * 0.8171143);
    path_4.close();

    Paint paint_4_fill = Paint()..style = PaintingStyle.fill;
    paint_4_fill.color = Color(0xff9759C4).withOpacity(1.0);
    canvas.drawPath(path_4, paint_4_fill);

    Path path_5 = Path();
    path_5.moveTo(size.width * 0.8201550, size.height * 0.7748229);
    path_5.cubicTo(
        size.width * 0.8187515,
        size.height * 0.7755543,
        size.width * 0.8178918,
        size.height * 0.7784286,
        size.width * 0.8186023,
        size.height * 0.7809029);
    path_5.cubicTo(
        size.width * 0.8193509,
        size.height * 0.7835086,
        size.width * 0.8203889,
        size.height * 0.7857829,
        size.width * 0.8216491,
        size.height * 0.7875486);
    path_5.cubicTo(
        size.width * 0.8236287,
        size.height * 0.7903200,
        size.width * 0.8260380,
        size.height * 0.7916686,
        size.width * 0.8284678,
        size.height * 0.7913543);
    path_5.cubicTo(
        size.width * 0.8308977,
        size.height * 0.7910457,
        size.width * 0.8331988,
        size.height * 0.7890971,
        size.width * 0.8349766,
        size.height * 0.7858400);
    path_5.cubicTo(
        size.width * 0.8367544,
        size.height * 0.7825886,
        size.width * 0.8378977,
        size.height * 0.7782343,
        size.width * 0.8382164,
        size.height * 0.7735143);
    path_5.cubicTo(
        size.width * 0.8385351,
        size.height * 0.7687943,
        size.width * 0.8380058,
        size.height * 0.7640057,
        size.width * 0.8367193,
        size.height * 0.7599657);
    path_5.cubicTo(
        size.width * 0.8354327,
        size.height * 0.7559257,
        size.width * 0.8334708,
        size.height * 0.7528800,
        size.width * 0.8311637,
        size.height * 0.7513486);
    path_5.cubicTo(
        size.width * 0.8288567,
        size.height * 0.7498171,
        size.width * 0.8263509,
        size.height * 0.7498971,
        size.width * 0.8240731,
        size.height * 0.7515771);
    path_5.cubicTo(
        size.width * 0.8226199,
        size.height * 0.7526457,
        size.width * 0.8213187,
        size.height * 0.7543143,
        size.width * 0.8202485,
        size.height * 0.7564571);
    path_5.cubicTo(
        size.width * 0.8192339,
        size.height * 0.7584857,
        size.width * 0.8196842,
        size.height * 0.7616914,
        size.width * 0.8209415,
        size.height * 0.7631143);
    path_5.lineTo(size.width * 0.8222778, size.height * 0.7646229);
    path_5.cubicTo(
        size.width * 0.8243070,
        size.height * 0.7669086,
        size.width * 0.8239064,
        size.height * 0.7728571,
        size.width * 0.8216433,
        size.height * 0.7740400);
    path_5.lineTo(size.width * 0.8201550, size.height * 0.7748229);
    path_5.close();

    Paint paint_5_fill = Paint()..style = PaintingStyle.fill;
    paint_5_fill.color = Color(0xff9759C4).withOpacity(1.0);
    canvas.drawPath(path_5, paint_5_fill);

    Path path_6 = Path();
    path_6.moveTo(size.width * 0.7880351, size.height * 0.7748229);
    path_6.cubicTo(
        size.width * 0.7894386,
        size.height * 0.7755543,
        size.width * 0.7902982,
        size.height * 0.7784286,
        size.width * 0.7895877,
        size.height * 0.7809029);
    path_6.cubicTo(
        size.width * 0.7888392,
        size.height * 0.7835086,
        size.width * 0.7878012,
        size.height * 0.7857829,
        size.width * 0.7865409,
        size.height * 0.7875486);
    path_6.cubicTo(
        size.width * 0.7845614,
        size.height * 0.7903200,
        size.width * 0.7821520,
        size.height * 0.7916686,
        size.width * 0.7797222,
        size.height * 0.7913543);
    path_6.cubicTo(
        size.width * 0.7772924,
        size.height * 0.7910457,
        size.width * 0.7749912,
        size.height * 0.7890971,
        size.width * 0.7732135,
        size.height * 0.7858400);
    path_6.cubicTo(
        size.width * 0.7714357,
        size.height * 0.7825886,
        size.width * 0.7702924,
        size.height * 0.7782343,
        size.width * 0.7699737,
        size.height * 0.7735143);
    path_6.cubicTo(
        size.width * 0.7696550,
        size.height * 0.7687943,
        size.width * 0.7701842,
        size.height * 0.7640057,
        size.width * 0.7714708,
        size.height * 0.7599657);
    path_6.cubicTo(
        size.width * 0.7727573,
        size.height * 0.7559257,
        size.width * 0.7747193,
        size.height * 0.7528800,
        size.width * 0.7770263,
        size.height * 0.7513486);
    path_6.cubicTo(
        size.width * 0.7793333,
        size.height * 0.7498171,
        size.width * 0.7818392,
        size.height * 0.7498971,
        size.width * 0.7841170,
        size.height * 0.7515771);
    path_6.cubicTo(
        size.width * 0.7855702,
        size.height * 0.7526457,
        size.width * 0.7868713,
        size.height * 0.7543143,
        size.width * 0.7879415,
        size.height * 0.7564571);
    path_6.cubicTo(
        size.width * 0.7889561,
        size.height * 0.7584857,
        size.width * 0.7885058,
        size.height * 0.7616914,
        size.width * 0.7872456,
        size.height * 0.7631143);
    path_6.lineTo(size.width * 0.7859123, size.height * 0.7646229);
    path_6.cubicTo(
        size.width * 0.7838830,
        size.height * 0.7669086,
        size.width * 0.7842836,
        size.height * 0.7728571,
        size.width * 0.7865468,
        size.height * 0.7740400);
    path_6.lineTo(size.width * 0.7880351, size.height * 0.7748229);
    path_6.close();

    Paint paint_6_fill = Paint()..style = PaintingStyle.fill;
    paint_6_fill.color = Color(0xff9759C4).withOpacity(1.0);
    canvas.drawPath(path_6, paint_6_fill);

    Path path_7 = Path();
    path_7.moveTo(size.width * 0.7077719, size.height * 0.1028571);
    path_7.cubicTo(
        size.width * 0.7077105,
        size.height * 0.1072246,
        size.width * 0.7076813,
        size.height * 0.1116074,
        size.width * 0.7076813,
        size.height * 0.1160034);
    path_7.cubicTo(
        size.width * 0.7076813,
        size.height * 0.3788371,
        size.width * 0.8167076,
        size.height * 0.5919086,
        size.width * 0.9511988,
        size.height * 0.5919086);
    path_7.cubicTo(
        size.width * 0.9679123,
        size.height * 0.5919086,
        size.width * 0.9842339,
        size.height * 0.5886171,
        size.width,
        size.height * 0.5823486);
    path_7.lineTo(size.width, size.height * 0.3598303);
    path_7.cubicTo(
        size.width * 0.9848772,
        size.height * 0.3713989,
        size.width * 0.9684181,
        size.height * 0.3777497,
        size.width * 0.9511988,
        size.height * 0.3777497);
    path_7.cubicTo(
        size.width * 0.8772281,
        size.height * 0.3777497,
        size.width * 0.8172632,
        size.height * 0.2605617,
        size.width * 0.8172632,
        size.height * 0.1160034);
    path_7.cubicTo(
        size.width * 0.8172632,
        size.height * 0.1115949,
        size.width * 0.8173187,
        size.height * 0.1072120,
        size.width * 0.8174298,
        size.height * 0.1028571);
    path_7.lineTo(size.width * 0.7077719, size.height * 0.1028571);
    path_7.close();

    Paint paint_7_fill = Paint()..style = PaintingStyle.fill;
    paint_7_fill.color = Color(0xff6D4FA5).withOpacity(1.0);
    canvas.drawPath(path_7, paint_7_fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
