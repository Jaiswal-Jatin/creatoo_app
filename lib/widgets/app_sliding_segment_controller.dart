import '../core.dart';

class AppSlidingSegmentController extends StatefulWidget {
  final double height;
  final double borderRadius;
  final String name1;
  final String name2;
  int index;
  final Function(int)? onTap;

  AppSlidingSegmentController({
    Key? key,
    this.height = 60,
    this.borderRadius = 50,
    required this.name1,
    required this.name2,
    this.onTap,
    this.index = 0,
  }) : super(key: key);

  @override
  _AppSlidingSegmentControllerState createState() => _AppSlidingSegmentControllerState();
}

class _AppSlidingSegmentControllerState extends State<AppSlidingSegmentController> {
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
    widget.index = 0;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width / 2.3;
    return Container(
      height: widget.height,
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color(0xFFECEAFF),
        borderRadius: BorderRadius.circular(widget.borderRadius),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            alignment: _currentSelection == 0 ? Alignment.centerLeft : Alignment.centerRight,
            duration: Duration(milliseconds: 500),
            curve: Curves.ease,
            child: Container(
              height: widget.height,
              width: width,
              decoration: BoxDecoration(
                color: AppColor.white,
                borderRadius: BorderRadius.circular(widget.borderRadius),
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

  Widget _buildSegment({required String name, required bool isSelected, required VoidCallback onTap}) {
    double width = MediaQuery.of(context).size.width / 2.3;
    return GestureDetector(
      onTap: onTap,
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
            fontSize: 16.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
