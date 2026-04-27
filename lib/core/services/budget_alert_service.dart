import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:moneywise/core/services/notification_service.dart';
import 'package:moneywise/features/categories/domain/category_model.dart';

class BudgetAlertService {
  final FlutterSecureStorage _storage;

  BudgetAlertService(this._storage);

  static const _keyPrefix = 'budget_alerts_';

  Future<void> checkAndTriggerAlert({
    required CategoryEntity category,
    required String monthYear,
    required double spent,
  }) async {
    if (category.monthlyBudget <= 0) return;

    final percentage = spent / category.monthlyBudget;
    if (percentage < 0.8) return;

    final storageKey = '$_keyPrefix$monthYear';
    final alertedJson = await _storage.read(key: storageKey);
    final alertedCategories = alertedJson != null 
        ? Set<String>.from(jsonDecode(alertedJson)) 
        : <String>{};

    // Alert levels: 80 (0.8) and 100 (1.0)
    final alert80Key = '${category.uuid}_80';
    final alert100Key = '${category.uuid}_100';

    bool triggered = false;

    if (percentage >= 1.0 && !alertedCategories.contains(alert100Key)) {
      await NotificationService.showBudgetAlert(
        categoryName: category.name,
        percentage: percentage,
      );
      alertedCategories.add(alert100Key);
      triggered = true;
    } else if (percentage >= 0.8 && percentage < 1.0 && !alertedCategories.contains(alert80Key)) {
      await NotificationService.showBudgetAlert(
        categoryName: category.name,
        percentage: percentage,
      );
      alertedCategories.add(alert80Key);
      triggered = true;
    }

    if (triggered) {
      await _storage.write(key: storageKey, value: jsonEncode(alertedCategories.toList()));
    }
  }
}
