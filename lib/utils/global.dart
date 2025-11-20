import 'package:flutter/material.dart';

import '../features/verify_otp/model/verify_otp_model.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
String? token;
String? fcmToken;
int? userId;
int? roleId;
UserData? user;
String? base64AppLogo;
int instaVerication = 3;
