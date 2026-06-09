import 'dart:ui';
import '../../../../core.dart';
import '../../view_model/edit_business_profile_view_model.dart';

Widget businessServicesWidget(BuildContext context) {
  EditBusinessProfileViewModel viewModel = Provider.of<EditBusinessProfileViewModel>(context);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(Icons.list_alt_rounded, color: AppColor.premiumAccent, size: 20.sp),
          SizedBox(width: 10.w),
          Text(
            'Services Offered',
            style: GoogleFonts.montserrat(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
      SizedBox(height: 4.h),
      Text(
        'Manage your service catalog with pricing and add-ons',
        style: GoogleFonts.montserrat(
          fontSize: 11.sp,
          color: Colors.white38,
        ),
      ),
      SizedBox(height: 20.h),

      if (viewModel.services.isEmpty)
        _buildEmptyState(viewModel, context)
      else
        ...viewModel.services.asMap().entries.map((entry) {
          final i = entry.key;
          final svc = entry.value;
          return _buildServiceCard(context, viewModel, svc, i);
        }),

      if (viewModel.isEditing) ...[
        SizedBox(height: 16.h),
        GestureDetector(
          onTap: () => _showServiceForm(context, viewModel),
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
                  Text(
                    "Add New Service",
                    style: GoogleFonts.montserrat(
                      fontSize: 13.sp,
                      color: AppColor.premiumAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ],
  );
}

Widget _buildEmptyState(EditBusinessProfileViewModel viewModel, BuildContext context) {
  return Container(
    width: double.infinity,
    padding: EdgeInsets.all(32.w),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.03),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
    ),
    child: Column(
      children: [
        Icon(Icons.construction_rounded, color: Colors.white24, size: 48.sp),
        SizedBox(height: 12.h),
        Text(
          'No services added yet',
          style: GoogleFonts.montserrat(
            fontSize: 14.sp,
            color: Colors.white38,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Tap "Add New Service" below to get started',
          style: GoogleFonts.montserrat(
            fontSize: 11.sp,
            color: Colors.white24,
          ),
        ),
      ],
    ),
  );
}

Widget _buildServiceCard(BuildContext context, EditBusinessProfileViewModel viewModel, Map<String, dynamic> svc, int index) {
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
              decoration: BoxDecoration(
                color: AppColor.premiumAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.build_rounded, color: AppColor.premiumAccent, size: 20.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    svc['name']?.toString() ?? 'Service',
                    style: GoogleFonts.montserrat(
                      fontSize: 14.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (description.isNotEmpty) ...[
                    SizedBox(height: 4.h),
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${svc['price']}",
                  style: GoogleFonts.montserrat(
                    fontSize: 16.sp,
                    color: AppColor.premiumAccent,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  "${svc['duration_minutes']} min",
                  style: GoogleFonts.montserrat(
                    fontSize: 10.sp,
                    color: Colors.white38,
                  ),
                ),
              ],
            ),
          ],
        ),

        if (addOns.isNotEmpty) ...[
          SizedBox(height: 12.h),
          Divider(color: Colors.white.withValues(alpha: 0.06)),
          SizedBox(height: 8.h),
          Text(
            'Add-ons',
            style: GoogleFonts.montserrat(
              fontSize: 11.sp,
              color: Colors.white38,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          ...addOns.map((addOn) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  addOn['name']?.toString() ?? '',
                  style: GoogleFonts.montserrat(
                    fontSize: 11.sp,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  "₹${addOn['price']}",
                  style: GoogleFonts.montserrat(
                    fontSize: 11.sp,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
          )),
        ],

        if (viewModel.isEditing) ...[
          SizedBox(height: 12.h),
          Divider(color: Colors.white.withValues(alpha: 0.06)),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () => _showServiceForm(context, viewModel, index: index),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_rounded, color: Colors.white54, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Edit',
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () {
                  viewModel.services.removeAt(index);
                  viewModel.notify();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.delete_rounded, color: Colors.redAccent, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        'Remove',
                        style: GoogleFonts.montserrat(
                          fontSize: 12.sp,
                          color: Colors.redAccent,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

void _showServiceForm(BuildContext context, EditBusinessProfileViewModel viewModel, {int? index}) {
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
                  Center(
                    child: Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Text(
                    isEdit ? "Edit Service" : "Add New Service",
                    style: GoogleFonts.montserrat(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildFormField(
                            label: "Service Name",
                            controller: nameCtl,
                            hint: "e.g. Haircut, Facial, Turf Booking",
                          ),
                          SizedBox(height: 16.h),
                          _buildFormField(
                            label: "Description",
                            controller: descCtl,
                            hint: "Brief description of the service",
                            maxLines: 3,
                          ),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: _buildFormField(
                                  label: "Price (₹)",
                                  controller: priceCtl,
                                  hint: "e.g. 500",
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: _buildFormField(
                                  label: "Duration (min)",
                                  controller: durCtl,
                                  hint: "e.g. 60",
                                  keyboardType: TextInputType.number,
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: 24.h),
                          Divider(color: Colors.white.withValues(alpha: 0.08)),
                          SizedBox(height: 12.h),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Add-ons',
                                style: GoogleFonts.montserrat(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white70,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    addOns.add({'name': '', 'price': 0});
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                                  decoration: BoxDecoration(
                                    color: AppColor.premiumAccent.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_rounded, color: AppColor.premiumAccent, size: 14.sp),
                                      SizedBox(width: 4.w),
                                      Text(
                                        'Add Add-on',
                                        style: GoogleFonts.montserrat(
                                          fontSize: 11.sp,
                                          color: AppColor.premiumAccent,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
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
                              child: Center(
                                child: Text(
                                  'No add-ons yet',
                                  style: GoogleFonts.montserrat(
                                    fontSize: 12.sp,
                                    color: Colors.white24,
                                  ),
                                ),
                              ),
                            )
                          else
                            ...addOns.asMap().entries.map((entry) {
                              final aIndex = entry.key;
                              final addOn = entry.value;
                              final addOnNameCtl = TextEditingController(text: addOn['name']?.toString() ?? '');
                              final addOnPriceCtl = TextEditingController(text: addOn['price']?.toString() ?? '');

                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 3,
                                      child: TextField(
                                        controller: addOnNameCtl,
                                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                        decoration: InputDecoration(
                                          hintText: "Name",
                                          hintStyle: TextStyle(color: Colors.white24, fontSize: 13.sp),
                                          filled: true,
                                          fillColor: Colors.white.withValues(alpha: 0.03),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: AppColor.premiumAccent),
                                          ),
                                        ),
                                        onChanged: (v) => addOn['name'] = v.trim(),
                                      ),
                                    ),
                                    SizedBox(width: 8.w),
                                    Expanded(
                                      flex: 2,
                                      child: TextField(
                                        controller: addOnPriceCtl,
                                        keyboardType: TextInputType.number,
                                        style: TextStyle(color: Colors.white, fontSize: 13.sp),
                                        decoration: InputDecoration(
                                          hintText: "Price",
                                          hintStyle: TextStyle(color: Colors.white24, fontSize: 13.sp),
                                          filled: true,
                                          fillColor: Colors.white.withValues(alpha: 0.03),
                                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: AppColor.premiumAccent),
                                          ),
                                        ),
                                        onChanged: (v) => addOn['price'] = double.tryParse(v) ?? 0,
                                      ),
                                    ),
                                    SizedBox(width: 4.w),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          addOns.removeAt(aIndex);
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
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
                          child: Text(
                            "Cancel",
                            style: GoogleFonts.montserrat(
                              color: Colors.white54,
                              fontWeight: FontWeight.w600,
                              fontSize: 14.sp,
                            ),
                          ),
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
                          child: Text(
                            isEdit ? "Save Changes" : "Add Service",
                            style: GoogleFonts.montserrat(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 14.sp,
                            ),
                          ),
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

Widget _buildFormField({
  required String label,
  required TextEditingController controller,
  String? hint,
  int? maxLines,
  TextInputType? keyboardType,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: EdgeInsets.only(left: 4.w, bottom: 8.h),
        child: Text(
          label,
          style: GoogleFonts.montserrat(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColor.premiumTextSecondary,
          ),
        ),
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
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColor.premiumAccent, width: 1.5),
          ),
        ),
      ),
    ],
  );
}
