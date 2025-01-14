import 'dart:collection';
import 'dart:io' as io;

extension type const Env._(Map<String, String> _map) {
  factory Env() {
    final map = HashMap<String, String>.of(
      <String, String>{
        for (final MapEntry<String, String>(key: String k, value: String v) in io.Platform.environment.entries)
          if (k.isNotEmpty && v.isNotEmpty) k.trim().toLowerCase(): v.trim().toLowerCase(),
      },
    );
    return Env._(map);
  }

  /// Returns the value associated with the given [key] as a [T] or `null` if the
  /// key is not present or the value cannot be converted to [T].
  T? get<T>(String key) => switch (T) {
        const (String) => _map[key] as T?,
        const (int) => switch (_map[key]) {
            String value => int.tryParse(value) as T?,
            _ => null,
          },
        const (double) => switch (_map[key]) {
            String value => double.tryParse(value) as T?,
            _ => null,
          },
        const (num) => switch (_map[key]) {
            String value => num.tryParse(value) as T?,
            _ => null,
          },
        const (bool) => switch (_map[key]) {
            'true' || 'yes' || 'y' => true as T?,
            'false' || 'no' || 'n' => false as T?,
            _ => null,
          },
        const (List<String>) => _map[key]?.split(',') as T?,
        _ => null,
      };
}
