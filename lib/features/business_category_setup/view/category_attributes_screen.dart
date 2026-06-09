import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:creatoo/core.dart';
import 'package:creatoo/data/network/base_api_services.dart';
import 'package:creatoo/data/network/network_api_service.dart';
import 'package:creatoo/resources/app_url.dart';
import 'package:creatoo/widgets/custom_back_button.dart';
import '../../home/view_model/home_view_model.dart';

class _ServiceItem {
  final TextEditingController nameCtrl;
  final TextEditingController priceCtrl;
  final TextEditingController durationCtrl;
  _ServiceItem({required this.nameCtrl, required this.priceCtrl, required this.durationCtrl});
}

class CategoryAttributesScreen extends StatefulWidget {
  const CategoryAttributesScreen({super.key});

  @override
  State<CategoryAttributesScreen> createState() => _CategoryAttributesScreenState();
}

class _CategoryAttributesScreenState extends State<CategoryAttributesScreen> {
  final BaseApiServices _api = NetworkApiService();
  bool _isSaving = false;
  bool _isLoading = true;

  String _category = 'restaurant';
  Map<String, dynamic> _attrs = {};

  final _cuisineCtrl = TextEditingController();
  final _capacityCtrl = TextEditingController();
  bool _isVegOnly = false;
  String _genderSupport = 'unisex';

  final List<_ServiceItem> _services = [];
  final List<TextEditingController> _stylistCtrls = [];
  final List<TextEditingController> _amenityCtrls = [];

