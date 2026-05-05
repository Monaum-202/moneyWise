import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_provider.freezed.dart';
part 'settings_provider.g.dart';

@freezed
class AppSettings with _$AppSettings {
  const factory AppSettings({
    @Default(ThemeMode.system) ThemeMode themeMode,
    @Default('BDT') String currency,
    @Default('DD/MM/YYYY') String dateFormat,
    @Default(1) int firstDayOfWeek, // 1 = Monday, 7 = Sunday
    @Default(true) bool biometricEnabled,
    @Default(true) bool budgetAlertsEnabled,
    @Default(true) bool loanRemindersEnabled,
    @Default(false) bool autoBackupEnabled,
    @Default(false) bool smsTrackingEnabled,
  }) = _AppSettings;
  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);
}

class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const _key = 'app_settings';

  @override
  Future<AppSettings> build() async {
    final storage = ref.watch(secureStorageProvider);
    final raw = await storage.read(key: _key);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw));
    } catch (_) {
      return const AppSettings();
    }
  }

  Future<void> setTheme(ThemeMode mode) => _update((s) => s.copyWith(themeMode: mode));
  Future<void> setCurrency(String c) => _update((s) => s.copyWith(currency: c));
  Future<void> setDateFormat(String f) => _update((s) => s.copyWith(dateFormat: f));
  Future<void> setFirstDayOfWeek(int d) => _update((s) => s.copyWith(firstDayOfWeek: d));
  Future<void> setBiometric(bool v) => _update((s) => s.copyWith(biometricEnabled: v));
  Future<void> setBudgetAlerts(bool v) => _update((s) => s.copyWith(budgetAlertsEnabled: v));
  Future<void> setLoanReminders(bool v) => _update((s) => s.copyWith(loanRemindersEnabled: v));
  Future<void> setAutoBackup(bool v) => _update((s) => s.copyWith(autoBackupEnabled: v));
  Future<void> setSmsTracking(bool v) => _update((s) => s.copyWith(smsTrackingEnabled: v));

  Future<void> _update(AppSettings Function(AppSettings) updater) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = updater(current);
    state = AsyncData(updated);
    final storage = ref.read(secureStorageProvider);
    await storage.write(key: _key, value: jsonEncode(updated.toJson()));
  }
}

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

// Secure storage provider
final secureStorageProvider = Provider<FlutterSecureStorage>((_) => const FlutterSecureStorage());
