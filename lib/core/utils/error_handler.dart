import 'package:dio/dio.dart';

class AppError {
  final String message;
  final String? technical;
  final int? statusCode;

  const AppError({
    required this.message,
    this.technical,
    this.statusCode,
  });

  factory AppError.from(dynamic error) {
    if (error is DioException) {
      return _fromDio(error);
    }
    return AppError(
      message: 'Terjadi kesalahan. Coba lagi nanti.',
      technical: error.toString(),
    );
  }

  static AppError _fromDio(DioException error) {
    final statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return AppError(
          message:
              'Koneksi terlalu lambat. Periksa internet Anda dan coba lagi.',
          technical: error.message,
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return AppError(
          message:
              'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
          technical: error.message,
          statusCode: statusCode,
        );
      case DioExceptionType.badResponse:
        return _fromBadResponse(statusCode, error);
      case DioExceptionType.cancel:
        return AppError(
          message: 'Permintaan dibatalkan.',
          technical: error.message,
        );
      case DioExceptionType.unknown:
      default:
        return AppError(
          message: 'Terjadi kesalahan pada server. Coba lagi nanti.',
          technical: error.message ?? error.toString(),
          statusCode: statusCode,
        );
    }
  }

  static AppError _fromBadResponse(int? statusCode, DioException error) {
    final data = error.response?.data;
    String? serverMessage;
    if (data is Map) {
      final raw = data['message'] ?? data['error'] ?? data['errorMessage'];
      if (raw is String) serverMessage = raw;
    }

    switch (statusCode) {
      case 400:
        return AppError(
          message: serverMessage ??
              'Permintaan tidak valid. Periksa kembali input Anda.',
          technical: error.message,
          statusCode: statusCode,
        );
      case 401:
        return AppError(
          message: 'Sesi Anda telah berakhir. Silakan login kembali.',
          technical: error.message,
          statusCode: statusCode,
        );
      case 403:
        return AppError(
          message: 'Anda tidak memiliki akses untuk tindakan ini.',
          technical: error.message,
          statusCode: statusCode,
        );
      case 404:
        return AppError(
          message: 'Data yang dicari tidak ditemukan.',
          technical: error.message,
          statusCode: statusCode,
        );
      case 408:
        return AppError(
          message: 'Permintaan waktu habis. Coba lagi.',
          technical: error.message,
          statusCode: statusCode,
        );
      case 422:
        return AppError(
          message: serverMessage ?? 'Data yang dikirim tidak dapat diproses.',
          technical: error.message,
          statusCode: statusCode,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        return AppError(
          message: 'Server sedang mengalami gangguan. Coba beberapa saat lagi.',
          technical: error.message,
          statusCode: statusCode,
        );
      default:
        return AppError(
          message: serverMessage ?? 'Terjadi kesalahan pada server.',
          technical: error.message,
          statusCode: statusCode,
        );
    }
  }

  @override
  String toString() => message;
}