  String _turfSize = '';
  String _groundType = '';
  final List<TextEditingController> _sportCtrls = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    final vm = Provider.of<HomeViewModel>(context, listen: false);
    _category = vm.businessCategory?.toLowerCase() ?? 'restaurant';
    _attrs = vm.categoryAttributes ?? {};
    _populateFields();
    setState(() => _isLoading = false);
  }

  void _populateFields() {
    if (_category == 'restaurant') {
      _cuisineCtrl.text = (_attrs['cuisine_type'] as List?)?.join(', ') ?? '';
      _capacityCtrl.text = (_attrs['seating_capacity']?.toString()) ?? '';
      _isVegOnly = _attrs['is_veg_only'] == true;
    } else if (_category == 'salon') {
      for (final s in (_attrs['services'] as List? ?? [])) {
        _services.add(_ServiceItem(
          nameCtrl: TextEditingController(text: s['name']?.toString() ?? ''),
          priceCtrl: TextEditingController(text: s['price']?.toString() ?? ''),
          durationCtrl: TextEditingController(text: s['duration_minutes']?.toString() ?? ''),
        ));
      }
      for (final s in (_attrs['stylists'] as List? ?? [])) {
        _stylistCtrls.add(TextEditingController(text: s.toString()));
      }
      _genderSupport = _attrs['gender_support'] ?? 'unisex';
    } else if (_category == 'turf') {
      _turfSize = _attrs['turf_size'] ?? '';
      _groundType = _attrs['ground_type'] ?? '';
      for (final s in (_attrs['sport_types'] as List? ?? [])) {
        _sportCtrls.add(TextEditingController(text: s.toString()));
      }
      for (final a in (_attrs['amenities'] as List? ?? [])) {
        _amenityCtrls.add(TextEditingController(text: a.toString()));
      }
      for (final s in (_attrs['services'] as List? ?? [])) {
        _services.add(_ServiceItem(
          nameCtrl: TextEditingController(text: s['name']?.toString() ?? ''),
          priceCtrl: TextEditingController(text: s['price']?.toString() ?? ''),
          durationCtrl: TextEditingController(text: s['duration_minutes']?.toString() ?? ''),
        ));
      }
    }
  }

  @override
  void dispose() {
    _cuisineCtrl.dispose();
    _capacityCtrl.dispose();
    for (final s in _services) { s.nameCtrl.dispose(); s.priceCtrl.dispose(); s.durationCtrl.dispose(); }
    for (final c in _stylistCtrls) { c.dispose(); }
    for (final c in _amenityCtrls) { c.dispose(); }
    for (final c in _sportCtrls) { c.dispose(); }
    super.dispose();
  }

  Map<String, dynamic> _buildAttributes() {
    if (_category == 'restaurant') {
      return {
        'cuisine_type': _cuisineCtrl.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'seating_capacity': int.tryParse(_capacityCtrl.text) ?? 0,
        'is_veg_only': _isVegOnly,
      };
    } else if (_category == 'salon') {
      return {
        'services': _services.where((s) => s.nameCtrl.text.isNotEmpty).map((s) => {
          'name': s.nameCtrl.text.trim(),
          'price': double.tryParse(s.priceCtrl.text) ?? 0,
          'duration_minutes': int.tryParse(s.durationCtrl.text) ?? 30,
        }).toList(),
        'stylists': _stylistCtrls.map((c) => c.text.trim()).where((n) => n.isNotEmpty).toList(),
        'gender_support': _genderSupport,
      };
    } else {
      return {
        'turf_size': _turfSize,
        'ground_type': _groundType,
        'sport_types': _sportCtrls.map((c) => c.text.trim()).where((n) => n.isNotEmpty).toList(),
        'amenities': _amenityCtrls.map((c) => c.text.trim()).where((n) => n.isNotEmpty).toList(),
        'services': _services.where((s) => s.nameCtrl.text.isNotEmpty).map((s) => {
          'name': s.nameCtrl.text.trim(),
          'price': double.tryParse(s.priceCtrl.text) ?? 0,
          'duration_minutes': int.tryParse(s.durationCtrl.text) ?? 30,
        }).toList(),
      };
    }
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    try {
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${token ?? ""}',
      };
      final result = await _api.callPostAPI<Map<String, dynamic>, Map<String, dynamic>>(
        AppUrl.editBusinessProfile,
        headers,
        (response) => jsonDecode(response) as Map<String, dynamic>,
        body: {'category_attributes': _buildAttributes()},
      );
      result.fold(
        (error) => Utils.toastMessage("Failed: ${error.message}"),
        (response) {
          Utils.toastMessage("Saved successfully");
          Navigator.pop(context, true);
        },
      );
    } catch (e) {
      Utils.toastMessage("Failed to save");
    }
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator(color: AppColor.premiumAccent)));
    }
    return AppScaffold(
      useGradient: true, backgroundColor: AppColor.premiumBg, isSafe: false,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CustomBackButton(onTap: () => Navigator.pop(context)),
              SizedBox(width: 16.w),
              Text(
                _category == 'restaurant' ? "Menu Setup" : _category == 'salon' ? "Services Setup" : "Turf Setup",
                style: GoogleFonts.montserrat(fontSize: 20.sp, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ]),
            SizedBox(height: 24.h),
            if (_category == 'restaurant') ..._buildRestaurantForm(),
            if (_category == 'salon') ..._buildSalonForm(),
            if (_category == 'turf') ..._buildTurfForm(),
            SizedBox(height: 32.h),
            AppButton(onTap: _isSaving ? null : _save, text: _isSaving ? "Saving..." : "Save", icon: Icons.save_rounded),
          ]),
        ),
      ),
    );
  }

  List<Widget> _buildRestaurantForm() => [
    _label("Cuisine Types (comma-separated)"),
    _field(_cuisineCtrl, "e.g. Indian, Chinese, Italian"),
    SizedBox(height: 16.h),
    _label("Seating Capacity"),
    _field(_capacityCtrl, "e.g. 50", kt: TextInputType.number),
    SizedBox(height: 16.h),
    Row(children: [
      Text("Vegetarian Only", style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white70)),
      Spacer(),
      Switch(value: _isVegOnly, onChanged: (v) => setState(() => _isVegOnly = v), activeColor: AppColor.activeGreen),
    ]),
  ];

  List<Widget> _buildSalonForm() => [
    _label("Gender Support"),
    SizedBox(height: 8.h),
    Row(children: ['men', 'women', 'unisex'].map((g) {
      final sel = _genderSupport == g;
      return Expanded(child: GestureDetector(
        onTap: () => setState(() => _genderSupport = g),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: sel ? AppColor.premiumAccent.withOpacity(0.2) : Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: sel ? AppColor.premiumAccent : Colors.white.withOpacity(0.08)),
          ),
          child: Text(g[0].toUpperCase() + g.substring(1), textAlign: TextAlign.center,
            style: GoogleFonts.montserrat(fontSize: 12.sp, fontWeight: FontWeight.w600, color: sel ? AppColor.premiumAccent : Colors.white60)),
        ),
      ));
    }).toList()),
    SizedBox(height: 24.h),
    _sectionHeader("Services", () => setState(() => _services.add(_ServiceItem(
      nameCtrl: TextEditingController(), priceCtrl: TextEditingController(), durationCtrl: TextEditingController(),
    )))),
    ..._services.asMap().entries.map((e) => _serviceCard(e.key, e.value)),
    SizedBox(height: 16.h),
    _sectionHeader("Stylists", () => setState(() => _stylistCtrls.add(TextEditingController()))),
    ..._stylistCtrls.asMap().entries.map((e) => _listField(e.key, e.value, _stylistCtrls)),
  ];

  List<Widget> _buildTurfForm() => [
    _label("Turf Size"),
    _field(TextEditingController(text: _turfSize), "e.g. 7v7, 5v5", onChanged: (v) => _turfSize = v),
    SizedBox(height: 16.h),
    _label("Ground Type"),
    _field(TextEditingController(text: _groundType), "e.g. Artificial Grass, Natural", onChanged: (v) => _groundType = v),
    SizedBox(height: 24.h),
    _sectionHeader("Sport Types", () => setState(() => _sportCtrls.add(TextEditingController()))),
    ..._sportCtrls.asMap().entries.map((e) => _listField(e.key, e.value, _sportCtrls)),
    SizedBox(height: 16.h),
    _sectionHeader("Amenities", () => setState(() => _amenityCtrls.add(TextEditingController()))),
    ..._amenityCtrls.asMap().entries.map((e) => _listField(e.key, e.value, _amenityCtrls)),
    SizedBox(height: 16.h),
    _sectionHeader("Services / Packages", () => setState(() => _services.add(_ServiceItem(
      nameCtrl: TextEditingController(), priceCtrl: TextEditingController(), durationCtrl: TextEditingController(),
    )))),
    ..._services.asMap().entries.map((e) => _serviceCard(e.key, e.value)),
  ];

  Widget _label(String t) => Padding(padding: EdgeInsets.only(bottom: 8.h),
    child: Text(t, style: GoogleFonts.montserrat(fontSize: 13.sp, fontWeight: FontWeight.w600, color: Colors.white70)));

  Widget _field(TextEditingController c, String hint, {TextInputType? kt, void Function(String)? onChanged}) => SizedBox(height: 44.h,
    child: TextField(controller: c, keyboardType: kt, onChanged: onChanged,
      style: GoogleFonts.montserrat(fontSize: 14.sp, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint, hintStyle: GoogleFonts.montserrat(fontSize: 13.sp, color: Colors.white24),
        filled: true, fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
      )));

  Widget _sectionHeader(String title, VoidCallback onAdd) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
    _label(title),
    GestureDetector(onTap: onAdd, child: Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(color: AppColor.premiumAccent.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
      child: Text("+ Add", style: TextStyle(color: AppColor.premiumAccent, fontSize: 12.sp, fontWeight: FontWeight.bold)),
    )),
  ]);

  Widget _serviceCard(int i, _ServiceItem item) => Container(
    margin: EdgeInsets.only(top: 8.h), padding: EdgeInsets.all(12.w),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.06))),
    child: Column(children: [
      Row(children: [
        Expanded(child: _field(item.nameCtrl, "Service name")),
        SizedBox(width: 8.w),
        GestureDetector(onTap: () => setState(() => _services.removeAt(i)), child: Icon(Icons.close, color: Colors.redAccent, size: 18.sp)),
      ]),
      SizedBox(height: 8.h),
      Row(children: [
        Expanded(child: _field(item.priceCtrl, "Price", kt: TextInputType.number)),
        SizedBox(width: 8.w),
        Expanded(child: _field(item.durationCtrl, "Duration (min)", kt: TextInputType.number)),
      ]),
    ]),
  );

  Widget _listField(int i, TextEditingController c, List<TextEditingController> list) => Padding(
    padding: EdgeInsets.only(top: 8.h),
    child: Row(children: [
      Expanded(child: _field(c, "")),
      SizedBox(width: 8.w),
      GestureDetector(onTap: () => setState(() => list.removeAt(i)), child: Icon(Icons.close, color: Colors.redAccent, size: 18.sp)),
    ]),
  );
}
