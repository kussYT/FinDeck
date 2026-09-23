import 'dart:math';

/// Identifiant local opaque. Ce n'est pas un identifiant de marché.
String createLocalId() {
  final random = Random.secure();
  final bytes = List<int>.generate(16, (_) => random.nextInt(256));
  return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
}
