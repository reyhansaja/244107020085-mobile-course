/// Formatting murni tanpa widget, supaya bisa diuji tanpa `flutter_test`
/// widget harness dan tidak memaksa presentation mengimpor `intl`.
String formatDateTime(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year} '
      '${two(value.hour)}:${two(value.minute)}';
}
