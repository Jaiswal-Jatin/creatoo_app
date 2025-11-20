import '../core.dart';

Widget ImageErrorWidget(context, url, error) => Image.asset(
      Images.appLogo,
      fit: BoxFit.cover,
    );

Widget DefaultProfileWidget(double size) => Icon(
      Icons.account_circle,
      size: size,
      color: AppColor.darkGrey.withOpacity(0.5),
    );

Widget ImagePlaceholderWidget(context, url) => const LinearProgressIndicator();
