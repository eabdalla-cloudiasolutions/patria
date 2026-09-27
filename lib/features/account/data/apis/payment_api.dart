import 'package:patria/core/network/api_client.dart';
import 'package:patria/core/network/api_endpoints.dart';
import 'package:patria/features/account/data/models/payment_method_model.dart';

class PaymentApi {
  Future<List<PaymentMethodModel>> getPaymentMethods() async {
    final response = await ApiClient.instance.get(ApiEndpoints.paymentMethods);
    final List data = response.data as List;
    return data.map((e) => PaymentMethodModel.fromJson(e)).toList();
  }

  Future<void> addPaymentMethod({
    required String cardType,
    required String last4,
    required String cardholderName,
    required String expiryMonth,
    required String expiryYear,
    bool isDefault = false,
  }) async {
    await ApiClient.instance.post(
      ApiEndpoints.paymentMethods,
      data: {
        'cardType': cardType,
        'last4': last4,
        'cardholderName': cardholderName,
        'expiryMonth': expiryMonth,
        'expiryYear': expiryYear,
        'isDefault': isDefault,
      },
    );
  }

  Future<void> deleteCard(String id) async {
    await ApiClient.instance.delete(ApiEndpoints.deleteCard(id));
  }

  Future<void> setDefaultCard(String id) async {
    await ApiClient.instance.patch(ApiEndpoints.setDefaultCard(id));
  }
}
