import 'package:dio/dio.dart';
import 'package:erb/features/home/data/apis/offers_api.dart';
import 'package:erb/features/home/data/models/offer_model.dart';

class OffersRepo {
  final OffersApi _api = OffersApi();

  Future<List<OfferModel>> getActiveOffers() async {
    try {
      final response = await _api.getActiveOffers();

      print('Offers API Response: ${response.data}');
      print('Response type: ${response.data.runtimeType}');

      List<dynamic> offersData = [];

      // API returns a direct list
      if (response.data is List) {
        offersData = response.data;
      } else if (response.data['data'] != null &&
          response.data['data'] is List) {
        offersData = response.data['data'];
      } else if (response.data['offers'] != null &&
          response.data['offers'] is List) {
        offersData = response.data['offers'];
      }

      print('Offers count: ${offersData.length}');

      if (offersData.isEmpty) {
        print('No offers found, using default');
        return _getDefaultOffers();
      }

      final offers = offersData
          .map((json) {
            try {
              return OfferModel.fromJson(json);
            } catch (e) {
              print('Error parsing offer: $e');
              print('JSON data: $json');
              return null;
            }
          })
          .whereType<OfferModel>()
          .toList();

      print('Parsed ${offers.length} offers');
      return offers.isNotEmpty ? offers : _getDefaultOffers();
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Dio error type: ${e.type}');
      return _getDefaultOffers();
    } catch (e) {
      print('Unexpected error: $e');
      return _getDefaultOffers();
    }
  }

  // Fallback default offers if API fails
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
