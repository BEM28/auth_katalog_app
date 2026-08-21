import 'package:auth_katalog_app/core/constants/api_contant.dart';
import 'package:auth_katalog_app/data/models/auth_response_model.dart';
import 'package:auth_katalog_app/data/models/user_model.dart';
import 'package:auth_katalog_app/data/services/dio_client.dart';
import 'package:auth_katalog_app/data/services/secure_storage_service.dart';

class AuthRepository {
  final DioClient _dioClient;
  final SecureStorageService _storage;

  AuthRepository(this._dioClient, this._storage);

  Future<AuthResponseModel> login(String username, String password) async {
    final response = await _dioClient.dio.post(
      ApiConstants.login,
      data: {'username': username, 'password': password, 'expiresInMins': 1},
    );

    final auth = AuthResponseModel.fromJson(response.data);
    await _storage.saveTokens(auth.accessToken!, auth.refreshToken!);
    return auth;
  }

  Future<UserModel> getProfile() async {
    final response = await _dioClient.dio.get(ApiConstants.me);
    return UserModel.fromJson(response.data);
  }

  Future<void> logout() async {
    await _storage.clearTokens();
  }

  Future<bool> isLoggedIn() async {
    return await _storage.hasToken();
  }
}
