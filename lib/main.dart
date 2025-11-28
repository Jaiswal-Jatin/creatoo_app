import 'package:creatoo/features/card/view_model/card_view_model.dart';
import 'package:flutter/services.dart';

import 'features/card/view_model/card_visit_view_model.dart';
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
      providers: [
        ...Providers.getAllProviders(),
        ChangeNotifierProvider(create: (_) => CardViewModel()),
        ChangeNotifierProvider(create: (_) => CardVisitViewModel()),
      ],
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
