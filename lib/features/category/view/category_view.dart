import 'dart:ui';
import 'package:creatoo/widgets/app_text_widget.dart';
import '../../../core.dart';
import '../../home/view_model/home_view_model.dart';
import '../../search/view_model/search_view_model.dart';
import '../view_model/category_view_model.dart';

class CategoryView extends StatefulWidget {
  const CategoryView({super.key});

  @override
  State<CategoryView> createState() => _CategoryViewState();
}

class _CategoryViewState extends State<CategoryView>
    with SingleTickerProviderStateMixin {
  late CategoryViewModel viewModel;
  late AnimationController _animationController;

  final List<Map<String, dynamic>> categories = [
    {
      'key': 'restaurant',
      'name': 'Restaurants',
      'icon': Icons.restaurant_menu_rounded,
      'color': const Color(0xFFFF5722),
      'gradient': [const Color(0xFFFF5722), const Color(0xFFFF8A65)],
      'description': 'Discover the best dining experiences',
      'emoji': '🍽️',
    },
    {
      'key': 'salon',
      'name': 'Salons',
      'icon': Icons.content_cut_rounded,
      'color': const Color(0xFFE91E63),
      'gradient': [const Color(0xFFE91E63), const Color(0xFFF48FB1)],
      'description': 'Book your beauty & grooming services',
      'emoji': '💇',
    },
    {
      'key': 'turf',
      'name': 'Turf & Sports',
      'icon': Icons.sports_soccer_rounded,
      'color': const Color(0xFF4CAF50),
      'gradient': [const Color(0xFF4CAF50), const Color(0xFF81C784)],
      'description': 'Book sports grounds & turf arenas',
      'emoji': '⚽',
    },
  ];

  @override
  void initState() {
    viewModel = Provider.of<CategoryViewModel>(context, listen: false);
    viewModel.init();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animationController.forward();
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: Stack(
        children: [
          // Background glow effects
          Positioned(
            top: -120.h,
            right: -80.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
              child: Container(
                width: 350.w,
                height: 350.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColor.premiumAccent.withOpacity(0.12),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -100.h,
            left: -60.w,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
              child: Container(
                width: 300.w,
                height: 300.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blueAccent.withOpacity(0.08),
                ),
              ),
            ),
          ),

          // Content
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                // Header
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
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
                      SizedBox(height: 4.h),
                      AppTextWidget(
                        text: "Categories",
                        fontSize: 26.sp,
                        fontWeight: FontWeight.w800,
                        color: AppColor.premiumTextPrimary,
                      ),
                      SizedBox(height: 6.h),
                      AppTextWidget(
                        text: "Choose a category to explore",
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColor.premiumTextSecondary,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 32.h),

                // Category Cards
                Expanded(
                  child: ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final cat = categories[index];
                      final delay = index * 0.15;
                      return SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.3),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _animationController,
                          curve: Interval(delay, 0.6 + delay, curve: Curves.easeOutCubic),
                        )),
                        child: FadeTransition(
                          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _animationController,
                              curve: Interval(delay, 0.5 + delay, curve: Curves.easeOut),
                            ),
                          ),
                          child: _buildCategoryCard(cat),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(Map<String, dynamic> cat) {
    final gradientColors = cat['gradient'] as List<Color>;
    final color = cat['color'] as Color;

    return GestureDetector(
      onTap: () {
        // Set category filter on search ViewModel and switch to search tab
        final searchVM = Provider.of<SearchViewModel>(context, listen: false);
        searchVM.setCategoryFilter(cat['key'] as String);
        // Switch to search tab (index 1 for creators)
        final homeVM = Provider.of<HomeViewModel>(context, listen: false);
        homeVM.changeIndex(1, false);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 18.h),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              padding: EdgeInsets.all(22.w),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                color: Colors.white.withOpacity(0.04),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Icon container with gradient
                  Container(
                    width: 64.w,
                    height: 64.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        cat['icon'] as IconData,
                        color: Colors.white,
                        size: 28.sp,
                      ),
                    ),
                  ),

                  SizedBox(width: 18.w),

                  // Text content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              cat['emoji'] as String,
                              style: TextStyle(fontSize: 16.sp),
                            ),
                            SizedBox(width: 8.w),
                            AppTextWidget(
                              text: cat['name'] as String,
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        AppTextWidget(
                          text: cat['description'] as String,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColor.premiumTextSecondary,
                        ),
                      ],
                    ),
                  ),

                  // Arrow
                  Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.1),
                    ),
                    child: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: color,
                      size: 16.sp,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
