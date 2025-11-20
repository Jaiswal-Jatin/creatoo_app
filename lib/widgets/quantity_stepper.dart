import 'package:creatoo/core.dart';

class QuantityStepper extends StatefulWidget {
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  QuantityStepper({
    this.quantity = 1,
    required this.onQuantityChanged,
  });

  @override
  _QuantityStepperState createState() => _QuantityStepperState();
}

class _QuantityStepperState extends State<QuantityStepper> {
  late int _quantity;
  Color _minusButtonColor = AppColor.lightGrey;
  Color _plusButtonColor = AppColor.lightGrey; //Colors.grey[300]!;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
  }

  void _increment() {
    setState(() {
      _quantity++;
      widget.onQuantityChanged(_quantity);
      _plusButtonColor = AppColor.primary;
    });
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        _plusButtonColor = AppColor.lightGrey;
      });
    });
  }

  void _decrement() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
        widget.onQuantityChanged(_quantity);
        _minusButtonColor = AppColor.primary;
      });
      Future.delayed(Duration(milliseconds: 100), () {
        setState(() {
          _minusButtonColor = AppColor.lightGrey;
        });
      });
    } else {
      Utils.toastMessage("Quantity cannot be less than 1");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: AppColor.lightGrey,
        border: Border.all(
          color: AppColor.lightGrey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(Icons.remove, _decrement, _minusButtonColor),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            color: Colors.white,
            child: Text(
              '$_quantity',
              style: AppTextStyles.formHeaderStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          _buildActionButton(Icons.add, _increment, _plusButtonColor),
        ],
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, VoidCallback onPressed, Color color) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: icon == Icons.remove
              ? BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                )
              : BorderRadius.only(
                  topRight: Radius.circular(8),
                  bottomRight: Radius.circular(8),
                ),
        ),
        child: Icon(
          icon,
          color: color == AppColor.primary ? Colors.white : AppColor.darkGrey,
        ),
      ),
    );
  }
}
