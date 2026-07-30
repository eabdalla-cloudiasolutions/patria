import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:patria/features/account/data/apis/addresses_api.dart';
import 'package:patria/features/account/data/models/address_model.dart';
import 'package:patria/features/checkout/data/models/delivery_zone_model.dart';
import 'package:patria/features/checkout/presentation/manager/delivery_zones_bloc.dart';
import 'package:patria/features/checkout/presentation/manager/delivery_zones_state.dart';
import 'package:patria/features/checkout/presentation/views/new_address_screen.dart';

class AddressSelectionSheet extends StatefulWidget {
  final String? selectedAddressId;
  final Function(
    String fullAddress,
    String addressId,
    String deliveryZoneId,
    String zoneName,
  )
  onAddressSelected;

  const AddressSelectionSheet({
    super.key,
    this.selectedAddressId,
    required this.onAddressSelected,
  });

  @override
  State<AddressSelectionSheet> createState() => _AddressSelectionSheetState();
}

class _AddressSelectionSheetState extends State<AddressSelectionSheet> {
  late Future<List<AddressModel>> _addressesFuture;

  @override
  void initState() {
    super.initState();
    _addressesFuture = AddressesApi().getAddresses();
  }

  String _formatAddress(AddressModel addr) {
    return '${addr.buildingName.isNotEmpty ? addr.buildingName : ""}, ${addr.street}, ${addr.zone}, ${addr.city}'
        .replaceAll(RegExp(r'^,\s*'), '');
  }

  Future<void> _selectAddress(AddressModel addr) async {
    String deliveryZoneId = '';
    String zoneName = addr.zone;

    try {
      final zonesBloc = context.read<DeliveryZonesBloc>();
      DeliveryZonesState currentState = zonesBloc.state;

      if (currentState is DeliveryZonesLoading) {
        try {
          await zonesBloc.stream
              .firstWhere((state) => state is DeliveryZonesLoaded)
              .timeout(const Duration(seconds: 5));
          currentState = zonesBloc.state;
        } catch (_) {}
      }

      if (currentState is DeliveryZonesLoaded) {
        final zones = currentState.zones;
        final matched = zones.firstWhere(
          (z) =>
              z.name.trim().toLowerCase() == addr.zone.trim().toLowerCase() ||
              z.name.trim().toLowerCase().contains(
                addr.zone.trim().toLowerCase(),
              ) ||
              addr.zone.trim().toLowerCase().contains(
                z.name.trim().toLowerCase(),
              ),
          orElse: () => DeliveryZone(
            id: '',
            name: '',
            deliveryFee: 0,
            minOrderAmount: 0,
            status: '',
            deliverySchedule: [],
          ),
        );
        deliveryZoneId = matched.id;
      }
    } catch (e) {
      print('Zone matching error: $e');
    }

    widget.onAddressSelected(
      _formatAddress(addr),
      addr.id,
      deliveryZoneId,
      zoneName,
    );
    if (mounted) Navigator.pop(context);
  }

  Future<void> _addNewAddress() async {
    // ✅ Open NewAddressScreen first (map screen)
    final result = await Navigator.of(
      context,
      rootNavigator: true,
    ).push(MaterialPageRoute(builder: (_) => const NewAddressScreen()));

    if (!mounted) return;

    final addressId = result is Map ? result['addressId'] as String? : null;
    if (addressId == null) {
      // ✅ Refresh addresses list after returning
      setState(() {
        _addressesFuture = AddressesApi().getAddresses();
      });
      return;
    }

    // ✅ Auto-select the address that was just created, regardless of
    // whether "set as default" was checked, instead of leaving nothing
    // selected until the user reopens this list.
    final addresses = await AddressesApi().getAddresses();
    if (!mounted) return;
    final newAddress = addresses.firstWhere(
      (a) => a.id == addressId,
      orElse: () => addresses.first,
    );
    await _selectAddress(newAddress);
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
                        final isSelected = widget.selectedAddressId == addr.id;
                        return GestureDetector(
                          onTap: () => _selectAddress(addr),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 12.h,
                            ),
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
                                              text: ' (${addr.zone})',
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
                                        ? const Color(0xFF3C4119)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: const Color(0xFF3C4119),
                                      width: isSelected ? 0 : 1,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
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
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: ElevatedButton(
                    onPressed: _addNewAddress,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5E8D3),
                      foregroundColor: const Color(0xFF3C4119),
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
