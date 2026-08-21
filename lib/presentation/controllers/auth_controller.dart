import 'package:auth_katalog_app/core/utils/error_handler.dart';
import 'package:auth_katalog_app/data/models/auth_response_model.dart';
import 'package:auth_katalog_app/data/models/user_model.dart';
import 'package:auth_katalog_app/data/repositories/auth_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod/legacy.dart';
import 'package:riverpod/riverpod.dart';

part 'auth_controller.freezed.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  throw UnimplementedError('Override di main');
});

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    final repo = ref.watch(authRepositoryProvider);
    return AuthController(repo);
  },
);

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(false) bool isLoading,
    @Default(false) bool isAuthenticated,
    String? errorMessage,
    AuthResponseModel? user,
    UserModel? profile,
  }) = _AuthState;
}

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthController(this._repository) : super(const AuthState());

  Future<void> checkAuth() async {
    final isLoggedIn = await _repository.isLoggedIn();
    state = state.copyWith(isAuthenticated: isLoggedIn);
  }

  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final auth = await _repository.login(username, password);
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: auth,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: AppError.from(e).message,
      );
    }
  }

  Future<void> fetchProfile() async {
    try {
      final profile = await _repository.getProfile();
      state = state.copyWith(profile: profile);
    } catch (e) {
      // Profil gagal dimuat; abaikan agar tidak mengganggu alur login.
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState();
  }
}
