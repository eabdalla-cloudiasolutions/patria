abstract class ProductsEvent {}

class LoadProducts extends ProductsEvent {
  final String? category;
  LoadProducts({this.category});
}

// class LoadCategories extends ProductsEvent {}
