/// Semua string rute hidup di satu tempat supaya deep link dari FCM dan
/// GoRouter memakai konstanta yang sama.
class AppRoutes {
  const AppRoutes._();

  static const login = '/login';
  static const home = '/';
  static const announcement = '/pengumuman/:id';

  static String announcementDetail(String id) => '/pengumuman/$id';
}
