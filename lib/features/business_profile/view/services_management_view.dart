import 'dart:io';
import 'dart:ui';
import 'package:image_picker/image_picker.dart';
import '../../../core.dart';
import '../view_model/edit_business_profile_view_model.dart';

class ServicesManagementView extends StatefulWidget {
  const ServicesManagementView({super.key});

  @override
  State<ServicesManagementView> createState() => _ServicesManagementViewState();
}

class _ServicesManagementViewState extends State<ServicesManagementView> {
  late EditBusinessProfileViewModel viewModel;

  @override
  void initState() {
    super.initState();
    viewModel = Provider.of<EditBusinessProfileViewModel>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (viewModel.profileResponse.status != Status.completed) {
        viewModel.init("My Profile");
      }
      if (viewModel.turfSportOptions.isEmpty && viewModel.turfAmenityOptions.isEmpty) {
        viewModel.fetchTurfOptions();
      }
    });
  }

  String get _category => viewModel.selectedBusinessCategory?.toLowerCase() ?? 'salon';
  String get _title {
    switch (_category) {
      case 'turf': return 'Manage Sports, Amenities & Offers';
      case 'restaurant': return 'Manage Offers';
      default: return 'Manage Services & Offers';
    }
  }

  void _pickExclusiveImage(String tier) async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final file = File(pickedFile.path);
      setState(() {
        if (tier == 'premium') {
          viewModel.premiumOffers.add(BusinessImage(file: file));
        } else if (tier == 'elite') {
          viewModel.eliteOffers.add(BusinessImage(file: file));
        } else if (tier == 'core') {
          viewModel.coreOffers.add(BusinessImage(file: file));
        }
      });
      viewModel.notify();
    }
  }

  Widget _buildOfferImageCard(BusinessImage img, int index, String tier) {
    return Container(
      width: 100.w,
      height: 100.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.premiumAccent.withValues(alpha: 0.2)),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: img.file != null
                ? Image.file(img.file!, fit: BoxFit.cover, height: double.infinity, width: double.infinity)
                : img.url != null
                    ? AppImageWidget(imageUrl: img.url!, fit: BoxFit.cover, height: double.infinity, width: double.infinity)
                    : const SizedBox.shrink(),
          ),
          Positioned(
            top: 4,
            right: 4,
            child: GestureDetector(
              onTap: () {
                setState(() {
                  if (tier == 'premium') {
                    viewModel.premiumOffers.removeAt(index);
                  } else if (tier == 'elite') {
                    viewModel.eliteOffers.removeAt(index);
                  } else if (tier == 'core') {
                    viewModel.coreOffers.removeAt(index);
                  }
                });
                viewModel.notify();
              },
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                child: Icon(Icons.close_rounded, color: Colors.white, size: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantOffersCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<BusinessImage> offers,
    required String tier,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColor.premiumAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: Icon(icon, color: AppColor.premiumAccent, size: 16.sp),
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                              Text(subtitle, style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white38), maxLines: 1, overflow: TextOverflow.ellipsis),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => _pickExclusiveImage(tier),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                      decoration: BoxDecoration(color: AppColor.premiumAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                      child: Text("+ Add Image", style: GoogleFonts.montserrat(color: AppColor.premiumAccent, fontSize: 11.sp, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              if (offers.isEmpty)
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.02),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.add_photo_alternate_outlined, color: Colors.white24, size: 36.sp),
                      SizedBox(height: 8.h),
                      Text("No $title added yet", style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white38, fontWeight: FontWeight.w500)),
                    ],
                  ),
                )
              else
                SizedBox(
                  height: 100.w,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: offers.length,
                    itemBuilder: (context, index) => _buildOfferImageCard(offers[index], index, tier),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    viewModel = Provider.of<EditBusinessProfileViewModel>(context);

    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          Positioned(top: -100.h, right: -50.w, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(width: 350.w, height: 350.w, decoration: BoxDecoration(shape: BoxShape.circle, color: AppColor.premiumAccent.withValues(alpha: 0.15))),
          )),
          Positioned(bottom: 50.h, left: -80.w, child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(width: 300.w, height: 300.w, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blueAccent.withValues(alpha: 0.1))),
          )),

          Positioned(top: 0, left: 0, right: 0, child: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Row(
                children: [
                  const CustomBackButton(),
                  SizedBox(width: 16.w),
                  Text(_title, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 20.sp, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          )),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.only(top: 60.h),
              child: viewModel.profileResponse.status == Status.loading || viewModel.isOffersLoading
                  ? const AppLoadingWidget()
                  : SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.all(20.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_category == 'salon') ...[
                            _buildServicesCard(),
                            SizedBox(height: 24.h),
                          ],
                          if (_category == 'turf') ...[
                            _buildTurfSportsSection(),
                            SizedBox(height: 20.h),
                            _buildTurfAmenitiesSection(),
                            SizedBox(height: 20.h),
                          ],
                          _buildRestaurantOffersCard(
                            icon: Icons.workspace_premium_rounded,
                            title: "Premium Offers",
                            subtitle: "Featured offers for premium tier members",
                            offers: viewModel.premiumOffers,
                            tier: 'premium',
                          ),
                          SizedBox(height: 20.h),
                          _buildRestaurantOffersCard(
                            icon: Icons.stars_rounded,
                            title: "Elite Offers",
                            subtitle: "Featured offers for elite tier members",
                            offers: viewModel.eliteOffers,
                            tier: 'elite',
                          ),
                          SizedBox(height: 20.h),
                          _buildRestaurantOffersCard(
                            icon: Icons.shield_rounded,
                            title: "Core Offers",
                            subtitle: "Featured offers for core tier members",
                            offers: viewModel.coreOffers,
                            tier: 'core',
                          ),
                          SizedBox(height: 24.h),
                          AppButton(
                            onTap: () async {
                              if (_category == 'restaurant') {
                                await viewModel.saveExclusiveOffers();
                              } else {
                                await viewModel.updateBusinessProfile();
                                if (viewModel.profileResponse.status == Status.completed) {
                                  await viewModel.saveExclusiveOffers();
                                }
                              }
                            },
                            text: _category == 'restaurant' ? "Save Offers" : "Save Services & Offers",
                            isIconEnabled: true,
                            icon: Icons.save_rounded,
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

  Widget _buildTurfSportsSection() {
    final options = viewModel.turfSportOptions;
    if (options.isEmpty) return const SizedBox.shrink();

    // Standard selected sports only
    final selectedSports = viewModel.services.where((s) {
      final name = s['name']?.toString() ?? '';
      return options.contains(name);
    }).toList();

    return _buildChipSection(
      icon: Icons.sports_soccer_rounded,
      title: "Sports",
      subtitle: "Select sports offered at your turf",
      options: options,
      selectedItems: selectedSports,
      defaultDuration: 60,
      defaultPrice: 0,
      showAddCustom: false,
    );
  }

  Widget _buildTurfAmenitiesSection() {
    final options = viewModel.turfAmenityOptions;
    if (options.isEmpty) return const SizedBox.shrink();

    // Standard selected amenities
    final selectedAmenities = viewModel.services.where((s) {
      final name = s['name']?.toString() ?? '';
      return options.contains(name);
    }).toList();

    return _buildChipSection(
      icon: Icons.checkroom_rounded,
      title: "Amenities",
      subtitle: "Select amenities available at your turf",
      options: options,
      selectedItems: selectedAmenities,
      defaultDuration: 0,
      defaultPrice: 0,
      showAddCustom: false,
    );
  }

  Widget _buildTurfItemCard(Map<String, dynamic> item, int mainIndex, String sectionTitle) {
    final price = item['price'] ?? 0;
    final duration = item['duration_minutes'] ?? 0;
    final description = item['description']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColor.premiumAccent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              sectionTitle == "Sports" ? Icons.sports_soccer_rounded : Icons.checkroom_rounded,
              color: AppColor.premiumAccent,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['name']?.toString() ?? '',
                  style: GoogleFonts.montserrat(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.w600),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (description.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  Text(
                    description,
                    style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 10.sp),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: 8.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                price > 0 ? "₹$price" : "Free",
                style: GoogleFonts.montserrat(
                  color: price > 0 ? AppColor.premiumAccent : Colors.greenAccent,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (duration > 0)
                Text(
                  "$duration min",
                  style: GoogleFonts.montserrat(color: Colors.white38, fontSize: 9.sp),
                ),
            ],
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _showServiceForm(index: mainIndex),
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.edit_rounded, color: Colors.white54, size: 14.sp),
            ),
          ),
          SizedBox(width: 6.w),
          GestureDetector(
            onTap: () {
              setState(() {
                viewModel.services.removeAt(mainIndex);
              });
              viewModel.notify();
            },
            child: Container(
              padding: EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_rounded, color: Colors.redAccent, size: 14.sp),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChipSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required List<String> options,
    required List<Map<String, dynamic>> selectedItems,
    required int defaultDuration,
    required int defaultPrice,
    required bool showAddCustom,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColor.premiumAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(icon, color: AppColor.premiumAccent, size: 16.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(subtitle, style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white38), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 10.h,
                children: options.map((opt) {
                  final selected = viewModel.services.any((s) => s['name'] == opt);
                  return GestureDetector(
                    onTap: () {
                      if (selected) {
                        viewModel.services.removeWhere((s) => s['name'] == opt);
                      } else {
                        viewModel.services.add({
                          'name': opt,
                          'price': defaultPrice,
                          'duration_minutes': defaultDuration,
                        });
                      }
                      viewModel.notify();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColor.premiumAccent.withValues(alpha: 0.15)
                            : Colors.white.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppColor.premiumAccent.withValues(alpha: 0.5)
                              : Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            selected ? Icons.check_circle_rounded : Icons.add_circle_outline_rounded,
                            size: 16.sp,
                            color: selected ? AppColor.premiumAccent : Colors.white38,
                          ),
                          SizedBox(width: 6.w),
                          Text(
                            opt,
                            style: GoogleFonts.montserrat(
                              fontSize: 12.sp,
                              color: selected ? AppColor.premiumAccent : Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              if (showAddCustom) ...[
                SizedBox(height: 16.h),
                GestureDetector(
                  onTap: () => _showServiceForm(),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColor.premiumAccent.withValues(alpha: 0.3)),
                      borderRadius: BorderRadius.circular(10),
                      color: AppColor.premiumAccent.withValues(alpha: 0.05),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_rounded, color: AppColor.premiumAccent, size: 16.sp),
                        SizedBox(width: 6.w),
                        Text("Add Custom Sport", style: GoogleFonts.montserrat(fontSize: 11.sp, color: AppColor.premiumAccent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ],
              if (selectedItems.isNotEmpty) ...[
                SizedBox(height: 20.h),
                Divider(color: Colors.white.withValues(alpha: 0.06)),
                SizedBox(height: 12.h),
                Text(
                  "Configure Pricing & Duration",
                  style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white70, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12.h),
                ...selectedItems.map((item) {
                  final mainIndex = viewModel.services.indexOf(item);
                  return _buildTurfItemCard(item, mainIndex, title);
                }).toList(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServicesCard() {
    final services = _filterCustomServices();
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColor.premiumAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(Icons.list_alt_rounded, color: AppColor.premiumAccent, size: 16.sp),
                  ),
                  SizedBox(width: 10.w),
                  Text("Services", style: GoogleFonts.montserrat(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w700)),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                "Manage your service catalog with pricing and add-ons",
                style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white38),
              ),
              SizedBox(height: 16.h),
              Divider(color: Colors.white.withValues(alpha: 0.06)),
              SizedBox(height: 12.h),

              if (services.isEmpty)
                _buildEmptyState("No services added yet")
              else
                ...services.asMap().entries.map((entry) {
                  final mainIndex = viewModel.services.indexOf(entry.value);
                  return _buildServiceCard(entry.value, mainIndex);
                }),

              SizedBox(height: 16.h),
              GestureDetector(
                onTap: () => _showServiceForm(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColor.premiumAccent.withValues(alpha: 0.3)),
                    borderRadius: BorderRadius.circular(16),
                    color: AppColor.premiumAccent.withValues(alpha: 0.05),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_rounded, color: AppColor.premiumAccent, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text("Add New Service", style: GoogleFonts.montserrat(fontSize: 13.sp, color: AppColor.premiumAccent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterCustomServices() {
    return viewModel.services.where((s) {
      final name = s['name']?.toString() ?? '';
      return !_isTurfDbOption(name);
    }).toList();
  }

  bool _isTurfDbOption(String name) {
    return viewModel.turfSportOptions.contains(name) || viewModel.turfAmenityOptions.contains(name);
  }

  Widget _buildEmptyState(String message) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        children: [
          Icon(Icons.construction_rounded, color: Colors.white24, size: 48.sp),
          SizedBox(height: 12.h),
          Text(message, style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white38, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> svc, int index) {
    final addOns = svc['add_ons'] as List<dynamic>? ?? [];
    final description = svc['description']?.toString() ?? '';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(color: AppColor.premiumAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.build_rounded, color: AppColor.premiumAccent, size: 20.sp),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(svc['name']?.toString() ?? 'Service', style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white, fontWeight: FontWeight.w700)),
                    if (description.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(description, style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white54), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("₹${svc['price']}", style: GoogleFonts.montserrat(fontSize: 16.sp, color: AppColor.premiumAccent, fontWeight: FontWeight.w800)),
                  Text("${svc['duration_minutes']} min", style: GoogleFonts.montserrat(fontSize: 10.sp, color: Colors.white38)),
                ],
              ),
            ],
          ),
          if (addOns.isNotEmpty) ...[
            SizedBox(height: 12.h),
            Divider(color: Colors.white.withValues(alpha: 0.06)),
            SizedBox(height: 8.h),
            Text("Add-ons", style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white38, fontWeight: FontWeight.w600)),
            SizedBox(height: 6.h),
            ...addOns.map((addOn) => Padding(
              padding: EdgeInsets.only(bottom: 4.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(addOn['name']?.toString() ?? '', style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white70)),
                  Text("₹${addOn['price']}", style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white54)),
                ],
              ),
            )),
          ],
          SizedBox(height: 12.h),
          Divider(color: Colors.white.withValues(alpha: 0.06)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _showServiceForm(index: index),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, color: Colors.white54, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text("Edit", style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white54, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () { viewModel.services.removeAt(index); viewModel.notify(); },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.redAccent, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text("Remove", style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.redAccent, fontWeight: FontWeight.w500)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showServiceForm({int? index}) {
    final isEdit = index != null;
    final existing = isEdit ? viewModel.services[index] : null;
    final addOns = existing?['add_ons'] != null
        ? List<Map<String, dynamic>>.from(existing!['add_ons'] as List)
        : <Map<String, dynamic>>[];

    final nameCtl = TextEditingController(text: existing?['name']?.toString() ?? '');
    final descCtl = TextEditingController(text: existing?['description']?.toString() ?? '');
    final priceCtl = TextEditingController(text: existing?['price']?.toString() ?? '');
    final durCtl = TextEditingController(text: existing?['duration_minutes']?.toString() ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2)))),
                    SizedBox(height: 20.h),
                    Text(isEdit ? "Edit Service" : "Add New Service", style: GoogleFonts.montserrat(fontSize: 18.sp, fontWeight: FontWeight.w700, color: Colors.white)),
                    SizedBox(height: 20.h),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildField(label: "Service Name", controller: nameCtl, hint: "e.g. Haircut, Facial, Turf Booking"),
                            SizedBox(height: 16.h),
                            _buildField(label: "Description", controller: descCtl, hint: "Brief description", maxLines: 3),
                            SizedBox(height: 16.h),
                            Row(
                              children: [
                                Expanded(child: _buildField(label: "Price (₹)", controller: priceCtl, hint: "e.g. 500", keyboardType: TextInputType.number)),
                                SizedBox(width: 12.w),
                                Expanded(child: _buildField(label: "Duration (min)", controller: durCtl, hint: "e.g. 60", keyboardType: TextInputType.number)),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            Divider(color: Colors.white.withValues(alpha: 0.08)),
                            SizedBox(height: 12.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text("Add-ons", style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white70)),
                                GestureDetector(
                                  onTap: () => setState(() => addOns.add({'name': '', 'price': 0})),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                    decoration: BoxDecoration(color: AppColor.premiumAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(Icons.add_rounded, color: AppColor.premiumAccent, size: 14.sp),
                                        SizedBox(width: 4.w),
                                        Text("Add Add-on", style: GoogleFonts.montserrat(fontSize: 11.sp, color: AppColor.premiumAccent, fontWeight: FontWeight.w600)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            if (addOns.isEmpty)
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: Center(child: Text("No add-ons yet", style: GoogleFonts.montserrat(fontSize: 12.sp, color: Colors.white24))),
                              )
                            else
                              ...addOns.asMap().entries.map((entry) {
                                final aIndex = entry.key;
                                final addOn = entry.value;
                                final aNameCtl = TextEditingController(text: addOn['name']?.toString() ?? '');
                                final aPriceCtl = TextEditingController(text: addOn['price']?.toString() ?? '');
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 10.h),
                                  child: Row(
                                    children: [
                                      Expanded(flex: 3, child: TextField(
                                        controller: aNameCtl,
                                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                        decoration: InputDecoration(
                                          hintText: "Name", hintStyle: TextStyle(color: Colors.white24, fontSize: 13.sp),
                                          filled: true, fillColor: Colors.white.withValues(alpha: 0.03),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColor.premiumAccent)),
                                        ),
                                        onChanged: (v) => addOn['name'] = v.trim(),
                                      )),
                                      SizedBox(width: 8.w),
                                      Expanded(flex: 2, child: TextField(
                                        controller: aPriceCtl,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                        decoration: InputDecoration(
                                          hintText: "Price", hintStyle: TextStyle(color: Colors.white24, fontSize: 13.sp),
                                          filled: true, fillColor: Colors.white.withValues(alpha: 0.03),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                                          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColor.premiumAccent)),
                                        ),
                                        onChanged: (v) => addOn['price'] = double.tryParse(v) ?? 0,
                                      )),
                                      SizedBox(width: 4.w),
                                      GestureDetector(
                                        onTap: () => setState(() => addOns.removeAt(aIndex)),
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                          child: Icon(Icons.close_rounded, color: Colors.redAccent, size: 16.sp),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => Navigator.pop(ctx),
                            child: Text("Cancel", style: GoogleFonts.montserrat(color: Colors.white54, fontWeight: FontWeight.w600, fontSize: 14.sp)),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.premiumAccent,
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () {
                              if (nameCtl.text.trim().isEmpty || priceCtl.text.trim().isEmpty) {
                                Utils.toastMessage("Service name and price are required");
                                return;
                              }
                              final svc = {
                                'name': nameCtl.text.trim(),
                                'description': descCtl.text.trim(),
                                'price': double.tryParse(priceCtl.text) ?? 0,
                                'duration_minutes': int.tryParse(durCtl.text) ?? 60,
                                'add_ons': addOns.where((a) => a['name'].toString().isNotEmpty).toList(),
                              };
                              if (isEdit) {
                                viewModel.services[index] = svc;
                              } else {
                                viewModel.services.add(svc);
                              }
                              viewModel.notify();
                              Navigator.pop(ctx);
                            },
                            child: Text(isEdit ? "Save Changes" : "Add Service", style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14.sp)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.h),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildField({required String label, required TextEditingController controller, String? hint, int? maxLines, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
          child: Text(label, style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w500, color: AppColor.premiumTextSecondary)),
        ),
        TextField(
          controller: controller,
          maxLines: maxLines ?? 1,
          keyboardType: keyboardType,
          style: GoogleFonts.montserrat(color: Colors.white, fontSize: 14.sp),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.montserrat(color: Colors.white24, fontSize: 14.sp),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.03),
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: AppColor.premiumAccent, width: 1.5)),
          ),
        ),
      ],
    );
  }
}
