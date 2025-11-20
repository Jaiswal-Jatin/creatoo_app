import 'package:creatoo/core.dart';
import 'package:creatoo/features/register_business/model/business_type_response.dart';
import 'package:creatoo/features/register_business/view_model/register_business_view_model.dart';
import 'package:dropdown_search/dropdown_search.dart';

class RegisterBusinessView extends StatefulWidget {
  final String phone;

  const RegisterBusinessView({super.key, required this.phone});

  @override
  State<RegisterBusinessView> createState() => _RegisterBusinessViewState();
}

class _RegisterBusinessViewState extends State<RegisterBusinessView> {
  @override
  void initState() {
    super.initState();
    final RegisterBusinessViewModel registerBusinessViewModel = Provider.of<RegisterBusinessViewModel>(context, listen: false);
    registerBusinessViewModel.init(widget.phone);
  }

  @override
  Widget build(BuildContext context) {
    final RegisterBusinessViewModel viewModel = Provider.of<RegisterBusinessViewModel>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushNamedAndRemoveUntil(context, RoutesName.startupView, (route) => false);
        return true;
      },
      child: AppScaffold(
        appBar: AppBarWidget(
          title: "Business Registration",
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    GestureDetector(
                      onTap: () async => await viewModel.getImageAttachment(),
                      child: AppValidator(
                        validator: (viewModel.model.businessImage == null),
                        isValidating: viewModel.isValidating,
                        errorMessage: "Please select profile image",
                        alignment: Alignment.center,
                        child: Center(
                          child: Stack(
                            children: [
                              viewModel.model.businessImage == null
                                  ? Icon(
                                      Icons.account_circle,
                                      size: 120.h,
                                      color: AppColor.darkGrey.withOpacity(0.2),
                                    )
                                  : CircleAvatar(
                                      radius: 50.h,
                                      backgroundImage: FileImage(
                                        File(viewModel.model.businessImage!),
                                      ),
                                    ),
                              Positioned(
                                bottom: viewModel.model.businessImage == null ? 10 : 0,
                                right: viewModel.model.businessImage == null ? 10 : 0,
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
                      title: 'Business Registration',
                      hintTexts: ["Business Name", "Area", "Complete Address", "Website Url"],
                      onDataChanged: (List<String> data) => viewModel.updateBusinessRegistrationForm(data),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Business Representative Details',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    AppForm(
                      title: 'Business Representative',
                      hintTexts: [
                        "Full Name",
                        "Designation",
                        "Business mail",
                      ],
                      onDataChanged: (List<String> data) => viewModel.updateBusinessRepresentativeForm(data),
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
                          color: AppColor.lightBack,
                        ),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Container(
                      margin: EdgeInsets.only(right: 1),
                      child: AppTextField(
                        controller: TextEditingController(text: widget.phone),
                        hintText: "Enter Mobile number",
                        textInputType: TextInputType.number,
                        contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                        disableBorder: false,
                        readOnly: true,
                        maxLength: 10,
                        validator: (value) => Validator.validate(value.toString(), "Mobile number"),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Documentation',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16.sp,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    AppForm(
                      title: 'Documentation',
                      hintTexts: ["GSTIN"],
                      capitaliseText: TextCapitalization.characters,
                      maxLength: 15,
                      onDataChanged: (List<String> data) => viewModel.updateDocumentationForm(
                        value: data.first.toUpperCase(),
                      ),
                    ),
                    Text(
                      'Business Type',
                      style: GoogleFonts.montserrat(
                        textStyle: Theme.of(context).textTheme.displayLarge,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF191D23),
                      ),
                    ),
                    SizedBox(height: 10.h),
                    DropdownSearch<BusinessType>(
                      popupProps: const PopupProps.menu(),
                      items: viewModel.businessTypeList,
                      // asyncItems: (String filter) => getData(filter),
                      itemAsString: (BusinessType u) => u.title.toString(),
                      dropdownDecoratorProps: DropDownDecoratorProps(
                        dropdownSearchDecoration: InputDecoration(
                          hintText: "Business Type",
                          contentPadding: EdgeInsets.symmetric(horizontal: 25, vertical: 18),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide(
                              color: Color(
                                0xFFDADADA,
                              ),
                            ), // Border color when enabled
                          ),
                          errorStyle: TextStyle(fontSize: 14.sp),
                          hintStyle: GoogleFonts.montserrat(
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                            color: Color(0xFF0B0B0B).withOpacity(0.5),
                          ),
                        ),
                      ),
                      onChanged: (BusinessType? data) => viewModel.updateDocumentationForm(
                        value: data!.id.toString(),
                        isGst: false,
                      ),
                      validator: (item) {
                        if (item == null) {
                          return "Business Type field is required";
                        } else {
                          return null;
                        }
                      },
                    ),
                    SizedBox(height: 80.h),
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
            isLoading: viewModel.businessResponse.status == Status.loading,
            onTap: () async {
              viewModel.setValidatingStatus(true);
              print((viewModel.formKey.currentState!.validate()));
              if (viewModel.formKey.currentState!.validate()) {
                if (viewModel.model.businessImage == null) {
                  return Utils.toastMessage("Please attach image");
                }
                await viewModel.registerBusiness();
              }
            },
          ),
        ),
      ),
    );
  }
}
