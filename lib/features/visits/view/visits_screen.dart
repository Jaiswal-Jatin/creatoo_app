import 'dart:ui';
import 'package:creatoo/core.dart' hide Day;
import 'package:intl/intl.dart';
import 'package:creatoo/features/visits/view_model/visits_view_model.dart';
import '../model/visits_response_model.dart';

import '../../../../data/services/shared_preference_service.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({Key? key}) : super(key: key);

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  final VisitsViewModel visitsViewModel = VisitsViewModel();
  final SharedPreferencesService _prefs = SharedPreferencesService();

  @override
  void initState() {
    super.initState();
    _fetchVisitsData();
  }

  Future<void> _fetchVisitsData() async {
    String? token = await _prefs.getToken();
    if (token != null) {
      await visitsViewModel.fetchBusinessVisitsApi(token);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<VisitsViewModel>.value(
      value: visitsViewModel,
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
                    color: AppColor.premiumAccent.withOpacity(0.05),
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Consumer<VisitsViewModel>(
                builder: (context, viewModel, _) {
                  switch (viewModel.visitsResponse.status) {
                    case Status.loading:
                      return const Center(child: AppLoadingWidget());
                    case Status.error:
                      return Center(child: AppTextWidget(text: 'Error: ${viewModel.visitsResponse.message}', color: Colors.white70));
                    case Status.completed:
                      return Column(
                        children: [
                          // Custom Header
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                            child: Row(
                              children: [
                                // CustomBackButton(onTap: () => Navigator.pop(context)),
                                // SizedBox(width: 16.w),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      AppTextWidget(
                                        text: "CREATOO",
                                        fontSize: 11.sp,
                                        color: AppColor.premiumAccent,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1.2,
                                      ),
                                      SizedBox(height: 2.h),
                                      AppTextWidget(
                                        text: "Visit History",
                                        fontSize: 22.sp,
                                        fontWeight: FontWeight.w800,
                                        color: AppColor.premiumTextPrimary,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Expanded(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(horizontal: 16.w),
                              physics: const BouncingScrollPhysics(),
                              child: Column(
                                children: [
                                  SizedBox(height: 10.h),
                                  // Tier Summary Cards
                                  IntrinsicHeight(
                                    child: Row(
                                      children: [
                                        _buildGlassTierCard('Premium', viewModel.goldCount.toString(), const Color(0xFFFFD700)),
                                        SizedBox(width: 12.w),
                                        _buildGlassTierCard('Elite', viewModel.silverCount.toString(), const Color(0xFFC0C0C0)),
                                        SizedBox(width: 12.w),
                                        _buildGlassTierCard('Core', viewModel.bronzeCount.toString(), const Color(0xFFCD7F32)),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: 32.h),

                                  if (viewModel.visitsByDate.isEmpty)
                                    Padding(
                                      padding: EdgeInsets.only(top: 100.h),
                                      child: AppTextWidget(
                                        text: 'No visit history available.',
                                        fontSize: 16.sp,
                                        color: Colors.white38,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  else
                                    ...viewModel.visitsByDate.entries.map((entry) {
                                      return Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 12.h, left: 4.w),
                                            child: AppTextWidget(
                                              text: entry.key,
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColor.premiumAccent.withOpacity(0.8),
                                            ),
                                          ),
                                          ...entry.value.map((visit) => _buildGlassVisitCard(visit)),
                                          SizedBox(height: 20.h),
                                        ],
                                      );
                                    }).toList(),
                                  
                                  SizedBox(height: 40.h),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    default:
                      return const Center(child: AppTextWidget(text: 'Unexpected state.', color: Colors.white70));
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassTierCard(String title, String count, Color accentColor) {
    return Expanded(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppTextWidget(
                  text: count,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
                SizedBox(height: 4.h),
                AppTextWidget(
                  text: title,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlassVisitCard(Visit visit) {
    final timeFormat = DateFormat('h:mm a');
    final Tier displayTier = visit.tier == Tier.newTier ? Tier.premium : visit.tier;
    
    Color tierColor;
    switch (displayTier) {
      case Tier.premium:
        tierColor = const Color(0xFFFFD700);
        break;
      case Tier.elite:
        tierColor = const Color(0xFFC0C0C0);
        break;
      case Tier.core:
      default:
        tierColor = const Color(0xFFCD7F32);
    }

    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.03),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withOpacity(0.08),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                // Indicator
                Container(
                  width: 4.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: tierColor.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: tierColor.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16.w),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppTextWidget(
                        text: visit.userName,
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                      SizedBox(height: 4.h),
                      AppTextWidget(
                        text: timeFormat.format(visit.dateTime),
                        fontSize: 12.sp,
                        color: Colors.white38,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
                // Tier Badge
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: tierColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: tierColor.withOpacity(0.2)),
                  ),
                  child: AppTextWidget(
                    text: displayTier.toString().split('.').last.toUpperCase(),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: tierColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Visit and Tier models live in `visits_response_model.dart` now.
