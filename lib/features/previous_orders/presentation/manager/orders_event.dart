abstract class OrdersEvent {}

class LoadOrders extends OrdersEvent {}

class RefreshOrders extends OrdersEvent {} // 👈 added