/// Kontrak push notification. Presentation hanya tahu kontrak ini, sehingga
/// Firebase bisa diganti/dimatikan tanpa menyentuh UI.
abstract class PushRepository {
  bool get enabled;

  Future<void> start({
    required Future<void> Function(String token) onToken,
    required void Function(String route) go,
  });

  Future<void> subscribe(String topic);

  Future<void> unsubscribe(String topic);
}
