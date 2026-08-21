import 'package:auth_katalog_app/core/utils/currency_formatter.dart';
import 'package:auth_katalog_app/presentation/controllers/product_detail_controller.dart';
import 'package:auth_katalog_app/presentation/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductDetailPage extends ConsumerWidget {
  final int productId;

  const ProductDetailPage({super.key, required this.productId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(productDetailControllerProvider(productId));

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Produk')),
      body: _buildBody(state, ref),
    );
  }

  Widget _buildBody(ProductDetailState state, WidgetRef ref) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.errorMessage != null) {
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
              onPressed: () => ref
                  .read(
                    productDetailControllerProvider(state.product?.id ?? 0)
                        .notifier,
                  )
                  .fetchDetail(),
            ),
          ],
        ),
      );
    }

    final product = state.product;
    if (product == null) {
      return const Center(child: Text('Produk tidak ditemukan'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (product.images.isNotEmpty)
            SizedBox(
              height: 250,
              child: PageView.builder(
                itemCount: product.images.length,
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      product.images[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_not_supported),
                      ),
                    ),
                  );
                },
              ),
            )
          else
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(child: Icon(Icons.image_not_supported)),
            ),
          const SizedBox(height: 16),
          Text(
            product.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            CurrencyFormatter.toRupiah(product.price),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            children: [
              Chip(
                label: Text(product.category),
                visualDensity: VisualDensity.compact,
              ),
              Chip(
                label: Text(product.brand ?? "-"),
                visualDensity: VisualDensity.compact,
              ),
              Chip(
                label: Text('⭐ ${product.rating}'),
                visualDensity: VisualDensity.compact,
              ),
              Chip(
                label: Text('Stok: ${product.stock}'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Deskripsi',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(product.description),
        ],
      ),
    );
  }
}
