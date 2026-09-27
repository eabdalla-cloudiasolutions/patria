import 'package:patria/features/home/data/models/product_model.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;
  final String selectedCategory;

  ProductsLoaded({required this.products, this.selectedCategory = 'All'});

  ProductsLoaded copyWith({
    List<ProductModel>? products,
    String? selectedCategory,
  }) {
    return ProductsLoaded(
      products: products ?? this.products,
      selectedCategory: selectedCategory ?? this.selectedCategory,
    );
  }
}

class ProductsError extends ProductsState {
  final String message;
  ProductsError(this.message);
}
