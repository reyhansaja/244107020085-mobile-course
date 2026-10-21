/// Parsing `RemoteMessage.data` -> rute, dipisah jadi fungsi murni supaya
/// bisa diunit-test tanpa Firebase dan dipakai ulang oleh semua handler.
String routeFromMessage(Map<String, dynamic> data) {
  final raw = (data['route'] as String?)?.trim() ?? '';
  if (raw.isEmpty) return '/';
  return raw.startsWith('/') ? raw : '/$raw';
}

/// `data.id` dipakai halaman tujuan bila rute tidak membawa parameter.
String? announcementIdFromMessage(Map<String, dynamic> data) {
  final id = (data['id'] as String?)?.trim();
  return (id == null || id.isEmpty) ? null : id;
}
