import 'package:erb/features/home/data/repos/products_repo.dart';
import 'package:erb/features/home/presentation/manager/products_event.dart';
import 'package:erb/features/home/presentation/manager/products_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ProductsRepo _productsRepo;

  ProductsBloc(this._productsRepo) : super(ProductsInitial()) {
    on<LoadProducts>(_onLoadProducts);
    // ❌ Remove on<LoadCategories>
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductsLoading());
    try {
      final products =
          await _productsRepo.getProducts(category: event.category);
      emit(ProductsLoaded(
        products: products,
        selectedCategory: event.category ?? 'All',
      ));
    } catch (e) {
      emit(ProductsError(e.toString()));
    }
  }
}
