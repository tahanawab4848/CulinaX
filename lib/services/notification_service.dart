import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    try {
      tz_data.initializeTimeZones();
      const android = AndroidInitializationSettings('@mipmap/ic_launcher');
      const ios = DarwinInitializationSettings();
      await _plugin.initialize(
        const InitializationSettings(android: android, iOS: ios),
      );
      _initialized = true;
    } catch (_) {
      // Notifications may not work on all platforms (e.g. web)
    }
  }

  Future<void> showNow({
    required int id,
    required String title,
    required String body,
  }) async {
    if (!_initialized) return;
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        'culinax',
        'CulinaX',
        channelDescription: 'Pantry and cooking alerts',
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details);
  }

  Future<void> scheduleWeeklyMealReminder() async {
    if (!_initialized) return;
    final scheduled = tz.TZDateTime.now(tz.local).add(const Duration(days: 7));
    await _plugin.zonedSchedule(
      100,
      'Weekly Meal Plan',
      'Plan your desi meals for the week!',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meal_plan',
          'Meal Planner',
          channelDescription: 'Weekly meal reminders',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> notifyExpiringItems(List<String> items) async {
    if (items.isEmpty) return;
    await showNow(
      id: 1,
      title: 'Items Expiring Soon',
      body: items.take(3).join(', ') +
          (items.length > 3 ? ' +${items.length - 3} more' : ''),
    );
  }

  Future<void> notifyCookSuggestion(String recipeName) async {
    await showNow(
      id: 2,
      title: 'Cook This Today!',
      body: 'You can make $recipeName with your pantry.',
    );
  }

  Future<void> notifyLowStock(List<String> items) async {
    if (items.isEmpty) return;
    await showNow(
      id: 3,
      title: 'Low Stock Alert',
      body: 'Restock: ${items.take(3).join(', ')}',
    );
  }
}
