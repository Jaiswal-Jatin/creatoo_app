import '/core.dart';

class AppChipChoiceWidget extends StatefulWidget {
  final List<String> options;
  final List<String> selectedItems;
  final Function(String, bool) onSelectionChanged;

  const AppChipChoiceWidget({
    super.key,
    required this.options,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  _AppChipChoiceWidgetState createState() => _AppChipChoiceWidgetState();
}

class _AppChipChoiceWidgetState extends State<AppChipChoiceWidget> {
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _chipKeys = {};

  @override
  void initState() {
    super.initState();
    // Initialize GlobalKeys for each chip
    for (int i = 0; i < widget.options.length; i++) {
      _chipKeys[i] = GlobalKey();
    }
  }

  void _scrollToTile(int index) {
    final chipKey = _chipKeys[index];
    if (chipKey != null) {
      final context = chipKey.currentContext;
      if (context != null) {
        final RenderBox chipBox = context.findRenderObject() as RenderBox;
        final RenderBox listBox = _scrollController.position.context.storageContext.findRenderObject() as RenderBox;

        // Get the chip's position relative to the ListView
        final double chipLeftInListView = chipBox.localToGlobal(Offset.zero, ancestor: listBox).dx;
        final double chipWidth = chipBox.size.width;

        // Current scroll offset of the ListView
        final double currentOffset = _scrollController.offset;

        double targetOffset = currentOffset;

        if (chipLeftInListView < 0) {
          // Case 1: Chip is partially or fully off-screen to the left
          targetOffset = currentOffset + chipLeftInListView - 10; // Add small padding
        } else if (chipLeftInListView + chipWidth > listBox.size.width) {
          // Case 2: Chip is partially or fully off-screen to the right
          targetOffset = currentOffset + (chipLeftInListView + chipWidth - listBox.size.width) + 10; // Add small padding
        }

        // Clamp the targetOffset within scrollable bounds
        targetOffset = targetOffset.clamp(0, _scrollController.position.maxScrollExtent);

        // Smoothly scroll to the target offset
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.options.isNotEmpty)
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: widget.options.length,
              itemBuilder: (context, index) {
                String option = widget.options[index];
                bool isSelected = widget.selectedItems.contains(option);

                return GestureDetector(
                  key: _chipKeys[index], // Assign a unique key to each chip
                  onTap: () {
                    _scrollToTile(index);
                    widget.onSelectionChanged(option, !isSelected);
                  },
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.symmetric(horizontal: 4.0),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColor.primary : AppColor.moreLighterDd.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? AppColor.white : AppColor.white,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? AppColor.white : AppColor.black,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
