import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:mediremind/data/models/drug_model.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._constructor();
  static FlutterLocalNotificationsPlugin? _notificationsPlugin;

  NotificationService._constructor();

  // Initialize the notification service
  Future<void> initialize() async {
    tz.initializeTimeZones();
    _notificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@drawable/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin!.initialize(initSettings);

    // Request permissions for Android 13+ (FIXED)
    await _notificationsPlugin!
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Schedule notification for a drug
  Future<void> scheduleDrugReminder(Drug drug) async {
    if (drug.id == null) return;

    // Cancel existing notifications for this drug first
    await cancelDrugNotifications(drug.id!);

    // Parse time from drug.hour (e.g., "14:30")
    final timeParts = drug.hour.split(':');
    final hour = int.parse(timeParts[0]);
    final minute = int.parse(timeParts[1]);

    // Calculate next notification time
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledTime = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // If time has passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    // Create notification
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_reminders',
      'Medication Reminders',
      channelDescription: 'Reminders for taking medication',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Schedule the notification (FIXED - removed deprecated parameters)
    await _notificationsPlugin!.zonedSchedule(
      drug.id!,
      'Medication Reminder',
      'Time to take ${drug.name} - ${drug.dosage}',
      scheduledTime,
      platformDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: _getRepeatInterval(drug.frequency),
    );
  }

  // Get repeat interval based on frequency
  DateTimeComponents? _getRepeatInterval(String frequency) {
    switch (frequency.toLowerCase()) {
      case 'daily':
      case 'once daily':
        return DateTimeComponents.time; // Repeat daily at same time
      case 'weekly':
        return DateTimeComponents.dayOfWeekAndTime;
      default:
        return DateTimeComponents.time; // Default to daily
    }
  }

  // Cancel notifications for a specific drug
  Future<void> cancelDrugNotifications(int drugId) async {
    await _notificationsPlugin!.cancel(drugId);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin!.cancelAll();
  }

  // Show immediate test notification
  Future<void> showTestNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test',
      'Test Notifications',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin!.show(
      0,
      'Test Notification',
      'Your notifications are working!',
      platformDetails,
    );
  }

  // ADDED: Show immediate test notification for a specific drug
  Future<void> showTestDrugNotification(Drug drug) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'test_drug',
      'Test Drug Notifications',
      channelDescription: 'Test notifications for specific drugs',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      sound: 'default',
    );

    const NotificationDetails platformDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Use a unique ID for test notifications (drug.id + 10000 to avoid conflicts)
    final testNotificationId = (drug.id ?? 0) + 10000;

    await _notificationsPlugin!.show(
      testNotificationId,
      '💊 Medication Reminder (Test)',
      'Time to take ${drug.name} - ${drug.dosage}\nScheduled for: ${drug.hour} • ${drug.frequency}',
      platformDetails,
    );
  }

  // ADDED: Request exact alarm permission (for Android 12+)
  Future<bool> requestExactAlarmPermission() async {
    final androidImplementation = _notificationsPlugin!
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.requestExactAlarmsPermission() ?? false;
    }
    return false;
  }

  // ADDED: Check if exact alarm permission is granted
  Future<bool> isExactAlarmPermissionGranted() async {
    final androidImplementation = _notificationsPlugin!
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      return await androidImplementation.areNotificationsEnabled() ?? false;
    }
    return false;
  }
}