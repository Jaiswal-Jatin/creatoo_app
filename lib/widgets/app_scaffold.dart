import '../core.dart';

class AppScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;
  final Widget? drawer;
  final Widget? endDrawer;
  final Color? backgroundColor;
  final Gradient? gradient;
  final bool useGradient; // New flag to control gradient behavior
  final bool resizeToAvoidBottomInset;
  final List<Widget>? persistentFooterButtons;
  final Widget? bottomNavigationBar;
  final Widget? bottomSheet;
  final bool extendBody;
  final bool extendBodyBehindAppBar;
  final bool primary;
  final bool isSafe;

  const AppScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
    this.drawer,
    this.endDrawer,
    this.backgroundColor,
    this.gradient,
    this.useGradient = true, // Default: Gradient enabled
    this.resizeToAvoidBottomInset = true,
    this.persistentFooterButtons,
    this.bottomNavigationBar,
    this.bottomSheet,
    this.extendBody = false,
    this.extendBodyBehindAppBar = false,
    this.primary = true,
    this.isSafe = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (useGradient) // Apply gradient only when useGradient is true
          Container(
            decoration: BoxDecoration(
              color: AppColor.premiumBg, // Solid base so transparency doesn't bleed
              gradient: gradient ?? AppGradient.scaffoldGradient,
            ),
          ),
        Scaffold(
          extendBodyBehindAppBar: extendBodyBehindAppBar,
          appBar: appBar,
          body: isSafe ? SafeArea(child: body!) : body,
          floatingActionButton: floatingActionButton,
          floatingActionButtonLocation: floatingActionButtonLocation,
          drawer: drawer,
          endDrawer: endDrawer,
          backgroundColor: useGradient ? Colors.transparent : (backgroundColor ?? Colors.white),
          resizeToAvoidBottomInset: resizeToAvoidBottomInset,
          persistentFooterButtons: persistentFooterButtons,
          bottomNavigationBar: bottomNavigationBar,
          bottomSheet: bottomSheet,
          extendBody: extendBody,
          primary: primary,
        ),
      ],
    );
  }
}
