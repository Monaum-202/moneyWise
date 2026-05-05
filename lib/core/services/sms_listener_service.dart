import 'dart:io';
import 'package:moneywise/core/services/notification_service.dart';
import 'package:moneywise/core/services/sms_parser.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:telephony/telephony.dart';

class SmsListenerService {
  static final _telephony = Telephony.instance;

  static Future<void> startListening(
    void Function(ParsedSmsTransaction) onTransaction,
  ) async {
    if (!Platform.isAndroid) return;

    final status = await Permission.sms.request();
    if (!status.isGranted) return;

    _telephony.listenIncomingSms(
      onNewMessage: (SmsMessage msg) {
        final parsed = SmsParser.parse(msg.body ?? '', msg.address ?? '');
        if (parsed != null) onTransaction(parsed);
      },
      onBackgroundMessage: _backgroundSmsHandler,
      listenInBackground: true,
    );
  }

  static Future<List<ParsedSmsTransaction>> scanInbox({
    int daysBack = 90,
  }) async {
    if (!Platform.isAndroid) return [];

    final status = await Permission.sms.request();
    if (!status.isGranted) return [];

    final cutoff = DateTime.now()
        .subtract(Duration(days: daysBack))
        .millisecondsSinceEpoch;

    final messages = await _telephony.getInboxSms(
      columns: [SmsColumn.ADDRESS, SmsColumn.BODY, SmsColumn.DATE],
      filter: SmsFilter.where(SmsColumn.DATE).greaterThan(cutoff.toString()),
      sortOrder: [OrderBy(SmsColumn.DATE, sort: Sort.DESC)],
    );

    final results = <ParsedSmsTransaction>[];
    for (final msg in messages) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        msg.date ?? DateTime.now().millisecondsSinceEpoch,
      );
      final parsed = SmsParser.parse(msg.body ?? '', msg.address ?? '', date: date);
      if (parsed != null) results.add(parsed);
    }
    return results;
  }
}

@pragma('vm:entry-point')
Future<void> _backgroundSmsHandler(SmsMessage message) async {
  if (!Platform.isAndroid) return;
  final parsed = SmsParser.parse(message.body ?? '', message.address ?? '');
  if (parsed != null) {
    await NotificationService.showSmsTransactionAlert(parsed);
  }
}
