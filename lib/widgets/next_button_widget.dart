import 'package:creatoo/core.dart';

class NextButtonWidget extends StatelessWidget {
  final Function() onNext;
  final int? answer; // Changed from String? to int?
  final bool isOptional;

  const NextButtonWidget({
    super.key,
    required this.onNext,
    required this.answer,
    this.isOptional = false,
  });

  void _handleNext(BuildContext context) {
    if (answer == null) {
      // No need to check for empty string
      if (!isOptional) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Please choose your answer before proceeding."),
          ),
        );
        return;
      }
    }
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      right: 0,
      left: 0,
      child: FloatingActionButton(
        onPressed: () => _handleNext(context),
        backgroundColor: AppColor.kPrimary,
        child: const Icon(Icons.arrow_forward, color: Colors.white),
      ),
    );
  }
}
