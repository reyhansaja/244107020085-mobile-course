/// Parsing `RemoteMessage.data` -> rute, fungsi murni tanpa Firebase sehingga
/// bisa diunit-test dan dipakai bersama oleh GoRouter serta handler push.
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
