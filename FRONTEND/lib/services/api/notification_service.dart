import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String channelId = 'channel_id'; // Harus sama dengan main.dart

  static Future<void> initialize() async {
    // Inisialisasi Timezone
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _plugin.initialize(initializationSettings);

    // Buat channel jika belum ada (wajib Android 8+)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      channelId,
      'Basic Notifications',
      description: 'Channel untuk notifikasi pengingat',
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  static Future<void> scheduleDailyReminders(
      List<Map<String, int>> reminderTimes) async {
    await _plugin.cancelAll(); // Bersihkan notifikasi lama

    final now = tz.TZDateTime.now(tz.local);

    for (var reminder in reminderTimes) {
      var scheduledTime = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        reminder['hour']!,
        reminder['minute']!,
      );

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        reminder['hour']! * 100 + reminder['minute']!, // ID unik tiap waktu
        'Pengingat Minum 💧',
        'Saatnya minum air putih sekarang, Bunda!',
        scheduledTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            channelId,
            'Basic Notifications',
            channelDescription: 'Channel untuk notifikasi pengingat',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        androidAllowWhileIdle: true,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    }
  }
}
