// lib/features/product/presentation/manager/product_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patria/features/product/presentation/manager/%20product_state.dart';

import '../../data/repos/product_repo.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepo _repo = ProductRepo();

  ProductCubit() : super(ProductInitial());

  Future<void> getProducts() async {
    emit(ProductLoading());
    try {
      final products = await _repo.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      // The repo throws a formatted String (from ApiErrorHandler)
      final errorMessage = e is String ? e : e.toString();
      emit(ProductError(errorMessage));
    }
  }
}
