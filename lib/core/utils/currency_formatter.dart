import 'package:intl/intl.dart';

class CurrencyFormatter {
  // Harga dari API diformat langsung sebagai Rupiah (pemisah ribuan, tanpa
  // konversi kurs buatan). Asumsi: nilai `price` sudah dalam satuan Rupiah
  // untuk keperluan tampilan.
  static String toRupiah(double price) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp',
      decimalDigits: 0,
    );
    return formatter.format(price);
  }
}
