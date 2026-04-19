import 'package:creatoo/utils/enums/status.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'dart:developer';
import 'package:creatoo/features/visits/view_model/visits_view_model.dart';
import 'package:provider/provider.dart'; // Import provider
import '../model/visits_response_model.dart';

import '../../../../data/services/shared_preference_service.dart';
import '../../../../resources/color.dart';
import '../../../../utils/ui_config/app_text_style.dart';

class VisitsScreen extends StatefulWidget {
  const VisitsScreen({Key? key}) : super(key: key);

  @override
  State<VisitsScreen> createState() => _VisitsScreenState();
}

class _VisitsScreenState extends State<VisitsScreen> {
  final VisitsViewModel visitsViewModel = VisitsViewModel();
  final SharedPreferencesService _prefs = SharedPreferencesService();

  List<Visit> visits = [];
  final Map<String, List<Visit>> visitsByDate = {};
  int goldCount = 0;
  int silverCount = 0;
  int bronzeCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchVisitsData();
  }

  Future<void> _fetchVisitsData() async {
    log("VisitsScreen: Attempting to fetch business visits data.");
    String? token = await _prefs.getToken();
    if (token != null) {
      log("VisitsScreen: Token retrieved successfully. Making API call.");
      await visitsViewModel.fetchBusinessVisitsApi(token);
    } else {
      log("VisitsScreen: No token found. Cannot make API call.");
      // Optionally, handle the case where no token is found (e.g., navigate to login)
    }
  }

  void _updateVisitsData(List<Day> daysList) {
    // Flatten visits from days into a single list
    visits = daysList.expand((d) => d.visits).toList();
    _groupVisitsByDate(visits);
    _countUsersByTier(visits);
  }

  void _groupVisitsByDate(List<Visit> visitsList) {
    visitsByDate.clear();
    for (var visit in visitsList) {
      final dateKey = DateFormat('EEEE, MMMM d, y').format(visit.dateTime);
      if (!visitsByDate.containsKey(dateKey)) {
        visitsByDate[dateKey] = [];
      }
      visitsByDate[dateKey]!.add(visit);
    }
  }

  void _countUsersByTier(List<Visit> visitsList) {
    // Map API tiers to display tiers: gold/new -> premium, silver -> elite, bronze -> core
    goldCount = visitsList
        .where((v) => v.tier == Tier.premium || v.tier == Tier.newTier)
        .length;
    silverCount = visitsList.where((v) => v.tier == Tier.elite).length;
    // core only
    bronzeCount = visitsList.where((v) => v.tier == Tier.core).length;
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    // Responsive breakpoints
    final isVerySmall = h < 600;
    final isSmall = h < 700 && !isVerySmall;
    final isMedium = h >= 700 && h < 850;

    // Responsive values
    double screenPadding;
    double tierCardPadding;
    double tierCountFontSize;
    double tierTitleFontSize;
    double cardSpacing;
    double sectionSpacing;
    double dateFontSize;

    if (isVerySmall) {
      screenPadding = 12;
      tierCardPadding = 10;
      tierCountFontSize = 22;
      tierTitleFontSize = 9;
      cardSpacing = 8;
      sectionSpacing = 16;
      dateFontSize = 13;
    } else if (isSmall) {
      screenPadding = 14;
      tierCardPadding = 12;
      tierCountFontSize = 24;
      tierTitleFontSize = 10;
      cardSpacing = 10;
      sectionSpacing = 18;
      dateFontSize = 14;
    } else if (isMedium) {
      screenPadding = 15;
      tierCardPadding = 14;
      tierCountFontSize = 26;
      tierTitleFontSize = 11;
      cardSpacing = 11;
      sectionSpacing = 20;
      dateFontSize = 15;
    } else {
      screenPadding = 16;
      tierCardPadding = 16;
      tierCountFontSize = 28;
      tierTitleFontSize = 12;
      cardSpacing = 12;
      sectionSpacing = 24;
      dateFontSize = 16;
    }

    return ChangeNotifierProvider<VisitsViewModel>.value(
      value: visitsViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Visits'),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
        body: Consumer<VisitsViewModel>(
          builder: (context, viewModel, _) {
            switch (viewModel.visitsResponse.status) {
              case Status.loading:
                log("VisitsScreen: Loading state");
                return const Center(child: CircularProgressIndicator());
              case Status.error:
                log("VisitsScreen: Error state - ${viewModel.visitsResponse.message}");
                return Center(
                    child: Text('Error: ${viewModel.visitsResponse.message}'));
              case Status.completed:
                log("VisitsScreen: Completed state");
                _updateVisitsData(viewModel.visitsResponse.data?.days ?? []);

                if (visitsByDate.isEmpty) {
                  return Center(
                    child: Text(
                      viewModel.visitsResponse.message ??
                          'No visits history available.',
                      style: AppTextStyles.montserratStyle(
                        fontSize: dateFontSize,
                        fontWeight: FontWeight.w500,
                        color: AppColor.darkGrey,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: EdgeInsets.all(screenPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Tier Summary Cards - All same size due to IntrinsicHeight
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildTierCard(
                              context,
                              'Premium',
                              goldCount.toString(),
                              'assets/icons/gold_medal.svg',
                              const Color(0xFFFFD700),
                              tierCardPadding,
                              tierCountFontSize,
                              tierTitleFontSize,
                            ),
                            SizedBox(width: cardSpacing),
                            _buildTierCard(
                              context,
                              'Elite',
                              silverCount.toString(),
                              'assets/icons/silver_medal.svg',
                              const Color(0xFFC0C0C0),
                              tierCardPadding,
                              tierCountFontSize,
                              tierTitleFontSize,
                            ),
                            SizedBox(width: cardSpacing),
                            _buildTierCard(
                              context,
                              'Core',
                              bronzeCount.toString(),
                              'assets/icons/bronze_medal.svg',
                              const Color(0xFFCD7F32),
                              tierCardPadding,
                              tierCountFontSize,
                              tierTitleFontSize,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: sectionSpacing),
                      // Visits List
                      ...visitsByDate.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: screenPadding * 0.5),
                              child: Text(
                                entry.key,
                                style: AppTextStyles.montserratStyle(
                                  fontSize: dateFontSize,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.darkGrey,
                                ),
                              ),
                            ),
                            ...entry.value.map(
                                (visit) => _buildVisitCard(visit, context)),
                            SizedBox(height: screenPadding),
                          ],
                        );
                      }).toList(),
                    ],
                  ),
                );
              default:
                log("VisitsScreen: Default state (should not happen after initial load)");
                return const Center(child: Text('Unexpected state.'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildTierCard(
    BuildContext context,
    String title,
    String count,
    String iconPath,
    Color color,
    double padding,
    double countFontSize,
    double titleFontSize,
  ) {
    // Determine gradient based on color
    List<Color> gradientColors = [];
    if (color == const Color(0xFFFFD700)) {
      gradientColors = [const Color(0xFFFFF3B0), const Color(0xFFFEDB5F)];
    } else if (color == const Color(0xFFC0C0C0)) {
      gradientColors = [const Color(0xFFF0F0F0), const Color(0xFFC0C0C0)];
    } else {
      gradientColors = [const Color(0xFFF0D9B5), const Color(0xFFCD7F32)];
    }

    return Expanded(
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: padding * 0.5),
            Text(
              count,
              style: GoogleFonts.montserrat(
                fontSize: countFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: padding * 0.25),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.montserrat(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitCard(Visit visit, BuildContext context) {
    final h = MediaQuery.of(context).size.height;

    // Responsive breakpoints
    final isVerySmall = h < 600;
    final isSmall = h < 700 && !isVerySmall;
    final isMedium = h >= 700 && h < 850;

    // Responsive values
    double cardPadding;
    double cardMargin;
    double borderRadius;
    double indicatorHeight;
    double nameFontSize;
    double timeFontSize;
    double tierPaddingH;
    double tierPaddingV;
    double tierFontSize;

    if (isVerySmall) {
      cardPadding = 10;
      cardMargin = 8;
      borderRadius = 10;
      indicatorHeight = 36;
      nameFontSize = 13;
      timeFontSize = 10;
      tierPaddingH = 8;
      tierPaddingV = 4;
      tierFontSize = 9;
    } else if (isSmall) {
      cardPadding = 12;
      cardMargin = 10;
      borderRadius = 11;
      indicatorHeight = 40;
      nameFontSize = 14;
      timeFontSize = 11;
      tierPaddingH = 10;
      tierPaddingV = 5;
      tierFontSize = 10;
    } else if (isMedium) {
      cardPadding = 14;
      cardMargin = 11;
      borderRadius = 11;
      indicatorHeight = 45;
      nameFontSize = 15;
      timeFontSize = 11;
      tierPaddingH = 11;
      tierPaddingV = 5;
      tierFontSize = 11;
    } else {
      cardPadding = 16;
      cardMargin = 12;
      borderRadius = 12;
      indicatorHeight = 50;
      nameFontSize = 16;
      timeFontSize = 12;
      tierPaddingH = 12;
      tierPaddingV = 6;
      tierFontSize = 12;
    }

    final timeFormat = DateFormat('h:mm a');

    // Treat 'newTier' as 'premium' for display purposes
    final Tier displayTier =
        visit.tier == Tier.newTier ? Tier.premium : visit.tier;
    List<Color> tierGradient;
    switch (displayTier) {
      case Tier.premium:
        tierGradient = [const Color(0xFFFFF3B0), const Color(0xFFFEDB5F)];
        break;
      case Tier.elite:
        tierGradient = [const Color(0xFFF0F0F0), const Color(0xFFC0C0C0)];
        break;
      case Tier.core:
      default:
        tierGradient = [const Color(0xFFF0D9B5), const Color(0xFFCD7F32)];
    }

    return Card(
      margin: EdgeInsets.only(bottom: cardMargin),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        child: Padding(
          padding: EdgeInsets.all(cardPadding),
          child: Row(
            children: [
              // Tier indicator with gradient
              Container(
                width: 4,
                height: indicatorHeight,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: tierGradient,
                  ),
                ),
              ),
              SizedBox(width: cardPadding),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.userName,
                      style: GoogleFonts.montserrat(
                        fontSize: nameFontSize,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: cardPadding * 0.25),
                    Text(
                      timeFormat.format(visit.dateTime),
                      style: GoogleFonts.montserrat(
                        fontSize: timeFontSize,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Tier badge
              Container(
                padding: EdgeInsets.symmetric(
                    horizontal: tierPaddingH, vertical: tierPaddingV),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: tierGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(borderRadius + 4),
                ),
                child: Text(
                  displayTier.toString().split('.').last.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: tierFontSize,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Visit and Tier models live in `visits_response_model.dart` now.
