import 'package:freezed_annotation/freezed_annotation.dart';

part 'product_model.freezed.dart';
part 'product_model.g.dart';

@freezed
abstract class ProductModel with _$ProductModel {
  const factory ProductModel({
    required int id,
    required String title,
    required String description,
    required String category,
    required double price,
    required double discountPercentage,
    required double rating,
    required int stock,
    String? brand,
    required String thumbnail,
    required List<String> images,
  }) = _ProductModel;

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);
}

@freezed
abstract class ProductListResponseModel with _$ProductListResponseModel {
  const factory ProductListResponseModel({
    required List<ProductModel> products,
    required int total,
    required int skip,
    required int limit,
  }) = _ProductListResponseModel;

  factory ProductListResponseModel.fromJson(Map<String, dynamic> json) =>
      _$ProductListResponseModelFromJson(json);
}
