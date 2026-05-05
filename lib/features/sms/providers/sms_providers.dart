import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:moneywise/core/services/sms_listener_service.dart';
import 'package:moneywise/core/services/sms_parser.dart';
import 'package:moneywise/features/transactions/domain/transaction_model.dart';
import 'package:moneywise/shared/enums/recurring_type.dart';
import 'package:moneywise/shared/enums/transaction_type.dart';
import 'package:moneywise/shared/providers/repository_providers.dart';
import 'package:moneywise/features/settings/presentation/providers/settings_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';

final pendingSmsProvider = StateProvider<List<ParsedSmsTransaction>>((ref) => []);

class SmsTrackingNotifier extends StateNotifier<bool> {
  SmsTrackingNotifier(this._ref) : super(false) {
    _init();
  }
  final Ref _ref;

  void _init() {
    // Sync with persistent settings
    final enabled = _ref.watch(settingsProvider.select((s) => s.valueOrNull?.smsTrackingEnabled ?? false));
    state = enabled;
    if (enabled) {
      enable(isInitial: true);
    }
  }

  Future<bool> enable({bool isInitial = false}) async {
    if (!Platform.isAndroid) return false;

    final status = await Permission.sms.request();
    if (!status.isGranted) return false;

    await SmsListenerService.startListening((parsed) {
      _ref.read(pendingSmsProvider.notifier).update((list) => [...list, parsed]);
    });

    if (!isInitial) {
      await _ref.read(settingsProvider.notifier).setSmsTracking(true);
    }
    state = true;
    return true;
  }

  Future<void> disable() async {
    await _ref.read(settingsProvider.notifier).setSmsTracking(false);
    state = false;
    // Note: Telephony doesn't have a direct 'stop' but we'll stop responding to events
  }

  Future<List<ParsedSmsTransaction>> scanHistory() {
    if (!Platform.isAndroid) return Future.value([]);
    return SmsListenerService.scanInbox(daysBack: 90);
  }

  Future<void> confirmTransaction(
    ParsedSmsTransaction parsed,
    String categoryId,
  ) async {
    final repo = _ref.read(transactionRepositoryProvider);
    await repo.add(TransactionEntity(
      uuid: const Uuid().v4(),
      title:
          '${parsed.bankName} ${parsed.type == TransactionType.expense ? "Payment" : "Received"}',
      amount: parsed.amount,
      type: parsed.type,
      categoryId: categoryId,
      date: parsed.receivedAt,
      note: parsed.counterParty != null
          ? '${parsed.type == TransactionType.expense ? "To" : "From"}: ${parsed.counterParty}'
          : (parsed.reference ?? ''),
      isRecurring: false,
      recurringType: RecurringType.none,
      createdAt: DateTime.now(),
    ));

    _ref.read(pendingSmsProvider.notifier).update(
          (list) => list.where((t) => t != parsed).toList(),
        );
  }

  void dismissTransaction(ParsedSmsTransaction parsed) {
    _ref.read(pendingSmsProvider.notifier).update(
          (list) => list.where((t) => t != parsed).toList(),
        );
  }
}

final smsTrackingNotifierProvider =
    StateNotifierProvider<SmsTrackingNotifier, bool>(
        (ref) => SmsTrackingNotifier(ref));
