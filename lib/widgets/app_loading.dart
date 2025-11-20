import 'package:creatoo/core.dart';

class AppLoadingWidget extends StatelessWidget {
  final bool isApi;
  const AppLoadingWidget({super.key, this.isApi = false});

  @override
  Widget build(BuildContext context) {
    return isApi
        ? Center(child: CircularProgressIndicator())
        : AppScaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
  }
}
