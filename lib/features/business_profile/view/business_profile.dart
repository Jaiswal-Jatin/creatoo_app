import 'dart:ui';
import 'package:creatoo/core.dart';
import 'package:creatoo/features/business_profile/model/business_profile_response.dart';
import '../view_model/business_profile_view_model.dart';

class BusinessProfileView extends StatefulWidget {
  const BusinessProfileView({super.key});

  @override
  State<BusinessProfileView> createState() => _BusinessProfileViewState();
}

class _BusinessProfileViewState extends State<BusinessProfileView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusinessProfileViewModel>(context, listen: false).init();
    });
  }

  @override
  Widget build(BuildContext context) {
    BusinessProfileViewModel viewModel = Provider.of<BusinessProfileViewModel>(context);

    switch (viewModel.profileResponse.status) {
      case Status.loading:
        return const AppLoadingWidget();
      case Status.error:
        return AppErrorWidget(message: viewModel.profileResponse.message.toString());
      case Status.completed:
        return _buildBody(viewModel.profileResponse.data!.data!, viewModel);
      default:
        return const AppNoDataWidget();
    }
  }

  Widget _buildBody(Data item, BusinessProfileViewModel viewModel) {
    final category = item.businessCategory?.toLowerCase() ?? '';

    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          Positioned(top: -150.h, left: -100.w, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(width: 400.w, height: 400.w, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.premiumAccent.withValues(alpha: 0.15))),
          )),
          Positioned(bottom: -100.h, right: -50.w, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(width: 350.w, height: 350.w, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withValues(alpha: 0.1))),
          )),
          Positioned(top: 0, left: 0, right: 0, child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  GestureDetector(onTap: () => Navigator.pop(context), child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16.sp),
                  )),
                  SizedBox(width: 16.w),
                  Text("Business Profile", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w700)),
                  const Spacer(),
                  GestureDetector(onTap: () => Navigator.pushNamed(context, RoutesName.editBusinessProfile), child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(color: AppColor.premiumAccent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColor.premiumAccent.withValues(alpha: 0.3))),
                    child: Icon(Icons.edit_rounded, color: AppColor.premiumAccent, size: 16.sp),
                  )),
                ],
              ),
            ),
          )),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 60.h),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildProfileHeader(item),
                    SizedBox(height: 24.h),
                    _buildInfoCard("Business Information", Icons.business_center_rounded, [
                      _detail("Business Name", item.businessName),
                      _detail("Category", _categoryLabel(category)),
                      _detail("Area", item.businessArea),
                      _detail("Address", item.businessAddress),
                      _detail("Website", item.businessSiteUrl),
                    ]),
                    SizedBox(height: 16.h),
                    _buildInfoCard("Contact Person", Icons.person_rounded, [
                      _detail("Name", item.businessFullname),
                      _detail("Designation", item.businessDesignation),
                      _detail("Email", item.businessEmail),
                      _detail("Mobile", item.businessMobile),
                    ]),
                    SizedBox(height: 16.h),
                    _buildInfoCard("Business Identity", Icons.badge_rounded, [
                      _detail("GSTIN", item.gstNumber),
                      _detail("UPI ID", item.upiId),
                    ]),
                    SizedBox(height: 16.h),
                    _buildInfoCard("Shop Details", Icons.store_rounded, [
                      _detail("Opening Time", item.timeFrom),
                      _detail("Closing Time", item.timeTo),
                      _detail("Pricing", item.pricingRangeText),
                    ]),
                    // if (category == 'restaurant') ...[
                    //   SizedBox(height: 16.h),
                    //   _buildRestaurantSection(item),
                    // ],
                    if (category == 'salon') ...[
                      SizedBox(height: 16.h),
                      _buildSalonSection(item),
                    ],
                    if (category == 'turf') ...[
                      SizedBox(height: 16.h),
                      _buildTurfSection(item),
                    ],
                    SizedBox(height: 16.h),
                    _buildDiscountSection(item),
                    SizedBox(height: 16.h),
                    AppButton(
                      onTap: () => Navigator.pushNamed(context, RoutesName.businessQrView, arguments: {'businessId': item.id ?? 0, 'businessName': item.businessName ?? 'Business'}),
                      text: "Business QR Code", isIconEnabled: true, icon: Icons.qr_code_rounded,
                    ),
                    SizedBox(height: 40.h),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(Data item) {
    final imageUrl = item.businessImage?.isNotEmpty == true
        ? 'https://creatoos3.blr1.digitaloceanspaces.com/images/${item.businessImage!.startsWith('/') ? item.businessImage!.substring(1) : item.businessImage}'
        : 'https://creatoos3.blr1.digitaloceanspaces.com/images/default_profile.png';

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white.withValues(alpha: 0.1))),
          child: Column(
            children: [
              Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColor.premiumAccent.withValues(alpha: 0.5), width: 2)),
                child: CircleAvatar(radius: 45.w, backgroundImage: NetworkImage(imageUrl), backgroundColor: Colors.white.withValues(alpha: 0.1))),
              SizedBox(height: 12.h),
              Text(item.businessName ?? '---', textAlign: TextAlign.center, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w800)),
              SizedBox(height: 4.h),
              Container(padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(color: AppColor.premiumAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColor.premiumAccent.withValues(alpha: 0.2))),
                child: Text(_categoryLabel(item.businessCategory?.toLowerCase() ?? ''), style: GoogleFonts.montserrat(color: AppColor.premiumAccent, fontSize: 11.sp, fontWeight: FontWeight.w600))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.04), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withValues(alpha: 0.08))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(padding: EdgeInsets.all(8), decoration: BoxDecoration(color: AppColor.premiumAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColor.premiumAccent, size: 16.sp)),
              SizedBox(width: 10.w),
              Text(title, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
            ]),
            SizedBox(height: 14.h),
            Divider(color: Colors.white.withValues(alpha: 0.06)),
            SizedBox(height: 6.h),
            ...children,
          ]),
        ),
      ),
    );
  }

  Widget _detail(String label, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6.h),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 100.w, child: Text(label, style: GoogleFonts.montserrat(color: AppColor.premiumTextSecondary, fontSize: 11.sp, fontWeight: FontWeight.w500))),
        Expanded(child: Text(value, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600))),
      ]),
    );
  }

  Widget _buildRestaurantSection(Data item) {
    final attrs = item.categoryAttributes;
    return _buildInfoCard("Restaurant Details", Icons.restaurant_rounded, [
      if (attrs?['seating_capacity'] != null) _detail("Seating Capacity", "${attrs!['seating_capacity']} Seats"),
      _detail("Type", attrs?['is_veg_only'] == true ? "Pure Vegetarian" : "Veg & Non-Veg"),
      if ((attrs?['cuisine_type'] as List?)?.isNotEmpty == true) _detail("Cuisines", (attrs!['cuisine_type'] as List).join(", ")),
      if (item.menuCard1 != null || item.menuCard2 != null || item.menuCard3 != null || item.menuCard4 != null || item.menuCard5 != null)
        _detail("Menu Cards", "Uploaded ✓"),
    ]);
  }

  Widget _buildSalonSection(Data item) {
    final attrs = item.categoryAttributes;
    return _buildInfoCard("Salon Details", Icons.content_cut_rounded, [
      _detail("Gender Support", _genderLabel(attrs?['gender_support']?.toString())),
      if ((attrs?['stylists'] as List?)?.isNotEmpty == true) _detail("Stylists", (attrs!['stylists'] as List).join(", ")),
    ]);
  }

  Widget _buildTurfSection(Data item) {
    final attrs = item.categoryAttributes;
    return _buildInfoCard("Turf Details", Icons.sports_soccer_rounded, [
      if (attrs?['turf_size'] != null) _detail("Court Size", attrs!['turf_size'].toString()),
      if (attrs?['ground_type'] != null) _detail("Ground Type", attrs!['ground_type'].toString()),
      if ((attrs?['sport_types'] as List?)?.isNotEmpty == true) _detail("Sports", (attrs!['sport_types'] as List).join(", ")),
      if ((attrs?['amenities'] as List?)?.isNotEmpty == true) _detail("Amenities", (attrs!['amenities'] as List).join(", ")),
    ]);
  }

  Widget _buildDiscountSection(Data item) {
    final firstTime = item.setFirstTimeDiscount;
    final regular = item.setRegularDiscount;
    if (firstTime == null && regular == null) return const SizedBox.shrink();
    return _buildInfoCard("Discounts", Icons.local_offer_rounded, [
      if (firstTime != null) _detail("First Time", "$firstTime% OFF"),
      if (regular != null) _detail("Regular", "$regular% OFF"),
    ]);
  }

  String _categoryLabel(String cat) {
    switch (cat) { case 'restaurant': return 'Restaurant'; case 'salon': return 'Salon / Spa'; case 'turf': return 'Turf / Sports'; default: return cat; }
  }

  String _genderLabel(String? g) {
    switch (g) { case 'men': return 'Men Only'; case 'women': return 'Women Only'; case 'unisex': return 'Unisex'; default: return g ?? '---'; }
  }
}
