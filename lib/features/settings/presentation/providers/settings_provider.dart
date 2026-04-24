import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_provider.g.dart';

@riverpod
class AppSettings extends _$AppSettings {
  static const _themeKey = 'theme_mode';
  final _storage = const FlutterSecureStorage();

  @override
  FutureOr<ThemeMode> build() async {
    final theme = await _storage.read(key: _themeKey);
    return ThemeMode.values.firstWhere(
      (e) => e.name == theme,
      orElse: () => ThemeMode.system,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = AsyncData(mode);
    await _storage.write(key: _themeKey, value: mode.name);
  }
}
