import 'package:auth_katalog_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/repositories/auth_repository.dart';
import 'data/repositories/product_repository.dart';
import 'data/services/dio_client.dart';
import 'data/services/secure_storage_service.dart';
import 'presentation/controllers/auth_controller.dart';
import 'presentation/controllers/home_controller.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/splash_page.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  final storage = SecureStorageService();
  final dioClient = DioClient(
    storage,
    onLogout: () {
      // Refresh token invalid → kembali ke login, bersih dari stack.
      navigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    },
  );
  final authRepo = AuthRepository(dioClient, storage);
  final productRepo = ProductRepository(dioClient);

  runApp(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(authRepo),
        productRepositoryProvider.overrideWithValue(productRepo),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'Auth Katalog App',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: const SplashPage(),
    );
  }
}
