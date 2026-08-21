import 'package:auth_katalog_app/core/utils/error_handler.dart';
import 'package:auth_katalog_app/data/models/product_model.dart';
import 'package:auth_katalog_app/data/models/user_model.dart';
import 'package:auth_katalog_app/data/repositories/auth_repository.dart';
import 'package:auth_katalog_app/data/repositories/product_repository.dart';
import 'package:auth_katalog_app/presentation/controllers/auth_controller.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

part 'home_controller.freezed.dart';

final productRepositoryProvider = Provider<ProductRepository>((ref) {
  throw UnimplementedError('Override di main');
});

final homeControllerProvider = StateNotifierProvider<HomeController, HomeState>(
  (ref) {
    final productRepo = ref.watch(productRepositoryProvider);
    final authRepo = ref.watch(authRepositoryProvider);
    return HomeController(productRepo, authRepo);
  },
);

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(false) bool isLoading,
    @Default(false) bool isLoadingMore,
    @Default([]) List<ProductModel> products,
    UserModel? profile,
    String? errorMessage,
    @Default(true) bool hasMore,
    @Default(0) int skip,
  }) = _HomeState;
}

class HomeController extends StateNotifier<HomeState> {
  final ProductRepository _productRepo;
  final AuthRepository _authRepo;

  HomeController(this._productRepo, this._authRepo) : super(const HomeState());

  Future<void> init() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final profile = await _authRepo.getProfile();
      final products = await _productRepo.getProducts(limit: 20, skip: 0);
      state = state.copyWith(
        isLoading: false,
        profile: profile,
        products: products.products,
        hasMore: products.products.length < products.total,
        skip: products.products.length,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppError.from(e).message,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;
    state = state.copyWith(isLoadingMore: true);
    try {
      final products = await _productRepo.getProducts(
        limit: 20,
        skip: state.skip,
      );
      final allProducts = [...state.products, ...products.products];
      state = state.copyWith(
        isLoadingMore: false,
        products: allProducts,
        hasMore: allProducts.length < products.total,
        skip: allProducts.length,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> refresh() async {
    state = const HomeState(isLoading: true);
    await init();
  }

  Future<void> search(String query) async {
    if (query.isEmpty) {
      await refresh();
      return;
    }
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final products = await _productRepo.searchProducts(query);
      state = state.copyWith(
        isLoading: false,
        products: products.products,
        hasMore: false,
        skip: 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppError.from(e).message,
      );
    }
  }
}
