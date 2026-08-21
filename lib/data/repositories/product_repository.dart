import 'package:auth_katalog_app/core/constants/api_contant.dart';
import 'package:auth_katalog_app/data/models/product_model.dart';
import 'package:auth_katalog_app/data/services/dio_client.dart';

class ProductRepository {
  final DioClient _dioClient;

  ProductRepository(this._dioClient);

  Future<ProductListResponseModel> getProducts({
    int limit = 20,
    int skip = 0,
  }) async {
    final response = await _dioClient.dio.get(
      ApiConstants.products,
      queryParameters: {'limit': limit, 'skip': skip},
    );
    return ProductListResponseModel.fromJson(response.data);
  }

  Future<ProductListResponseModel> searchProducts(String query) async {
    final response = await _dioClient.dio.get(
      ApiConstants.searchProducts,
      queryParameters: {'q': query},
    );
    return ProductListResponseModel.fromJson(response.data);
  }

  Future<ProductModel> getProductDetail(int id) async {
    final response = await _dioClient.dio.get('${ApiConstants.products}/$id');
    return ProductModel.fromJson(response.data);
  }
}
