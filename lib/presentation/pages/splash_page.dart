import 'package:auth_katalog_app/presentation/controllers/auth_controller.dart';
import 'package:auth_katalog_app/presentation/pages/home_page.dart';
import 'package:auth_katalog_app/presentation/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 1));
    await ref.read(authControllerProvider.notifier).checkAuth();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authControllerProvider, (previous, next) {
      if (!next.isLoading) {
        if (next.isAuthenticated) {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => HomePage()));
        } else {
          Navigator.of(context)
              .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
        }
      }
    });

    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Memuat...'),
          ],
        ),
      ),
    );
  }
}
