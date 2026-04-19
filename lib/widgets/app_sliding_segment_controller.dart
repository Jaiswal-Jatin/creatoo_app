import '../core.dart';

class AppSlidingSegmentController extends StatefulWidget {
  final double height;
  final double borderRadius;
  final String name1;
  final String name2;
  final int index;
  final Function(int)? onTap;
  const AppSlidingSegmentController({
    super.key,
    this.height = 60,
    this.borderRadius = 50,
    required this.name1,
    required this.name2,
    this.onTap,
    this.index = 0,
  });

  @override
  _AppSlidingSegmentControllerState createState() =>
      _AppSlidingSegmentControllerState();
}

class _AppSlidingSegmentControllerState
    extends State<AppSlidingSegmentController> {
  int _currentSelection = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    if (widget.index != 0) {
      _currentSelection = widget.index;
    }
    setState(() {});
  }

  @override
  void dispose() {
    _currentSelection = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2.3;
    return Container(
      height: widget.height,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05), // 'trafart' (transparent) base
        borderRadius: BorderRadius.circular(widget.borderRadius),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _currentSelection == 0
                ? Alignment.centerLeft
                : Alignment.centerRight,
            duration: Duration(milliseconds: 300),
            curve: Curves.easeOutQuart,
            child: Container(
              height: widget.height,
              width: width,
              decoration: BoxDecoration(
                color: AppColor.premiumAccent.withOpacity(0.2), // Active pill
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(color: AppColor.premiumAccent.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.premiumAccent.withOpacity(0.2),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  )
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSegment(
                  name: widget.name1,
                  isSelected: _currentSelection == 0,
                  onTap: () {
                    setState(() {
                      _currentSelection = 0;
                      widget.onTap!(_currentSelection);
                    });
                  }),
              _buildSegment(
                  name: widget.name2,
                  isSelected: _currentSelection == 1,
                  onTap: () {
                    setState(() {
                      _currentSelection = 1;
                      widget.onTap!(_currentSelection);
                    });
                  }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(
      {required String name,
      required bool isSelected,
      required VoidCallback onTap}) {
    double width = MediaQuery.of(context).size.width / 2.3;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: widget.height,
        alignment: Alignment.center,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius),
        ),
        child: Text(
          name,
          style: TextStyle(
            fontSize: 14.sp, // Reduced slightly to look sleek
            color: isSelected ? AppColor.white : AppColor.premiumTextSecondary,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
