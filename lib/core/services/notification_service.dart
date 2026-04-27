import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:moneywise/features/loans/domain/loan_model.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const initializationSettings = InitializationSettings(
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

  Future<void> scheduleLoanDueReminder(LoanEntity loan) async {
    if (loan.dueDate == null) return;
    
    final scheduledDate = tz.TZDateTime.from(
      loan.dueDate!.subtract(const Duration(days: 1)),
      tz.local,
    ).add(const Duration(hours: 9)); // 9 AM day before

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _notificationsPlugin.zonedSchedule(
      id: loan.uuid.hashCode,
      title: 'Loan due tomorrow 💸',
      body: '৳${loan.amount.toStringAsFixed(0)} ${loan.type.name == "gave" ? "from" : "to"} ${loan.personName} is due tomorrow',
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

  Future<void> showBudgetAlert({
    required String categoryName,
    required double percentage,
  }) async {
    var title = '';
    var body = '';
    
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

  Future<void> cancelLoanReminder(String loanUuid) async {
    await _notificationsPlugin.cancel(id: loanUuid.hashCode);
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
