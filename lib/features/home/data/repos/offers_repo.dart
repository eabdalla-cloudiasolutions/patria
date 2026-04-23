import 'package:dio/dio.dart';
import 'package:erb/core/network/api_error_handler.dart';
import 'package:erb/features/home/data/apis/offers_api.dart';
import 'package:erb/features/home/data/models/offer_model.dart';

class OffersRepo {
  final OffersApi _api = OffersApi();

  Future<List<OfferModel>> getActiveOffers() async {
    try {
      final response = await _api.getActiveOffers();

      List<dynamic> offersData = [];

      if (response.data is List) {
        offersData = response.data;
      } else if (response.data['data'] != null &&
          response.data['data'] is List) {
        offersData = response.data['data'];
      } else if (response.data['offers'] != null &&
          response.data['offers'] is List) {
        offersData = response.data['offers'];
      }

      if (offersData.isEmpty) {
        return _getDefaultOffers();
      }

      final offers = offersData
          .map((json) {
            try {
              return OfferModel.fromJson(json);
            } catch (e) {
              return null;
            }
          })
          .whereType<OfferModel>()
          .toList();

      return offers.isNotEmpty ? offers : _getDefaultOffers();
    } on DioException catch (e) {
      // Log formatted error using ApiErrorHandler
      final errorMessage = ApiErrorHandler.handle(e);
      print('Offers API error: $errorMessage');
      return _getDefaultOffers();
    } catch (e) {
      print('Unexpected error in offers: $e');
      return _getDefaultOffers();
    }
  }

  List<OfferModel> _getDefaultOffers() {
    final now = DateTime.now();
    return [
      OfferModel(
        id: '1',
        title: 'Fresh Roasted Daily',
        description: 'Order now and get free delivery',
        imageUrl: 'assets/images/Banner.png',
        status: 'Active',
        includedProducts: [],
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        discountType: '',
        discountValue: 0,
        minOrderAmount: 0,
        usageCount: 0,
        discountPercent: null,
      ),
      OfferModel(
        id: '2',
        title: 'Special Offers',
        description: 'Check out our latest deals',
        imageUrl: 'assets/images/Banner.png',
        status: 'Active',
        includedProducts: [],
        startDate: now,
        endDate: now.add(const Duration(days: 30)),
        discountType: '',
        discountValue: 0,
        minOrderAmount: 0,
        usageCount: 0,
        discountPercent: null,
      ),
    ];
  }
}
