import 'package:auth_katalog_app/core/theme/app_theme.dart';
import 'package:auth_katalog_app/presentation/controllers/auth_controller.dart';
import 'package:auth_katalog_app/presentation/widgets/app_button.dart';
import 'package:auth_katalog_app/presentation/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'home_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameCtrl = TextEditingController(text: 'emilys');
  final _passwordCtrl = TextEditingController(text: 'emilyspass');
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      if (next.isAuthenticated) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      }
    });

    return Scaffold(
      body: SafeArea(
        top: false,
        child: Container(
          color: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Auth\nKatalog',
                  style: TextStyle(
                    fontSize: 66,
                    height: 1,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.start,
                ),
                const SizedBox(height: 32),
                AppTextField(
                  controller: _usernameCtrl,
                  hintText: 'Masukkan username',
                  prefixIcon: Icons.person,
                  textInputAction: TextInputAction.next,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _passwordCtrl,
                  hintText: 'Masukkan password',
                  prefixIcon: Icons.lock,
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Wajib diisi' : null,
                ),
                const SizedBox(height: 8),
                if (authState.errorMessage != null)
                  Text(
                    authState.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Login',
                  isLoading: authState.isLoading,
                  onPressed: authState.isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            ref
                                .read(authControllerProvider.notifier)
                                .login(
                                  _usernameCtrl.text.trim(),
                                  _passwordCtrl.text.trim(),
                                );
                          }
                        },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
