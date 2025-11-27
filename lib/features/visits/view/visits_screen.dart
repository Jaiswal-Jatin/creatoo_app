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
    goldCount = visitsList.where((v) => v.tier == Tier.premium || v.tier == Tier.newTier).length;
    silverCount = visitsList.where((v) => v.tier == Tier.elite).length;
    // core only
    bronzeCount = visitsList.where((v) => v.tier == Tier.core).length;
  }

  @override
  Widget build(BuildContext context) {
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
                return Center(child: Text('Error: ${viewModel.visitsResponse.message}'));
              case Status.completed:
                log("VisitsScreen: Completed state");
                _updateVisitsData(viewModel.visitsResponse.data?.days ?? []);

                if (visitsByDate.isEmpty) {
                  return Center(
                    child: Text(
                      viewModel.visitsResponse.message ?? 'No visits history available.',
                      style: AppTextStyles.montserratStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColor.darkGrey,
                      ),
                    ),
                  );
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Tier Summary Cards
                      Row(
                        children: [
                          _buildTierCard(
                            context,
                            'Premium Users',
                            goldCount.toString(),
                            'assets/icons/gold_medal.svg',
                            const Color(0xFFFFD700),
                          ),
                          const SizedBox(width: 12),
                          _buildTierCard(
                            context,
                            'Elite Users',
                            silverCount.toString(),
                            'assets/icons/silver_medal.svg',
                            const Color(0xFFC0C0C0),
                          ),
                          const SizedBox(width: 12),
                          _buildTierCard(
                            context,
                            'Core Users',
                            bronzeCount.toString(),
                            'assets/icons/bronze_medal.svg',
                            const Color(0xFFCD7F32),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      // Visits List
                      ...visitsByDate.entries.map((entry) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                entry.key,
                                style: AppTextStyles.montserratStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColor.darkGrey,
                                ),
                              ),
                            ),
                            ...entry.value.map((visit) => _buildVisitCard(visit)),
                            const SizedBox(height: 16),
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
        padding: const EdgeInsets.all(16),
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
            // SvgPicture.asset(
            //   iconPath,
            //   height: 28,
            //   width: 28,
            //   color: Colors.black87,
            // ),
            const SizedBox(height: 8),
            Text(
              count,
              style: GoogleFonts.montserrat(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.montserrat(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisitCard(Visit visit) {
    final timeFormat = DateFormat('h:mm a');
    
    // Treat 'newTier' as 'premium' for display purposes
    final Tier displayTier = visit.tier == Tier.newTier ? Tier.premium : visit.tier;
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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // color: AppColor.moreLighterDd,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Tier indicator with gradient
              Container(
                width: 4,
                height: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: tierGradient,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // User info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      visit.userName,
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeFormat.format(visit.dateTime),
                      style: GoogleFonts.montserrat(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Tier badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: tierGradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  displayTier.toString().split('.').last.toUpperCase(),
                  style: GoogleFonts.montserrat(
                    fontSize: 12,
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

  Color _getTierColor(Tier tier) {
    switch (tier) {
      case Tier.premium:
        return const Color(0xFFFFD700); // Premium (gold)
      case Tier.elite:
        return const Color(0xFFC0C0C0); // Elite (silver)
      case Tier.core:
        return const Color(0xFFCD7F32); // Core (bronze)
      case Tier.newTier:
        return const Color(0xFFFFD700); // Treat newTier as premium for display
    }
  }
}

// Visit and Tier models live in `visits_response_model.dart` now.
