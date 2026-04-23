import 'package:easy_localization/easy_localization.dart';
import 'package:erb/features/account/data/apis/addresses_api.dart';
import 'package:erb/features/account/data/models/address_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'address_form_sheet.dart';

class AddressSelectionSheet extends StatefulWidget {
  final Function(String fullAddress, String zoneId) onAddressSelected;

  const AddressSelectionSheet({super.key, required this.onAddressSelected});

  @override
  State<AddressSelectionSheet> createState() => _AddressSelectionSheetState();
}

class _AddressSelectionSheetState extends State<AddressSelectionSheet> {
  late Future<List<AddressModel>> _addressesFuture;
  String? _selectedAddressId;

  @override
  void initState() {
    super.initState();
    _addressesFuture = AddressesApi().getAddresses().then((list) {
      // Auto-select default address if any
      try {
        final defaultAddr = list.firstWhere((a) => a.isDefault);
        _selectedAddressId = defaultAddr.id;
      } catch (_) {}
      return list;
    });
  }

  String _formatAddress(AddressModel addr) {
    return '${addr.street}, ${addr.area}, ${addr.city}';
  }

  void _selectAddress(AddressModel addr) {
    widget.onAddressSelected(_formatAddress(addr), '');
    Navigator.pop(context); // closes selection sheet only
  }

  Future<void> _addNewAddress() async {
    // Open form sheet (do NOT close selection sheet yet)
    final result = await showModalBottomSheet<Map<String, String>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddressFormSheet(
        onSave: (address, zoneId) {
          // Close the form sheet and return the new address
          if (ctx.mounted) {
            Navigator.pop(ctx, {'address': address, 'zoneId': zoneId});
          }
        },
      ),
    );

    if (result != null && mounted) {
      // Pass the new address to the checkout screen
      widget.onAddressSelected(result['address']!, result['zoneId']!);
      // Close the selection sheet (this should return to checkout screen)
      // Use Navigator.of(context).pop() – same as Navigator.pop(context)
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 12.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFCACBD4),
                    borderRadius: BorderRadius.circular(100.r),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'saved_addresses'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF28293D),
                      ),
                    ),
                    const SizedBox(width: 28),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              // Address list
              Expanded(
                child: FutureBuilder<List<AddressModel>>(
                  future: _addressesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(height: 8.h),
                            Text('failed_to_load_addresses'.tr()),
                            ElevatedButton(
                              onPressed: () => setState(() {}),
                              child: Text('retry'.tr()),
                            ),
                          ],
                        ),
                      );
                    }
                    final addresses = snapshot.data!;
                    if (addresses.isEmpty) {
                      return Center(child: Text('no_addresses_found'.tr()));
                    }
                    return ListView.separated(
                      controller: scrollController,
                      itemCount: addresses.length,
                      separatorBuilder: (_, __) => Divider(
                        color: const Color(0xFFCACBD4),
                        height: 1.h,
                        thickness: 1,
                      ),
                      itemBuilder: (_, index) {
                        final addr = addresses[index];
                        final isSelected = _selectedAddressId == addr.id;
                        return GestureDetector(
                          onTap: () => _selectAddress(addr),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: addr.label,
                                              style: TextStyle(
                                                color: const Color(0xFF333333),
                                                fontSize: 16.sp,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            TextSpan(
                                              text: ' (${addr.area})',
                                              style: TextStyle(
                                                color: const Color(0xFF8B8B8B),
                                                fontSize: 14.sp,
                                                fontFamily: 'Montserrat',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 4.h),
                                      Text(
                                        _formatAddress(addr),
                                        style: TextStyle(
                                          color: const Color(0xFF8B8B8B),
                                          fontSize: 13.sp,
                                          fontFamily: 'Montserrat',
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 20.w,
                                  height: 20.h,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? const Color(0xFF6B5E4B)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: const Color(0xFF6B5E4B),
                                      width: isSelected ? 0 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check,
                                          size: 14, color: Colors.white)
                                      : null,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              // Add new address button
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _addNewAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF5F0EA),
                      foregroundColor: const Color(0xFF6B5E4B),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                    ),
                    child: Text(
                      'add_new_address'.tr(),
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontFamily: 'Montserrat',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        );
      },
    );
  }
}
