import 'package:auth_katalog_app/core/theme/app_theme.dart';
import 'package:auth_katalog_app/presentation/controllers/auth_controller.dart';
import 'package:auth_katalog_app/presentation/controllers/home_controller.dart';
import 'package:auth_katalog_app/presentation/pages/login_page.dart';
import 'package:auth_katalog_app/presentation/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _State();
}

class _State extends ConsumerState<ProfilePage> {
  Future<void> _confirmLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Yakin ingin keluar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(authControllerProvider.notifier).logout();
      if (mounted) {
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final profile = homeState.profile;

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        top: false,
        child: Container(
          alignment: Alignment.center,
          color: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: profile == null
              ? Column(
                  children: [
                    Text('User tidak ditemukan'),
                    const SizedBox(height: 16),
                    AppButton(
                      label: 'Login',
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                    ),
                  ],
                )
              : Column(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(profile.image!),
                      radius: 64,
                    ),
                    const SizedBox(height: 16),
                    Text('${profile.firstName} ${profile.lastName}'),
                    Text(profile.email!),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Logout',
                        onPressed: _confirmLogout,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
