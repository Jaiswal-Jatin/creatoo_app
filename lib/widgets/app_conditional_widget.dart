import '../core.dart';

class AppConditionalWidget extends StatelessWidget {
  final Widget child;
  final bool visibility;

  const AppConditionalWidget(
      {super.key, required this.child, this.visibility = true});

  @override
  Widget build(BuildContext context) {
    return visibility ? child : SizedBox.shrink();
  }
}
