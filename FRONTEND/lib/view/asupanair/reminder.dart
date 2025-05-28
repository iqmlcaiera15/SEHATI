import 'dart:async';

typedef ReminderCallback = void Function();

class Reminder {
  final List<Map<String, int>> reminderTimes;
  final ReminderCallback onReminder;
  Timer? _timer;

  Reminder({required this.reminderTimes, required this.onReminder});

  void start() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      final now = DateTime.now();
      for (var time in reminderTimes) {
        if (now.hour == time['hour'] && now.minute == time['minute']) {
          onReminder();
          break;
        }
      }
    });
  }

  void stop() {
    _timer?.cancel();
  }
}
