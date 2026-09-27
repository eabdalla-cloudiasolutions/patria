import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patria/features/home/data/repos/products_repo.dart';
import 'package:patria/features/home/presentation/manager/products_event.dart';
import 'package:patria/features/home/presentation/manager/products_state.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepo _productsRepo;

  ProductsBloc(this._productsRepo) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    try {
      final products = await _productsRepo.getProducts(
        category: event.category,
      );
      emit(
        ProductsLoaded(
          products: products,
          selectedCategory: event.category ?? 'All',
        ),
      );
    } catch (e) {
      // The repo already throws a formatted String (from ApiErrorHandler)
      // So we can use it directly
      final errorMessage = e is String ? e : e.toString();
      emit(ProductsError(errorMessage));
    }
  }
}
