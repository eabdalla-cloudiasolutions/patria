import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/account/data/apis/addresses_api.dart';
import 'package:erb/features/account/presentation/views/widgets/edit_address_form.dart';
import 'package:erb/features/account/presentation/views/widgets/edit_address_map.dart';
import 'package:erb/features/account/presentation/views/widgets/edit_address_tags_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditAddressScreen extends StatefulWidget {
  final Map<String, dynamic> address;

  const EditAddressScreen({
    super.key,
    required this.address,
  });

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late TextEditingController _buildingController;
  late TextEditingController _aptController;
  late TextEditingController _floorController;
  late TextEditingController _streetController;
  late TextEditingController _nearbyController;
  late TextEditingController _phoneController;
  late TextEditingController _cityController; // ✅ add city

  String _selectedTag = 'Home';
  bool _isDefault = false; // ✅ add isDefault
  bool _isLoading = false; // ✅ loading state

  @override
  void initState() {
    super.initState();
    _selectedTag = widget.address['label'] ?? 'Home'; // ✅ use label not type
    _isDefault = widget.address['isDefault'] ?? false; // ✅ load isDefault
    _buildingController =
        TextEditingController(text: widget.address['building'] ?? '');
    _aptController = TextEditingController(text: widget.address['apt'] ?? '');
    _floorController =
        TextEditingController(text: widget.address['floor'] ?? '');
    _streetController =
        TextEditingController(text: widget.address['street'] ?? '');
    _nearbyController =
        TextEditingController(text: widget.address['nearby'] ?? '');
    _phoneController =
        TextEditingController(text: widget.address['phone'] ?? '');
    _cityController =
        TextEditingController(text: widget.address['city'] ?? ''); // ✅
  }

  @override
  void dispose() {
    _buildingController.dispose();
    _aptController.dispose();
    _floorController.dispose();
    _streetController.dispose();
    _nearbyController.dispose();
    _phoneController.dispose();
    _cityController.dispose(); // ✅
    super.dispose();
  }

  void _deleteAddress() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          'delete_address'.tr(),
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            fontSize: 16.sp,
          ),
        ),
        content: Text(
          'delete_address_message'.tr(),
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w400,
            fontSize: 14.sp,
            color: Color(0xFF515151),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext), // ✅ dialogContext
            child: Text(
              'cancel'.tr(),
              style: const TextStyle(
                color: Color(0xFF6B5E4B),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // ✅ dialogContext
              Navigator.pop(context, {'deleted': true});
            },
            child: Text(
              'delete'.tr(),
              style: const TextStyle(
                color: Color(0xFFC90000),
                fontFamily: 'Montserrat',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Call update API
  Future<void> _saveChanges() async {
    final id = widget.address['_id']?.toString() ?? '';

    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid address ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await AddressesApi().updateAddress(
        id: id,
        label: _selectedTag,
        street: _streetController.text.trim(),
        city: _cityController.text.trim(),
        area: widget.address['area'] ?? '',
        isDefault: _isDefault,
      );

      if (!mounted) return;
      Navigator.pop(context, {'updated': true}); // ✅ reload addresses list
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F7F7),
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        title: Text(
          'edit_address'.tr(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontFamily: 'Montserrat',
            fontWeight: FontWeight.w600,
            letterSpacing: 0.36,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.w),
            child: GestureDetector(
              onTap: _deleteAddress,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF0F0),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  'delete'.tr(),
                  style: TextStyle(
                    color: Color(0xFFC90000),
                    fontSize: 12.sp,
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h),
                  const EditAddressMap(),
                  SizedBox(height: 16.h),
                  EditAddressTagsRow(
                    selectedTag: _selectedTag,
                    onTagSelected: (tag) => setState(() => _selectedTag = tag),
                  ),
                  SizedBox(height: 16.h),
                  EditAddressForm(
                    buildingController: _buildingController,
                    aptController: _aptController,
                    floorController: _floorController,
                    streetController: _streetController,
                    nearbyController: _nearbyController,
                    phoneController: _phoneController,
                    cityController: _cityController, // ✅ pass city
                  ),

                  // ✅ Set as default toggle
                  SizedBox(height: 16.h),
                  GestureDetector(
                    onTap: () => setState(() => _isDefault = !_isDefault),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 20.w,
                          height: 20.h,
                          decoration: ShapeDecoration(
                            color: _isDefault
                                ? const Color(0xFF6B5E4B)
                                : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Color(0xFF6B5E4B)),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          ),
                          child: _isDefault
                              ? const Icon(Icons.check,
                                  size: 14, color: Colors.white)
                              : null,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          'set_as_default'.tr(),
                          style: TextStyle(
                            color: Color(0xFF333333),
                            fontSize: 13.sp,
                            fontFamily: 'Montserrat',
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.26,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),

          // ✅ Save button with loading
          Container(
            padding: EdgeInsets.only(
                left: 20.w, right: 20.w, bottom: 32.h, top: 16.h),
            color: const Color(0xFFF7F7F7),
            child: SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B5E4B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'save_changes'.tr(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w600,
                          height: 1.50,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
