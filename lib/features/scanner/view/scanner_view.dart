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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        title: Text(
          'QR Code',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Color(0xFFF8F9FF)],
          ),
        ),
        child: Form(
          key: viewModel.formKey,
          child: SingleChildScrollView(
            physics: BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: buildQrCodeSection(),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Uncomment and update if you want to include settings section
                  // Card(
                  //   elevation: 8,
                  //   shape: RoundedRectangleBorder(
                  //     borderRadius: BorderRadius.circular(20),
                  //   ),
                  //   child: Padding(
                  //     padding: EdgeInsets.all(20.0),
                  //     child: buildSettingsSection(),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildQrCodeSection() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Business Name
        Text(
          widget.businessName?.toUpperCase() ?? 'YOUR BUSINESS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColor.kPrimary,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Scan to Get Rewards',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 24),
        
        // QR Code Container
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // QR Code
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColor.kPrimary.withOpacity(0.2), width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: AppImageWidget(
                  height: 200,
                  width: 200,
                  imageUrl: qrImageUrl ?? '',
                  fit: BoxFit.contain,
                ),
              ),
              
              SizedBox(height: 20),
              
              // Download Button
              if (viewModel.isDownloading)
                CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColor.kPrimary))
              else
                Container(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      File? file = await viewModel.getImage();
                      if (file != null) {
                        print('Image saved to :${file.path}');
                        Utils.snackBar('QR code downloaded successfully!', result: Result.success);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.kPrimary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                      shadowColor: AppColor.kPrimary.withOpacity(0.3),
                    ),
                    icon: Icon(Icons.download_rounded, size: 22),
                    label: Text(
                      'Download QR Code',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        // Info Text
        Padding(
          padding: EdgeInsets.only(top: 24, left: 16, right: 16),
          child: Text(
            'Display this QR code at your business location. Customers can scan it to earn and redeem points.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13.sp,
              height: 1.5,
            ),
          ),
        ),
      ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        AppTextField(
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
                        child: Text('OK', style: TextStyle(color: AppColor.kPrimary)),
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
                        child: Text('OK', style: TextStyle(color: AppColor.kPrimary)),
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
          },
          controller: controller,
          textInputType: TextInputType.number,
          disableBorder: false,
          borderRadius: 12,
          contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          backgroundColor: Colors.grey[50],
          borderColor: Colors.grey[300]!,
          focusedBorderColor: AppColor.kPrimary,
          textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          inputFormatters: [formatter],
          validator: (value) {
            if (value == null || value.isEmpty) {
              if (label == "Set Discount %") {
                return 'Please enter a discount percentage';
              } else if (label == "Min Order Value") {
                return 'Please enter minimum order value';
              } else {
                return 'This field is required';
              }
            }

            if (label == 'Set Discount %') {
              final parsedValue = int.tryParse(value);
              if (parsedValue == null || parsedValue < 1 || parsedValue > 100) {
                return 'Must be between 1 and 100';
              }
            }

            if (label == 'Min Order Value') {
              final parsedValue = int.tryParse(value);
              if (parsedValue == null || parsedValue <= 0) {
                return 'Must be greater than 0';
              }
            }

            return null;
          },
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Points Expiry (In Days)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.kPrimary, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.red, width: 1.5),
              ),
            ),
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey[600]),
            value: viewModel.selectedValue,
            items: [
              DropdownMenuItem(
                value: "15",
                child: Text("15 days", style: TextStyle(fontSize: 15)),
              ),
              DropdownMenuItem(
                value: "30",
                child: Text("30 days (1 month)", style: TextStyle(fontSize: 15)),
              ),
              DropdownMenuItem(
                value: "360",
                child: Text("360 days (1 year)", style: TextStyle(fontSize: 15)),
              ),
              DropdownMenuItem(
                value: "Custom",
                child: Text("Custom days", style: TextStyle(fontSize: 15)),
              ),
            ],
            onChanged: (value) {
              viewModel.showTextField = false;
              viewModel.onDropdownChangeExpiry(value!);
              viewModel.notify();
            },
            validator: (value) => value == null || value.isEmpty ? 'Please select expiry days' : null,
          ),
        ),
        SizedBox(height: 16),
      ],
    );
  }

  Widget buildExpiryDateTextField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Custom Expiry Days',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
          SizedBox(height: 8),
          AppTextField(
            onChanged: (v) => viewModel.checkIfModified(),
            controller: viewModel.expDateController,
            textInputType: TextInputType.number,
            disableBorder: false,
            disallowZero: true,
            borderRadius: 12,
            contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            backgroundColor: Colors.grey[50],
            borderColor: Colors.grey[300]!,
            focusedBorderColor: AppColor.kPrimary,
            hintText: 'Enter number of days',
            hintStyle: TextStyle(color: Colors.grey[500]),
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            validator: (value) {
              if (value == null || value.isEmpty) return 'Please enter number of days';
              if (int.tryParse(value) == null) return 'Please enter a valid number';
              if (int.parse(value) <= 0) return 'Must be greater than 0';
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextFormField(
            onChanged: (v) => viewModel.checkIfModified(),
            controller: viewModel.noteController,
            maxLines: 4,
            style: TextStyle(fontSize: 15, color: Colors.grey[800]),
            decoration: InputDecoration(
              hintText: 'Enter any additional notes here...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              contentPadding: EdgeInsets.all(16),
              border: InputBorder.none,
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppColor.kPrimary, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildSaveButton() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if (!viewModel.isModified) {
                  Navigator.pop(context);
                } else if (viewModel.formKey.currentState?.validate() ?? false) {
                  await viewModel.updateBusinessSetting();
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.kPrimary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                shadowColor: AppColor.kPrimary.withOpacity(0.3),
              ),
              child: Text(
                'Save Changes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
