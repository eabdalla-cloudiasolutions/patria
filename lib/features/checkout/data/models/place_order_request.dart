class PlaceOrderRequest {
  final Customer customer;
  final List<OrderItem> items;
  final OrderSummary summary;
  final Payment payment;
  final String orderType;
  final String notes;
  final String specialRequests; // 👈 added
  final int pointsToRedeem;

  PlaceOrderRequest({
    required this.customer,
    required this.items,
    required this.summary,
    required this.payment,
    required this.orderType,
    required this.notes,
    this.specialRequests = '', // 👈 added
    required this.pointsToRedeem,
  });

  Map<String, dynamic> toJson() => {
        'customer': customer.toJson(),
        'items': items.map((e) => e.toJson()).toList(),
        'summary': summary.toJson(),
        'payment': payment.toJson(),
        'orderType': orderType,
        'notes': notes,
        'specialRequests': specialRequests, // 👈 added
        'pointsToRedeem': pointsToRedeem,
      };
}

class Customer {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String region;

  Customer({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.region,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'email': email,
        'phone': phone,
        'address': address,
        'region': region,
      };
}

class OrderItem {
  final String product;
  final String name;
  final int quantity;
  final double price;
  final String notes; // 👈 renamed from specialRequest
  final Customization customization;

  OrderItem({
    required this.product,
    required this.name,
    required this.quantity,
    required this.price,
    this.notes = '', // 👈 renamed, optional with default
    required this.customization,
  });

  Map<String, dynamic> toJson() => {
        'product': product,
        'name': name,
        'quantity': quantity,
        'price': price,
        'notes': notes, // 👈 renamed
        'customization': customization.toJson(),
      };
}

class Customization {
  final String roastLevel;
  final String grindType;

  Customization({required this.roastLevel, required this.grindType});

  Map<String, dynamic> toJson() => {
        'roastLevel': roastLevel,
        'grindType': grindType,
      };
}

class OrderSummary {
  final double subtotal;
  final double deliveryFee;
  final double surcharges;
  final double discount;
  final double total;
  final Coupon coupon;

  OrderSummary({
    required this.subtotal,
    required this.deliveryFee,
    required this.surcharges,
    required this.discount,
    required this.total,
    required this.coupon,
  });

  Map<String, dynamic> toJson() => {
        'subtotal': subtotal,
        'deliveryFee': deliveryFee,
        'surcharges': surcharges,
        'discount': discount,
        'total': total,
        'coupon': coupon.toJson(),
      };
}

class Coupon {
  final String code;
  final double amount;

  Coupon({required this.code, required this.amount});

  Map<String, dynamic> toJson() => {'code': code, 'amount': amount};
}

class Payment {
  final String method;
  final String status;

  Payment({required this.method, this.status = 'Pending'});

  Map<String, dynamic> toJson() => {'method': method, 'status': status};
}
