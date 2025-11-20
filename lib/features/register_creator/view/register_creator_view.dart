import 'package:creatoo/core.dart';
import 'package:creatoo/features/register_creator/view_model/register_creator_view_model.dart';

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
        appBar: AppBarWidget(
          title: "User Registration",
          onPop: () {
            Navigator.popUntil(context, (route) => route.isFirst);
          },
        ),
        body: SafeArea(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            child: Form(
              key: viewModel.formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () async => await viewModel.getImageAttachment(),
                          child: AppValidator(
                            // validator: (viewModel.model.userImage == null),
                            validator: false,
                            // isValidating: viewModel.isValidating,
                            isValidating: false,
                            errorMessage: "Please select profile image",
                            alignment: Alignment.center,
                            child: Center(
                              child: Stack(
                                children: [
                                  viewModel.model.userImage == null
                                      ? Icon(
                                          Icons.account_circle,
                                          size: 120.h,
                                          color: AppColor.darkGrey.withOpacity(0.5),
                                        )
                                      : CircleAvatar(
                                          radius: 50.h,
                                          backgroundImage: FileImage(
                                            File(viewModel.model.userImage!),
                                          ),
                                        ),
                                  Positioned(
                                    bottom: viewModel.model.userImage == null ? 10 : 0,
                                    right: viewModel.model.userImage == null ? 10 : 0,
                                    child: Container(
                                      height: 40.h,
                                      width: 40.h,
                                      padding: EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: AppColor.primary,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColor.white,
                                          width: 5,
                                          strokeAlign: BorderSide.strokeAlignCenter,
                                        ),
                                      ),
                                      child: SvgPicture.asset(AppIcon.edit),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        AppForm(
                          title: 'Creator Registration',
                          hintTexts: const [
                            "Full Name",
                            // "Email",
                            "City",
                          ],
                          onDataChanged: (List<String> data) => viewModel.updateForm(data),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          padding: EdgeInsets.only(left: 5),
                          child: Text(
                            'Mobile Number',
                            style: GoogleFonts.montserrat(
                              textStyle: Theme.of(context).textTheme.displayLarge,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColor.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        AppTextField(
                          controller: TextEditingController(text: widget.phone),
                          hintText: "Enter Mobile number",
                          textInputType: TextInputType.number,
                          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                          disableBorder: false,
                          readOnly: true,
                          maxLength: 10,
                          validator: (value) => Validator.validate(value.toString(), "Mobile number"),
                        ),
                        // SizedBox(height: 20.h),
                        // Container(
                        //   padding: EdgeInsets.only(left: 5),
                        //   child: Text(
                        //     'Instagram Username',
                        //     style: GoogleFonts.montserrat(
                        //       textStyle:
                        //           Theme.of(context).textTheme.displayLarge,
                        //       fontSize: 15.sp,
                        //       fontWeight: FontWeight.w400,
                        //       color: AppColor.black,
                        //     ),
                        //   ),
                        // ),
                        // SizedBox(height: 10.h),
                        // AppTextField(
                        //   controller: viewModel.instaUserController,
                        //   hintText: "Enter Instagram username",
                        //   textInputType: TextInputType.text,
                        //   contentPadding: EdgeInsets.symmetric(
                        //       horizontal: 25, vertical: 18),
                        //   disableBorder: false,
                        //   showSuffixIcon: true,
                        //   readOnly: viewModel.userVerified,
                        //   suffixIcon: viewModel.userVerified
                        //       ? Icon(Icons.verified)
                        //       : null,
                        //   capitaliseText: TextCapitalization.none,
                        //   validator: (value) => Validator.validate(
                        //       value.toString(), "Instagram username"),
                        // ),
                        // SizedBox(height: 10.h),
                        // AppValidator(
                        //   validator: !viewModel.userVerified,
                        //   isValidating: viewModel.isValidating,
                        //   errorMessage: "Please Connect Instagram",
                        //   child: OutlinedButton(
                        //     onPressed: viewModel.isLoading
                        //         ? null
                        //         : viewModel.userVerified
                        //             ? null
                        //             : () async {
                        //                 if (viewModel.instaUserController.text
                        //                     .trim()
                        //                     .isEmpty) {
                        //                   Utils.toastMessage(
                        //                       "Enter username to connect Instagram");
                        //                 }
                        //                 if (viewModel.formKey.currentState!
                        //                     .validate()) {
                        //                   await viewModel.fetchInstaUser();
                        //                 }
                        //               },
                        //     child: viewModel.isLoading
                        //         ? CircularProgressIndicator()
                        //         : Text('Connect Instagram'),
                        //     style: OutlinedButton.styleFrom(
                        //       shape: StadiumBorder(
                        //         side: BorderSide(
                        //           style: BorderStyle.solid,
                        //           color: AppColor.black,
                        //         ),
                        //       ),
                        //       minimumSize: Size(
                        //         double.infinity,
                        //         50.h,
                        //       ),
                        //     ),
                        //   ),
                        // ),
                        SizedBox(height: 120.h),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.h),
          child: AppButton(
            text: "Continue",
            isLoading: viewModel.creatorResponse.status == Status.loading,
            onTap: () async {
              viewModel.setValidatingStatus(true);
              if (viewModel.formKey.currentState!.validate()) {
                // if(registerCreatorViewModel.model.instagramUsername == null){
                //   return Utils.toastMessage("Please Connect instagram");
                // }

                // if (viewModel.model.userImage == null) {
                //   return Utils.toastMessage("Please attach image");
                // }
                // if (viewModel.userVerified == false) {
                //   return Utils.toastMessage("Please Connect Instagram");
                // }

                await viewModel.registerCreator();
              }
            },
          ),
        ),
      ),
    );
  }
}
