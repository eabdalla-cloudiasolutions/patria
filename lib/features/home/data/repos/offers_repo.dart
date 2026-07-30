import 'package:dio/dio.dart';
import 'package:patria/core/network/api_error_handler.dart';
import 'package:patria/features/home/data/apis/offers_api.dart';
import 'package:patria/features/home/data/models/offer_model.dart';

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

      if (offersData.isEmpty) return [];

      return offersData
          .map((json) {
            try {
              return OfferModel.fromJson(json);
            } catch (e) {
              return null;
            }
          })
          .whereType<OfferModel>()
          .toList();
    } on DioException catch (e) {
      final errorMessage = ApiErrorHandler.handle(e);
      print('Offers API error: $errorMessage');
      return [];
    } catch (e) {
      print('Unexpected error in offers: $e');
      return [];
    }
  }
}
