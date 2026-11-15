/// Helper tampilan angka (hanya untuk UI, tidak dipakai dalam perhitungan).

/// Format desimal Indonesia (koma) tanpa nol di belakang.
/// Contoh: 30 -> "30", 82.5 -> "82,5", 12.345 -> "12,35".
String formatDecimal(double value, {int maxFractionDigits = 2}) {
  if (!value.isFinite) return '-';

  var text = value.toStringAsFixed(maxFractionDigits);

  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '');
    text = text.replaceFirst(RegExp(r'\.$'), '');
  }

  return text.replaceAll('.', ',');
}

/// Menampilkan angka apa adanya (tanpa pembulatan), memakai koma.
/// Sama dengan perilaku tampilan nilai akhir sebelum redesign.
String formatExact(double value) {
  return value.toString().replaceAll('.', ',');
}

/// Nomor urut dua digit: 1 -> "01".
String twoDigits(int number) => number.toString().padLeft(2, '0');
