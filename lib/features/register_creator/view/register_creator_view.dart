import 'dart:ui';
import 'package:creatoo/core.dart';
import 'package:creatoo/features/register_creator/view_model/register_creator_view_model.dart';
import 'package:creatoo/widgets/custom_back_button.dart';

class RegisterCreatorView extends StatefulWidget {
  final String phone;

  const RegisterCreatorView({super.key, required this.phone});

  @override
  State<RegisterCreatorView> createState() => _RegisterCreatorViewState();
}

class _RegisterCreatorViewState extends State<RegisterCreatorView> {
  late RegisterCreatorViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<RegisterCreatorViewModel>(context, listen: false);
    viewModel.init(widget.phone);
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<RegisterCreatorViewModel>(context);
    
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, RoutesName.startupView, (route) => false);
        return true;
      },
      child: AppScaffold(
        useGradient: true,
        backgroundColor: AppColor.premiumBg,
        isSafe: false,
        body: Stack(
          children: [
            // Background Glows
            Positioned(
              top: -100.h,
              right: -100.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
                child: Container(
                  width: 300.w,
                  height: 300.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.premiumAccent.withOpacity(0.15),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 100.h,
              left: -50.w,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 80, sigmaY: 80),
                child: Container(
                  width: 200.w,
                  height: 200.w,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColor.premiumAccent.withOpacity(0.1),
                  ),
                ),
              ),
            ),

            // Main Content
            SafeArea(
              child: Form(
                key: viewModel.formKey,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(24.w, 80.h, 24.w, 100.h),
                  child: Column(
                    children: <Widget>[
                      // Profile Picture Picker
                      GestureDetector(
                        onTap: () async => await viewModel.getImageAttachment(),
                        child: AppValidator(
                          validator: false,
                          isValidating: false,
                          errorMessage: "Please select profile image",
                          alignment: Alignment.center,
                          child: Center(
                            child: Stack(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(4.w),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColor.premiumAccent.withOpacity(0.5),
                                      width: 2,
                                    ),
                                  ),
                                  child: viewModel.model.userImage == null
                                      ? Container(
                                          height: 110.h,
                                          width: 110.h,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white.withOpacity(0.05),
                                          ),
                                          child: Icon(
                                            Icons.person_outline,
                                            size: 60.h,
                                            color: Colors.white.withOpacity(0.2),
                                          ),
                                        )
                                      : CircleAvatar(
                                          radius: 55.h,
                                          backgroundImage: FileImage(
                                            File(viewModel.model.userImage!),
                                          ),
                                        ),
                                ),
                                Positioned(
                                  bottom: 5.h,
                                  right: 5.h,
                                  child: Container(
                                    height: 36.h,
                                    width: 36.h,
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColor.premiumAccent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: AppColor.premiumBg,
                                        width: 3,
                                      ),
                                    ),
                                    child: SvgPicture.asset(
                                      AppIcon.edit,
                                      colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40.h),

                      // Registration Card
                      ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                          child: Container(
                            padding: EdgeInsets.all(24.w),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                AppForm(
                                  title: 'Creator Registration',
                                  textColor: Colors.white,
                                  textFieldBackgroundColor: Colors.transparent,
                                  hintTexts: const [
                                    "Full Name",
                                    "City",
                                  ],
                                  onDataChanged: (List<String> data) => viewModel.updateForm(data),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  ' Mobile Number',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                AppTextField(
                                  controller: TextEditingController(text: widget.phone),
                                  backgroundColor: Colors.transparent,
                                  textColor: Colors.white,
                                  readOnly: true,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 18.h),
                                  disableBorder: false,
                                  maxLength: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Back Button and Title (on top)
            Positioned(
              top: MediaQuery.of(context).padding.top + 10.h,
              left: 16.w,
              child: CustomBackButton(
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 15.h,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    "Creator Registration",
                    style: GoogleFonts.montserrat(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 10.h),
          child: AppButton(
            text: "Complete Registration",
            isLoading: viewModel.creatorResponse.status == Status.loading,
            onTap: () async {
              viewModel.setValidatingStatus(true);
              if (viewModel.formKey.currentState!.validate()) {
                await viewModel.registerCreator();
              }
            },
          ),
        ),
      ),
    );
  }
}
