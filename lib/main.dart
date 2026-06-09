import 'package:creatoo/features/card/view_model/card_view_model.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/services.dart';

import 'features/card/view_model/card_visit_view_model.dart';
import 'utils/deep_link_service.dart';
import 'core.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Future.wait([
    NotificationService.initialize(),
   
    FirebaseMessagingService.initialise(),
    DeepLinkService.initialize(), // Initialize deep link handling
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    DevicePreview(
      enabled: false, // Device preview enabled
      builder: (context) => MultiProvider(
        providers: [
          ...Providers.getAllProviders(),
          ChangeNotifierProvider(create: (_) => CardViewModel()),
          ChangeNotifierProvider(create: (_) => CardVisitViewModel()),
        ],
        child: MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        return OrientationBuilder(
          builder: (BuildContext context, Orientation orientation) {
            SizeConfig.init(constraints, orientation);
            return MaterialApp(
              debugShowCheckedModeBanner: !Constants.isProduction,
              title: Constants.appName,
              themeMode: ThemeMode.light,
              theme: AppTheme.lightTheme,
              initialRoute: RoutesName.splashView,
              onGenerateRoute: Routes.generateRoute,
              navigatorKey: navigatorKey,
              locale: DevicePreview.locale(context),
              builder: DevicePreview.appBuilder,
            );
          },
        );
      },
    );
  }
}
