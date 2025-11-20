import 'package:creatoo/widgets/app_text_widget.dart';
import 'package:flutter/services.dart';

import '../../../core.dart';
import '../view_model/scanner_view_model.dart';

class ScannerView extends StatefulWidget {
  final String? businessName;
  final String? qrUrl;

  const ScannerView({
    Key? key,
    required this.qrUrl,
    required this.businessName,
  }) : super(key: key);

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  late ScannerViewModel viewModel;
  String? qrImageUrl;

  @override
  void initState() {
    qrImageUrl = widget.qrUrl;
    super.initState();
    viewModel = Provider.of<ScannerViewModel>(context, listen: false);
    viewModel.init(qrImageUrl!);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      final newQrUrl = args['qrUrl'] as String?;
      if (newQrUrl != null && newQrUrl != qrImageUrl) {
        setState(() {
          qrImageUrl = newQrUrl;
        });
        viewModel.init(newQrUrl);
      }
    }
  }

  @override
  void dispose() {
    viewModel.isModified = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<ScannerViewModel>(context);

    return buildMobileBody();

    // switch (viewModel.scannerResponse.status) {
    //   case Status.loading:
    //     return AppLoadingWidget();
    //   case Status.error:
    //     return AppErrorWidget(message: viewModel.scannerResponse.message.toString());
    //   case Status.completed:
    //     return buildMobileBody();
    //   default:
    //     return AppNoDataWidget();
    // }
  }

  Widget buildMobileBody() {
    return AppScaffold(
      appBar: AppBarWidget(),
      body: Form(
        key: viewModel.formKey,
        child: Container(
          width: SizeConfig.screenWidth,
          margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                buildQrCodeSection(),
                //TODO: Remove TextField section after confirmation

                // SizedBox(height: 10.h),
                // Divider(color: AppColor.darkGrey, thickness: 0.5),
                // SizedBox(height: 10.h),
                // buildSettingsSection(),
                // SizedBox(height: 100.h),
              ],
            ),
          ),
        ),
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // floatingActionButton: buildSaveButton(),
    );
  }

  Widget buildQrCodeSection() {
    return Center(
      child: Column(
        children: [
          Text(
            widget.businessName ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
          ),
          SizedBox(height: 15.h),
          LayoutBuilder(
            builder: (context, constraints) {
              double size = constraints.maxWidth * 0.8;
              size = size > 350 ? 350 : size;
              return ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: AppImageWidget(
                    height: size,
                    width: size,
                    imageUrl: qrImageUrl ?? '',
                    fit: BoxFit.contain,
                    borderRadius: 5,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 20.h),
          (viewModel.isDownloading)
              ? AppLoadingWidget(
                  isApi: true,
                )
              : GestureDetector(
                  onTap: () async {
                    File? file = await viewModel.getImage();
                    if (file != null) {
                      print('Image saved to :${file.path}');
                      Utils.snackBar('QR code downloaded', result: Result.success);
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.download, size: 25.sp, color: AppColor.kPrimary),
                      SizedBox(width: 5.w),
                      Text(
                        'Download QR',
                        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  Widget buildSettingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSettingField(
          'Set Discount %',
          viewModel.discountController,
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ),
        SizedBox(height: 10),
        buildSettingField('Min Order Value', viewModel.minOrderController, FilteringTextInputFormatter.digitsOnly),
        SizedBox(height: 10),
        buildDropdownField(),
        if (viewModel.showTextField) buildExpiryDateTextField(),
        SizedBox(height: 10),
        buildNoteField(),
      ],
    );
  }

  Widget buildSettingField(String label, TextEditingController controller, TextInputFormatter formatter) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(fontSize: 16))),
        Expanded(
          child: AppTextField(
            onChanged: (value) {
              viewModel.checkIfModified();

              if (label == 'Set Discount %') {
                final parsedValue = int.tryParse(value);
                if (parsedValue != null && (parsedValue > 100 || parsedValue < 1)) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Invalid Value'),
                      content: Text('Value should be between 1 to 100.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );

                  controller.text = '';
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }
              }

              if (label == 'Min Order Value') {
                final parsedValue = int.tryParse(value);
                if (parsedValue != null && parsedValue <= 0) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Invalid Value'),
                      content: Text('Min Order Value must be greater than 0.'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );

                  // Reset the value to 1
                  controller.text = '';
                  controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length),
                  );
                }
              }
            },
            controller: controller,
            textInputType: TextInputType.number,
            disableBorder: false,
            borderRadius: 10,
            inputFormatters: [formatter],
            validator: (value) {
              if (value == null || value.isEmpty) {
                if (label == "Set Discount %")
                  return 'Enter Discount';
                else if (label == "Min Order Value")
                  return 'Enter Min Order Value';
                else
                  return '$value';
              }

              if (label == 'Set Discount %') {
                final parsedValue = int.tryParse(value);
                if (parsedValue == null || parsedValue < 1 || parsedValue > 100) {
                  return 'Value must be between 1 and 100';
                }
              }

              if (label == 'Min Order Value') {
                final parsedValue = int.tryParse(value);
                if (parsedValue == null || parsedValue <= 0) {
                  return 'Min Order Value must be greater than 0.';
                }
              }

              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget buildDropdownField() {
    return Row(
      children: [
        Expanded(
          child: Text('Points Expiry (In Days)', style: TextStyle(fontSize: 16)),
        ),
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFDADADA)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Color(0xFFDADADA)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColor.kPrimary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red),
              ),
            ),
            value: viewModel.selectedValue,
            items: [
              DropdownMenuItem(value: "15", child: AppTextWidget(text: "15")),
              DropdownMenuItem(value: "30", child: AppTextWidget(text: "30")),
              DropdownMenuItem(value: "360", child: AppTextWidget(text: "360")),
              DropdownMenuItem(value: "Custom", child: AppTextWidget(text: "Custom")),
            ],
            onChanged: (value) {
              viewModel.showTextField = false;
              viewModel.onDropdownChangeExpiry(value!);
              viewModel.notify();
            },
            validator: (value) => value == null || value.isEmpty ? 'Required Days' : null,
          ),
        ),
      ],
    );
  }

  Widget buildExpiryDateTextField() {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: AppTextField(
        onChanged: (v) => viewModel.checkIfModified(),
        controller: viewModel.expDateController,
        textInputType: TextInputType.number,
        disableBorder: false,
        disallowZero: true,
        borderRadius: 10,
        hintText: 'Enter Points Expiry(In Days)',
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        validator: (value) {
          if (value == null || value.isEmpty) return 'Enter Days';
          if (int.tryParse(value) == null) return 'Enter Valid Days';
          if (int.parse(value) == 0) return 'Value cannot be 0';
          return null;
        },
      ),
    );
  }

  Widget buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Note', style: TextStyle(fontSize: 16)),
        SizedBox(height: 5),
        AppTextField(
          onChanged: (v) => viewModel.checkIfModified(),
          maxLines: 5,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          controller: viewModel.noteController,
          disableBorder: false,
          borderRadius: 10,
        ),
      ],
    );
  }

  Widget buildSaveButton() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 10),
      child: AppButton(
        text: "Save",
        isLoading: false,
        onTap: () async {
          if (!viewModel.isModified) {
            Navigator.pop(context);
          } else if (viewModel.formKey.currentState?.validate() ?? false) {
            await viewModel.updateBusinessSetting();
            Navigator.pop(context);
            // Navigator.pushReplacement(
            //   context,
            //   MaterialPageRoute(
            //     builder: (context) => HomePage(),
            //   ),
            // );
          }
        },
      ),
    );
  }
}
