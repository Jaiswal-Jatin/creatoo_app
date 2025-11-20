import 'package:creatoo/core.dart';

class AppErrorWidget extends StatelessWidget {
  final String message;
  const AppErrorWidget({super.key, this.message = "Unexpected Error"});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Center(
        child: Text(message),
      ),
    );
  }
}
