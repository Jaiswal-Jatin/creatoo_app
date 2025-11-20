import '../core.dart';

class ImageTextDialog extends StatefulWidget {
  @override
  _ImageTextDialogState createState() => _ImageTextDialogState();
}

class _ImageTextDialogState extends State<ImageTextDialog> {
  final TextEditingController _textController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool? isValid;

  void _pickImage() async {
    final pickedImage = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog.adaptive(
      title: Text(
        'Verify Instagram Account',
        maxLines: 2,
        textAlign: TextAlign.center,
        style: AppTextStyles.appBarTitleTextStyle.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Text Input Field
            AppTextField(
              controller: _textController,
              disableBorder: false,
              borderRadius: 10,
              hintText: "Enter Instagram username",
              onChanged: (v) {
                setState(() {});
              },
              validator: (value) => Validator.validateInstagramUsername(value),
            ),
            SizedBox(height: 20),

            AppDottedBorderContainer(
              width: SizeConfig.screenWidth,
              height: 160.h,
              color: isValid == null
                  ? AppColor.primary
                  : isValid!
                      ? AppColor.primary
                      : AppColor.darkRed,
              borderRadius: BorderRadius.circular(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Visibility(
                    visible: (_image != null),
                    child: Image.file(
                      // color: Colors.orange,
                      File(_image?.path ?? ""),
                      height: 100.h,
                      width: 100.h,
                      fit: BoxFit.contain,
                    ),
                    replacement: Column(
                      children: [
                        SvgPicture.asset(AppIcon.folder),
                        SizedBox(height: 10.h),
                        Text(
                          'Upload Instagram Profile Screenshot',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => _pickImage(),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        vertical: 7,
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColor.primary),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _image == null ? 'Upload' : 'Change Image',
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w400,
                          color: AppColor.primary,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        // Cancel Button
        Container(
          margin: EdgeInsets.only(right: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              SizedBox(width: 10.w),
              // Submit Button
              ElevatedButton(
                onPressed: () {
                  isValid = _formKey.currentState?.validate();
                  if (isValid!) {
                    if (_image == null) {
                      isValid = false;
                      return Utils.toastMessage(
                          "Please upload instagram profile screenshot");
                    }
                    Navigator.of(context).pop({
                      'text': _textController.text,
                      'image': _image!.path,
                    });
                  }
                  setState(() {});
                },
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
