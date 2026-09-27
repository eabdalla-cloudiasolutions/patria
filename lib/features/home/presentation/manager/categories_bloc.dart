import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:patria/features/home/data/apis/categories_api.dart';
import 'package:patria/features/home/presentation/manager/categories_event.dart';
import 'package:patria/features/home/presentation/manager/categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesApi _api = CategoriesApi();

  CategoriesBloc() : super(CategoriesInitial()) {
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    try {
      final categories = await _api.getCategories();
      emit(CategoriesLoaded(categories));
    } catch (e) {
      final errorMessage = e is String ? e : e.toString();
      emit(CategoriesError(errorMessage));
    }
  }
}
