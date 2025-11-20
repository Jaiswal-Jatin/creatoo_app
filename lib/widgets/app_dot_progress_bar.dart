import '../core.dart';
import '../features/feedback/view_model/feedback_view_model.dart';

class CustomProgressBar extends StatefulWidget {
  final int selectedIndex;
  final Function(int)? onDotTap;
  final Color progressColor;
  final Color backgroundColor;
  final Color selectedDotColor;
  final Color dotColor;
  final bool useStarIcon;

  const CustomProgressBar({
    super.key,
    required this.selectedIndex,
    this.onDotTap,
    this.progressColor = AppColor.kPrimary,
    this.backgroundColor = AppColor.moreLighterDd,
    this.selectedDotColor = AppColor.white,
    this.dotColor = AppColor.black,
    this.useStarIcon = false,
  });

  @override
  _CustomProgressBarState createState() => _CustomProgressBarState();
}

class _CustomProgressBarState extends State<CustomProgressBar> {
  late FeedbackViewModel viewModel;
  late double dragPosition;
  late double segmentWidth;

  @override
  void initState() {
    viewModel = Provider.of<FeedbackViewModel>(context, listen: false);
    dragPosition = widget.selectedIndex.toDouble();
    super.initState();
  }

  void _updatePosition(double dx, double maxWidth) {
    dragPosition = (dx / maxWidth) * 5;
    dragPosition = dragPosition.clamp(0.0, 4.0);
    viewModel.notify();
    widget.onDotTap?.call(dragPosition.round());
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<FeedbackViewModel>(context);

    return GestureDetector(
      onTapUp: (details) => _updatePosition(details.localPosition.dx, MediaQuery.of(context).size.width),
      onHorizontalDragUpdate: (details) => _updatePosition(details.localPosition.dx, MediaQuery.of(context).size.width),
      child: Container(
        width: double.infinity,
        height: 40,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                segmentWidth = constraints.maxWidth / 5;
                double progressWidth = (dragPosition + 1) * segmentWidth;

                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: dragPosition.round() == 4
                      ? constraints.maxWidth // Full width for 5th dot
                      : ((dragPosition.round() + 0.61) * segmentWidth), // Stop at center of selected dot
                  height: 40,
                  decoration: BoxDecoration(
                    color: widget.progressColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(5, (index) {
                return Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: index == dragPosition.round() ? widget.selectedDotColor : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: widget.useStarIcon
                        ? Icon(
                            Icons.star,
                            color: index == dragPosition.round() ? AppColor.orange : widget.dotColor,
                            size: 16,
                          )
                        : Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: widget.dotColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
