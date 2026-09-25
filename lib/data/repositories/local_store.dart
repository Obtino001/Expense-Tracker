import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A small, serialized local store. Writes finish before a change is published,
/// so callers can report a failed save without losing the previous state.
class LocalListStore<T> extends StateNotifier<List<T>> {
  LocalListStore({
    required this.storageKey,
    required List<T> defaults,
    required this.decode,
    required this.encode,
  }) : super(List<T>.unmodifiable(defaults)) {
    ready = _load();
  }

  final String storageKey;
  final T Function(Map<String, dynamic>) decode;
  final Map<String, dynamic> Function(T) encode;
  late final Future<void> ready;
  Future<void> _pending = Future<void>.value();

  List<T> get current => state;

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(storageKey);
      if (raw != null) {
        final values = (jsonDecode(raw) as List<dynamic>)
            .map((dynamic item) => decode(Map<String, dynamic>.from(item as Map)))
            .toList();
        if (mounted) state = List<T>.unmodifiable(values);
      } else {
        await prefs.setString(storageKey, jsonEncode(state.map(encode).toList()));
      }
    } catch (_) {
      // Keep a damaged record intact so it can be recovered. The sample data
      // remains usable, and the next explicit mutation may replace the record.
    }
  }

  Future<void> change(List<T> Function(List<T>) transform) {
    final next = _pending.then((_) async {
      await ready;
      final updated = transform(List<T>.from(state));
      final prefs = await SharedPreferences.getInstance();
      final saved = await prefs.setString(
        storageKey,
        jsonEncode(updated.map(encode).toList()),
      );
      if (!saved) throw StateError('Unable to save on this device.');
      if (mounted) state = List<T>.unmodifiable(updated);
    });
    _pending = next.catchError((Object _) {});
    return next;
  }
}
