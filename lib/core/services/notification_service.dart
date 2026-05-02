import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:moneywise/core/utils/currency_formatter.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';

class NotificationService {
  static final _notificationsPlugin = FlutterLocalNotificationsPlugin();
  static String _currencyCode = 'BDT';

  static Future<void> init(String currencyCode) async {
    _currencyCode = currencyCode;
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: DarwinInitializationSettings(),
    );

    await _notificationsPlugin.initialize(
      settings: initializationSettings,
    );
    
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  static Future<void> scheduleLoanDueReminder(LoanEntity loan) async {
    if (loan.dueDate == null) return;
    
    final scheduledDate = tz.TZDateTime.from(
      loan.dueDate!.subtract(const Duration(days: 1)),
      tz.local,
    ).add(const Duration(hours: 9)); // 9 AM day before

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    final symbol = CurrencyFormatter.getSymbol(_currencyCode);

    await _notificationsPlugin.zonedSchedule(
      id: loan.uuid.hashCode,
      title: 'Loan due tomorrow 💸',
      body: '$symbol${loan.amount.toStringAsFixed(0)} ${loan.type.name == "gave" ? "from" : "to"} ${loan.personName} is due tomorrow',
      scheduledDate: scheduledDate,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'loan_reminders',
          'Loan Reminders',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  static Future<void> showBudgetAlert({
    required String categoryName,
    required double percentage,
  }) async {
    String title = '';
    String body = '';
    
    if (percentage >= 1.0) {
      title = '🚨 Budget exceeded';
      body = '$categoryName has exceeded its monthly budget';
    } else if (percentage >= 0.8) {
      title = '⚠️ Budget warning';
      body = '$categoryName is at ${(percentage * 100).toStringAsFixed(0)}% of monthly budget';
    } else {
      return;
    }

    await _notificationsPlugin.show(
      id: categoryName.hashCode,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'budget_alerts',
          'Budget Alerts',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }

  static Future<void> cancelLoanReminder(String loanUuid) async {
    await _notificationsPlugin.cancel(id: loanUuid.hashCode);
  }

  static Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
