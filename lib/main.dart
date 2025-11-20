import 'package:flutter/services.dart';

import 'core.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await Future.wait([
    NotificationService.initialize(),
    dotenv.load(fileName: Constants.dotEnv),
    FirebaseMessagingService.initialise(),
  ]);

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: Providers.getAllProviders(),
      child: MyApp(),
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
              initialRoute: RoutesName.onboardingView,
              onGenerateRoute: Routes.generateRoute,
              navigatorKey: navigatorKey,
            );
          },
        );
      },
    );
  }
}
