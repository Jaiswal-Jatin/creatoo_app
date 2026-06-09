import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import '../view_model/booking_view_model.dart';

/// Dynamic booking request screen — adapts based on business category.
/// Categories: restaurant, salon, turf
class BookingRequestScreen extends StatefulWidget {
  final int businessId;
  final String businessName;
  final String? businessImage;
  final String businessCategory;
  final String? prefilledService;
  final String? prefilledSport;
  final List<dynamic>? bookingServices;

  const BookingRequestScreen({
    super.key,
    required this.businessId,
    required this.businessName,
    this.businessImage,
    required this.businessCategory,
    this.prefilledService,
    this.prefilledSport,
    this.bookingServices,
  });

  @override
  State<BookingRequestScreen> createState() => _BookingRequestScreenState();
}

class _BookingRequestScreenState extends State<BookingRequestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  int _guestsCount = 2;
  String? _selectedService;
  String? _selectedSport;

  List<Map<String, dynamic>> _dynamicServices = [];

  @override
  void initState() {
    super.initState();
    if (widget.bookingServices != null) {
      _dynamicServices = widget.bookingServices!.map((s) => Map<String, dynamic>.from(s)).toList();
    }

    if (widget.prefilledService != null && widget.prefilledService!.isNotEmpty) {
      _selectedService = widget.prefilledService;
      if (_dynamicServices.isEmpty && !_salonServices.contains(widget.prefilledService)) {
        _salonServices.insert(0, widget.prefilledService!);
      }
    }
    if (widget.prefilledSport != null && widget.prefilledSport!.isNotEmpty) {
      _selectedSport = widget.prefilledSport;
      if (_dynamicServices.isEmpty && !_turfSports.contains(widget.prefilledSport)) {
        _turfSports.insert(0, widget.prefilledSport!);
      }
    }
  }

  // ─── Predefined Options ───
  final List<String> _salonServices = [
    'Haircut & Styling',
    'Hair Color',
    'Facial',
    'Manicure',
    'Pedicure',
    'Full Body Massage',
    'Waxing',
    'Bridal Package',
    'Other',
  ];

  final List<String> _turfSports = [
    'Football',
    'Cricket',
    'Basketball',
    'Badminton',
    'Tennis',
    'Volleyball',
    'Hockey',
    'Other',
  ];

  String get _categoryEmoji {
    switch (widget.businessCategory) {
      case 'salon':
        return '💇';
      case 'turf':
        return '⚽';
      default:
        return '🍽️';
    }
  }

  String get _categoryLabel {
    switch (widget.businessCategory) {
      case 'salon':
        return 'Salon & Spa';
      case 'turf':
        return 'Turf';
      default:
        return 'Restaurant';
    }
  }

  Color get _categoryColor {
    return AppColor.premiumAccent;
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 90)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: _categoryColor,
            surface: AppColor.premiumCardBg,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: ColorScheme.dark(
            primary: _categoryColor,
            surface: AppColor.premiumCardBg,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  String _formatDate(DateTime dt) {
    final months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${dt.day} ${months[dt.month]}, ${dt.year}';
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    final ampm = t.hour >= 12 ? 'PM' : 'AM';
    return '${h.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')} $ampm';
  }

  String _dateToString(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }

  String _timeToString(TimeOfDay t) {
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select date and time', style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    if (widget.businessCategory == 'salon' && _selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a service', style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }
    if (widget.businessCategory == 'turf' && _selectedSport == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a sport', style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red.shade700,
        ),
      );
      return;
    }

    final vm = context.read<BookingViewModel>();
    final success = await vm.submitBookingRequest(
      businessId: widget.businessId,
      bookingDate: _dateToString(_selectedDate!),
      bookingTime: _timeToString(_selectedTime!),
      guestsCount: (widget.businessCategory == 'restaurant' || widget.businessCategory == 'turf') ? _guestsCount : null,
      serviceName: widget.businessCategory == 'salon' ? _selectedService : null,
      sportName: widget.businessCategory == 'turf' ? _selectedSport : null,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (!mounted) return;
    if (success) {
      _showSuccessSheet();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(vm.error ?? 'Failed to send request', style: GoogleFonts.montserrat()),
          backgroundColor: Colors.red.shade700,
        ),
      );
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: false,
      builder: (_) => Container(
        padding: EdgeInsets.all(32.w),
        decoration: BoxDecoration(
          color: AppColor.premiumCardBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _categoryColor.withOpacity(0.15),
                border: Border.all(color: _categoryColor.withOpacity(0.4), width: 2),
              ),
              child: Icon(Icons.check_rounded, color: _categoryColor, size: 36.sp),
            ),
            SizedBox(height: 20.h),
            Text(
              'Request Sent! 🎉',
              style: GoogleFonts.montserrat(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white),
            ),
            SizedBox(height: 10.h),
            Text(
              'Your booking request has been sent to ${widget.businessName}. You\'ll be notified once they respond.',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.white54, height: 1.5),
            ),
            SizedBox(height: 28.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _categoryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () {
                  Navigator.pop(context); // close sheet
                  Navigator.pop(context); // close booking screen
                },
                child: Text('Done', style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      useGradient: true,
      backgroundColor: AppColor.premiumBg,
      isSafe: false,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBusinessCard(),
                    SizedBox(height: 24.h),
                    _buildSectionTitle('Select Date & Time'),
                    SizedBox(height: 12.h),
                    _buildDateTimePicker(),
                    SizedBox(height: 24.h),
                    _buildCategorySection(),
                    SizedBox(height: 24.h),
                    _buildNotesField(),
                    SizedBox(height: 32.h),
                    _buildSubmitButton(),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 5.h),
      child: Row(
        children: [
          CustomBackButton(onTap: () => Navigator.pop(context)),
          SizedBox(width: 14.w),
          Text(
            'Request Booking',
            style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: _categoryColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _categoryColor.withOpacity(0.3)),
            ),
            child: Text(
              '$_categoryEmoji $_categoryLabel',
              style: GoogleFonts.montserrat(fontSize: 11.sp, fontWeight: FontWeight.w600, color: _categoryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessCard() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_categoryColor.withOpacity(0.15), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _categoryColor.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          if (widget.businessImage != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                widget.businessImage!,
                width: 52.w,
                height: 52.w,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _businessPlaceholder(),
              ),
            )
          else
            _businessPlaceholder(),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.businessName,
                  style: GoogleFonts.montserrat(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Sending booking request to this business',
                  style: GoogleFonts.montserrat(fontSize: 11.sp, color: Colors.white38),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _businessPlaceholder() {
    return Container(
      width: 52.w,
      height: 52.w,
      decoration: BoxDecoration(
        color: _categoryColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(child: Text(_categoryEmoji, style: TextStyle(fontSize: 24.sp))),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.montserrat(fontSize: 14.sp, fontWeight: FontWeight.w700, color: Colors.white70),
    );
  }

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _pickDate,
            child: _pickerCard(
              icon: Icons.calendar_today_rounded,
              label: _selectedDate != null ? _formatDate(_selectedDate!) : 'Select Date',
              isSelected: _selectedDate != null,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: GestureDetector(
            onTap: _pickTime,
            child: _pickerCard(
              icon: Icons.access_time_rounded,
              label: _selectedTime != null ? _formatTime(_selectedTime!) : 'Select Time',
              isSelected: _selectedTime != null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _pickerCard({required IconData icon, required String label, required bool isSelected}) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: isSelected ? _categoryColor.withOpacity(0.12) : Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isSelected ? _categoryColor.withOpacity(0.4) : Colors.white.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: isSelected ? _categoryColor : Colors.white38, size: 18.sp),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.montserrat(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? Colors.white : Colors.white38,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    switch (widget.businessCategory) {
      case 'salon':
        return _buildSalonSection();
      case 'turf':
        return _buildTurfSection();
      default:
        return _buildRestaurantSection();
    }
  }

  Widget _buildRestaurantSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Number of Guests'),
        SizedBox(height: 12.h),
        _buildGuestCounter(),
      ],
    );
  }

  Widget _buildGuestCounter() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Guests', style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white60)),
          Row(
            children: [
              _counterBtn(Icons.remove_rounded, () => setState(() { if (_guestsCount > 1) _guestsCount--; })),
              SizedBox(width: 16.w),
              Text(
                '$_guestsCount',
                style: GoogleFonts.montserrat(fontSize: 22.sp, fontWeight: FontWeight.w800, color: Colors.white),
              ),
              SizedBox(width: 16.w),
              _counterBtn(Icons.add_rounded, () => setState(() { if (_guestsCount < 20) _guestsCount++; })),
            ],
          ),
        ],
      ),
    );
  }

  Widget _counterBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: _categoryColor.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(color: _categoryColor.withOpacity(0.3)),
        ),
        child: Icon(icon, color: _categoryColor, size: 18.sp),
      ),
    );
  }

  IconData _getSportIcon(String sportName) {
    final name = sportName.toLowerCase();
    if (name.contains('football') || name.contains('soccer')) return Icons.sports_soccer_rounded;
    if (name.contains('cricket')) return Icons.sports_cricket_rounded;
    if (name.contains('volleyball')) return Icons.sports_volleyball_rounded;
    if (name.contains('badminton') || name.contains('tennis') || name.contains('racket')) return Icons.sports_tennis_rounded;
    if (name.contains('basketball')) return Icons.sports_basketball_rounded;
    if (name.contains('hockey')) return Icons.sports_hockey_rounded;
    if (name.contains('golf')) return Icons.sports_golf_rounded;
    if (name.contains('kabaddi') || name.contains('wrestling')) return Icons.sports_kabaddi_rounded;
    return Icons.sports_handball_rounded;
  }

  Widget _buildSalonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select Service'),
        SizedBox(height: 12.h),
        _dynamicServices.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _dynamicServices.length,
                itemBuilder: (context, index) {
                  final service = _dynamicServices[index];
                  final serviceName = service['name']?.toString() ?? 'Service';
                  final price = (service['price'] as num?)?.toDouble() ?? 0.0;
                  final duration = service['duration_minutes']?.toString() ?? '30';
                  final description = service['description']?.toString() ?? '';

                  final isSelected = _selectedService != null &&
                      (_selectedService == serviceName ||
                          _selectedService!.split(', ').contains(serviceName));

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedService = null;
                        } else {
                          _selectedService = serviceName;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _categoryColor.withOpacity(0.08)
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _categoryColor.withOpacity(0.6)
                              : Colors.white.withOpacity(0.08),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _categoryColor.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _categoryColor.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isSelected ? Icons.check_circle_rounded : Icons.spa_rounded,
                              color: isSelected ? _categoryColor : Colors.white38,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        serviceName,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "₹${price.toInt()}",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: _categoryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(Icons.schedule_outlined, size: 12.sp, color: Colors.white38),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "$duration mins",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11.sp,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                                if (description.isNotEmpty) ...[
                                  SizedBox(height: 6.h),
                                  Text(
                                    description,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.sp,
                                      color: Colors.white54,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _salonServices.map((svc) {
                  final isSelected = _selectedService == svc;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedService = svc),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: isSelected ? _categoryColor.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? _categoryColor : Colors.white.withOpacity(0.1),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        svc,
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? _categoryColor : Colors.white54,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildTurfSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Select Sport'),
        SizedBox(height: 12.h),
        _dynamicServices.isNotEmpty
            ? ListView.builder(
                padding: EdgeInsets.zero,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _dynamicServices.length,
                itemBuilder: (context, index) {
                  final service = _dynamicServices[index];
                  final name = service['name']?.toString() ?? 'Sport';
                  final price = (service['price'] as num?)?.toDouble() ?? 0.0;
                  final duration = service['duration_minutes']?.toString() ?? '60';
                  final description = service['description']?.toString() ?? '';
                  final icon = _getSportIcon(name);

                  final isSelected = _selectedSport != null &&
                      (_selectedSport == name ||
                          _selectedSport!.split(', ').contains(name));

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (isSelected) {
                          _selectedSport = null;
                        } else {
                          _selectedSport = name;
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: EdgeInsets.only(bottom: 12.h),
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _categoryColor.withOpacity(0.08)
                            : Colors.white.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? _categoryColor.withOpacity(0.6)
                              : Colors.white.withOpacity(0.08),
                          width: isSelected ? 1.5 : 1.0,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: _categoryColor.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? _categoryColor.withOpacity(0.15)
                                  : Colors.white.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              isSelected ? Icons.check_circle_rounded : icon,
                              color: isSelected ? _categoryColor : Colors.white38,
                              size: 18.sp,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        name,
                                        style: GoogleFonts.montserrat(
                                          fontSize: 13.sp,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      "₹${price.toInt()}",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w800,
                                        color: _categoryColor,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Icon(Icons.schedule_outlined, size: 12.sp, color: Colors.white38),
                                    SizedBox(width: 4.w),
                                    Text(
                                      "$duration mins",
                                      style: GoogleFonts.montserrat(
                                        fontSize: 11.sp,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ],
                                ),
                                if (description.isNotEmpty) ...[
                                  SizedBox(height: 6.h),
                                  Text(
                                    description,
                                    style: GoogleFonts.montserrat(
                                      fontSize: 11.sp,
                                      color: Colors.white54,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              )
            : Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _turfSports.map((sport) {
                  final isSelected = _selectedSport == sport;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedSport = sport),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
                      decoration: BoxDecoration(
                        color: isSelected ? _categoryColor.withOpacity(0.2) : Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isSelected ? _categoryColor : Colors.white.withOpacity(0.1),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Text(
                        sport,
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected ? _categoryColor : Colors.white54,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
        SizedBox(height: 20.h),
        _buildSectionTitle('Number of Players'),
        SizedBox(height: 12.h),
        _buildGuestCounter(),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Special Requests (Optional)'),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.04),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withOpacity(0.08)),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 3,
            style: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Any special requests or notes...',
              hintStyle: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.white24),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(14.w),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Consumer<BookingViewModel>(
      builder: (context, vm, _) => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _categoryColor,
            foregroundColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
          onPressed: vm.isSubmitting ? null : _submit,
          child: vm.isSubmitting
              ? SizedBox(
                  height: 20.h,
                  width: 20.h,
                  child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.send_rounded, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'Send Booking Request',
                      style: GoogleFonts.montserrat(fontSize: 15.sp, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
