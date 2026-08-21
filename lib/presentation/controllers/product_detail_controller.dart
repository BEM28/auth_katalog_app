import 'package:auth_katalog_app/core/utils/error_handler.dart';
import 'package:auth_katalog_app/data/models/product_model.dart';
import 'package:auth_katalog_app/data/repositories/product_repository.dart';
import 'package:auth_katalog_app/presentation/controllers/home_controller.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/legacy.dart';

part 'product_detail_controller.freezed.dart';

final productDetailControllerProvider =
    StateNotifierProvider.family<
      ProductDetailController,
      ProductDetailState,
      int
    >((ref, id) {
      final repo = ref.watch(productRepositoryProvider);
      return ProductDetailController(repo, id);
    });

@freezed
abstract class ProductDetailState with _$ProductDetailState {
  const factory ProductDetailState({
    @Default(false) bool isLoading,
    ProductModel? product,
    String? errorMessage,
  }) = _ProductDetailState;
}

class ProductDetailController extends StateNotifier<ProductDetailState> {
  final ProductRepository _repository;
  final int _productId;

  ProductDetailController(this._repository, this._productId)
    : super(const ProductDetailState()) {
    fetchDetail();
  }

  Future<void> fetchDetail() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final product = await _repository.getProductDetail(_productId);
      state = state.copyWith(isLoading: false, product: product);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppError.from(e).message,
      );
    }
  }
}
