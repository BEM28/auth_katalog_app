import 'package:auth_katalog_app/core/theme/app_theme.dart';
import 'package:auth_katalog_app/core/utils/debouncer.dart';
import 'package:auth_katalog_app/presentation/controllers/home_controller.dart';
import 'package:auth_katalog_app/presentation/pages/profile_page.dart';
import 'package:auth_katalog_app/presentation/widgets/app_button.dart';
import 'package:auth_katalog_app/presentation/widgets/app_text_field.dart';
import 'package:auth_katalog_app/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'product_detail_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _searchCtrl = TextEditingController();
  final _debouncer = Debouncer(milliseconds: 400);
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(homeControllerProvider.notifier).init();
    });
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(homeControllerProvider.notifier).loadMore();
    }
  }

  static String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 18) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debouncer.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeControllerProvider);
    final profile = homeState.profile;

    return SafeArea(
      top: false,
      child: Scaffold(
        body: Container(
          color: AppColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 50),
              if (profile != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfilePage()),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        padding: EdgeInsets.all(4),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(profile.image!),
                          radius: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _greeting(),
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                          Text(
                            '${profile.firstName} ${profile.lastName}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_forward_ios),
                    ],
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                child: AppTextField(
                  controller: _searchCtrl,
                  hintText: 'Cari produk...',
                  prefixIcon: Icons.search,
                  onChanged: (value) {
                    _debouncer.run(() {
                      ref
                          .read(homeControllerProvider.notifier)
                          .search(value.trim());
                    });
                  },
                ),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildContent(homeState)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(HomeState state) {
    if (state.isLoading && state.products.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null && state.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text(state.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            AppButton(
              label: 'Coba Lagi',
              onPressed: () =>
                  ref.read(homeControllerProvider.notifier).refresh(),
            ),
          ],
        ),
      );
    }

    if (state.products.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('Tidak ada produk'),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(homeControllerProvider.notifier).refresh(),
      child: GridView.builder(
        controller: _scrollController,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 0.72,
        ),
        itemCount: state.products.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.products.length) {
            return const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final product = state.products[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: ProductCard(
              product: product,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ProductDetailPage(productId: product.id),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
