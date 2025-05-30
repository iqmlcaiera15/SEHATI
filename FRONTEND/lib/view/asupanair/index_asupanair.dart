import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:Sehati/services/api/api_services_asupanair.dart';
import 'package:Sehati/view/asupanair/notifications_asupanair.dart';
import 'package:Sehati/view/asupanair/reminder.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:intl/date_symbol_data_local.dart';


final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

class AsupanAirPage extends StatefulWidget {
  const AsupanAirPage({super.key});

  @override
  State<AsupanAirPage> createState() => _AsupanAirPageState();
}

class _AsupanAirPageState extends State<AsupanAirPage> {
  List<int> dailyGelas = List.filled(7, 0);
  List<DateTime> oneWeekDates = [];
  int gelasHariIni = 0;
  bool isReminderOn = true;
  late Reminder reminder;

  List<Map<String, int>> reminderTimes = [];

@override
void initState() {
  super.initState();
  initializeDateFormatting('id_ID', null).then((_) {
    generateOneWeekDates();
    loadFromLocal();
    fetchData();
    loadCustomReminders();
    loadReminderPreference();
    syncPendingMinum();
    _initializeNotifications();
  });
}


  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  void dispose() {
    reminder.stop();
    super.dispose();
  }

  void generateOneWeekDates() {
    oneWeekDates = List.generate(7, (i) =>
        DateTime.now().subtract(Duration(days: 6 - i)));
  }

  Future<void> loadFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      gelasHariIni = prefs.getInt('gelasHariIni') ?? 0;
    });
  }

  Future<void> saveToLocal(int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('gelasHariIni', value);
  }

  Future<void> saveReminderPreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isReminderOn', value);
  }

  Future<void> loadReminderPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isReminderOn = prefs.getBool('isReminderOn') ?? true;
    });

    if (isReminderOn && reminderTimes.isNotEmpty) {
      reminder = Reminder(
        reminderTimes: reminderTimes,
        onReminder: () => NotificationAsupanAir.showReminderSnackbar(context),
      );
      reminder.start();
      _scheduleReminders();
    }
  }

  Future<void> _scheduleReminders() async {
    await flutterLocalNotificationsPlugin.cancelAll();
    
    for (final time in reminderTimes) {
      final now = DateTime.now();
      var scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        time['hour']!,
        time['minute']!,
      );
      
      // Jika waktu sudah lewat hari ini, jadwalkan untuk besok
      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }
      
      await flutterLocalNotificationsPlugin.zonedSchedule(
        time['hour']! * 100 + time['minute']!, // ID unik berdasarkan jam dan menit
        'Waktunya minum air!',
        'Jangan lupa minum air untuk menjaga kesehatan Anda dan bayi',
        tz.TZDateTime.from(scheduledTime, tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'water_reminder',
            'Pengingat Minum Air',
            channelDescription: 'Pengingat untuk minum air secara teratur',
            importance: Importance.high,
            priority: Priority.high,
            sound: RawResourceAndroidNotificationSound('slow_spring_board'),
          ),
        ),
        androidAllowWhileIdle: true,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> saveCustomReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stringList = reminderTimes.map((e) => '${e['hour']}:${e['minute']}').toList();
    await prefs.setStringList('customReminders', stringList);
  }

Future<void> loadCustomReminders() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String> stringList = prefs.getStringList('customReminders') ?? [];

  if (stringList.isEmpty) {
    stringList.addAll([
      '06:30',
      '09:00',
      '11:00',
      '13:30',
      '15:30',
      '17:30',
      '19:30',
      '21:00',
    ]);
    await prefs.setStringList('customReminders', stringList);
  }

  setState(() {
    reminderTimes = stringList.map((str) {
      final parts = str.split(':');
      return {'hour': int.parse(parts[0]), 'minute': int.parse(parts[1])};
    }).toList();
  });
}

void showReminderDialog() {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Jadwal Minum Air'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3.8,
            children: reminderTimes.map((t) {
              final time = TimeOfDay(hour: t['hour']!, minute: t['minute']!);
              return Container(
                decoration: BoxDecoration(
                  color: Colors.pink.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.pinkAccent),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        children: [
                          const Icon(Icons.alarm, color: Colors.redAccent, size: 18),
                          const SizedBox(width: 6),
                          Text(time.format(context), style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        setState(() {
                          reminderTimes.remove(t);
                        });
                        await saveCustomReminders();
                        if (isReminderOn) {
                          reminder.stop();
                          reminder = Reminder(
                            reminderTimes: reminderTimes,
                            onReminder: () => NotificationAsupanAir.showReminderSnackbar(context),
                          );
                          reminder.start();
                          _scheduleReminders();
                        }
                        Navigator.pop(context);
                        showReminderDialog(); // buka ulang biar UI update
                      },
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.add_alarm),
            label: const Text('Tambah Waktu'),
            onPressed: () async {
              TimeOfDay? picked = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (picked != null) {
                final newTime = {'hour': picked.hour, 'minute': picked.minute};
                final isDuplicate = reminderTimes.any((t) =>
                    t['hour'] == newTime['hour'] && t['minute'] == newTime['minute']);
                if (!isDuplicate) {
                  setState(() {
                    reminderTimes.add(newTime);
                  });
                  await saveCustomReminders();
                  if (isReminderOn) {
                    reminder.stop();
                    reminder = Reminder(
                      reminderTimes: reminderTimes,
                      onReminder: () => NotificationAsupanAir.showReminderSnackbar(context),
                    );
                    reminder.start();
                    _scheduleReminders();
                  }
                }
                Navigator.pop(context);
                showReminderDialog(); // buka ulang dialog setelah tambah
              }
            },
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      );
    },
  );
}



  Future<void> simpanPendingMinum() async {
    final prefs = await SharedPreferences.getInstance();
    int pending = prefs.getInt('pendingMinum') ?? 0;
    pending += 1;
    await prefs.setInt('pendingMinum', pending);
    _updateSetelahMinum();
  }

  Future<void> syncPendingMinum() async {
    final prefs = await SharedPreferences.getInstance();
    int pending = prefs.getInt('pendingMinum') ?? 0;

    if (pending > 0) {
      int berhasil = 0;

      for (int i = 0; i < pending; i++) {
        try {
          final response = await ApiServiceAsupanAir.tambahMinum();
          if (response['success']) {
            berhasil++;
          }
        } catch (_) {
          break;
        }
      }

      if (berhasil > 0) {
        await prefs.setInt('pendingMinum', pending - berhasil);
        fetchData();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$berhasil data pending berhasil disinkronkan'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  Future<void> fetchData() async {
    try {
      final response = await ApiServiceAsupanAir.getTotalDanRiwayat();
      if (response['success']) {
        List<dynamic> history = response['history'];
        List<int> gelasList = List.generate(7, (i) {
          final target = oneWeekDates[i];
          final item = history.firstWhere(
            (h) {
              try {
                final tgl = DateTime.parse(h['tanggal']);
                return tgl.year == target.year &&
                    tgl.month == target.month &&
                    tgl.day == target.day;
              } catch (_) {
                return false;
              }
            },
            orElse: () => {'jumlah_ml': 0},
          );
          final jumlah = int.tryParse(item['jumlah_ml'].toString()) ?? 0;
          return (jumlah / 250).floor();
        });

        final now = DateTime.now();
        final todayIndex = oneWeekDates.indexWhere((d) =>
            d.year == now.year && d.month == now.month && d.day == now.day);

        setState(() {
          dailyGelas = gelasList;
          gelasHariIni = todayIndex != -1 ? gelasList[todayIndex] : 0;
        });

        await saveToLocal(gelasHariIni);
      }
    } catch (e) {
      debugPrint('❌ fetchData error: $e');
      await loadFromLocal();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sedang offline. Menampilkan data lokal.'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> tambahGelasHariIni() async {
  if (gelasHariIni >= 8) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎯 Target Tercapai!'),
        content: const Text(
          'Bunda sudah mencapai target 8 gelas hari ini. Lanjutkan kebiasaan baik ini ya!',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Oke'),
          ),
        ],
      ),
    );
    return;
  }

    try {
      final response = await ApiServiceAsupanAir.tambahMinum();

      if (response['success']) {
        _updateSetelahMinum();
      }
    } catch (e) {
      await simpanPendingMinum();
      NotificationAsupanAir.showErrorSnackbar(context);
    }
  }

  void _updateSetelahMinum() {
    final now = DateTime.now();
    final todayIndex = oneWeekDates.indexWhere((d) =>
        d.year == now.year && d.month == now.month && d.day == now.day);

    if (todayIndex != -1) {
      setState(() {
        gelasHariIni++;
        dailyGelas[todayIndex] = gelasHariIni;
      });
    }

    saveToLocal(gelasHariIni);

    if (gelasHariIni == 8) {
      NotificationAsupanAir.showTargetDialog(context);
    }
  }

  int get totalML => gelasHariIni * 250;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final todayText = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(today);
    final rangeText =
        "${DateFormat('dd MMM', 'id_ID').format(oneWeekDates.first)} - ${DateFormat('dd MMM', 'id_ID').format(oneWeekDates.last)}";

    void showReminderModal() {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (context) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.pinkAccent),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Jadwal Pengingat',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3.5,
              children: reminderTimes.map((t) {
                final time = TimeOfDay(hour: t['hour']!, minute: t['minute']!);
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.pinkAccent),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 10),
                        child: Row(
                          children: [
                            const Icon(Icons.alarm, color: Colors.redAccent, size: 18),
                            const SizedBox(width: 6),
                            Text(time.format(context), style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          setState(() {
                            reminderTimes.remove(t);
                          });
                          await saveCustomReminders();
                          if (isReminderOn) {
                            reminder.stop();
                            reminder = Reminder(
                              reminderTimes: reminderTimes,
                              onReminder: () => NotificationAsupanAir.showReminderSnackbar(context),
                            );
                            reminder.start();
                            _scheduleReminders();
                          }
                        },
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.alarm_add, color: Colors.white),
              label: const Text('Tambah Jam Pengingat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (picked != null) {
                  final newTime = {'hour': picked.hour, 'minute': picked.minute};
                  final isDuplicate = reminderTimes.any((t) =>
                      t['hour'] == newTime['hour'] &&
                      t['minute'] == newTime['minute']);
                  if (isDuplicate) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${picked.format(context)} sudah ada.'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                    return;
                  }

                  setState(() {
                    reminderTimes.add(newTime);
                  });

                  await saveCustomReminders();

                  if (isReminderOn) {
                    reminder.stop();
                    reminder = Reminder(
                      reminderTimes: reminderTimes,
                      onReminder: () => NotificationAsupanAir.showReminderSnackbar(context),
                    );
                    reminder.start();
                    _scheduleReminders();
                  }
                }
              },
            ),
          ],
        ),
      );
    },
  );
}


    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFE0E0E0))),
            ),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Hidrasi Harian',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    setState(() => generateOneWeekDates());
                    fetchData();
                    syncPendingMinum();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  const Text('Tetap jaga hidrasi sepanjang hari',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text(
                    'Lacak kecukupan konsumsi air minum harian bunda di sini yuk',
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: showReminderDialog,
                        child: const Text(
                          'Atur Jadwal Minum',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Text('Pengingat Minum'),
                          const SizedBox(width: 8),
                          Switch(
                            value: isReminderOn,
                            activeColor: Color.fromARGB(255, 255, 164, 195),
                            onChanged: (val) async {
                              setState(() => isReminderOn = val);
                              await saveReminderPreference(val);
                              if (val && reminderTimes.isNotEmpty) {
                                reminder = Reminder(
                                  reminderTimes: reminderTimes,
                                  onReminder: () => NotificationAsupanAir.showReminderSnackbar(context),
                                );
                                reminder.start();
                                _scheduleReminders();
                              } else {
                                reminder.stop();
                                await flutterLocalNotificationsPlugin.cancelAll();
                              }
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.lightBlue),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('$totalML ml / 2000 ml'),
                            Text(todayText,
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        GestureDetector(
                          onTap: tambahGelasHariIni,
                          child: const Icon(Icons.water_drop_rounded,
                              size: 64, color: Colors.blueAccent),
                        ),
                        const SizedBox(height: 8),
                        const Text('Tap untuk mencatat konsumsi hari ini'),
                        const SizedBox(height: 4),
                        const Text('⚠️ 1 gelas = 250 ml',
                            style: TextStyle(
                                fontSize: 12, color: Colors.black54)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Riwayat Minum Bunda',
                                style: TextStyle(fontWeight: FontWeight.w600)),
                            Text(rangeText,
                                style: const TextStyle(color: Colors.black54)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 260,
                          child: BarChart(
                            BarChartData(
                              maxY: 8,
                              gridData: FlGridData(show: true),
                              borderData: FlBorderData(show: false),
                              barGroups: List.generate(dailyGelas.length,
                                  (index) {
                                return BarChartGroupData(
                                  x: index,
                                  barRods: [
                                    BarChartRodData(
                                      toY: dailyGelas[index].toDouble(),
                                      width: 20,
                                      color: Colors.lightBlue,
                                      borderRadius: BorderRadius.circular(6),
                                      backDrawRodData:
                                          BackgroundBarChartRodData(
                                        show: true,
                                        toY: 8,
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      interval: 1),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, _) {
                                      int index = value.toInt();
                                      if (index < 0 ||
                                          index >= oneWeekDates.length) {
                                        return const SizedBox();
                                      }
                                      return Text(
                                        DateFormat('dd/MM')
                                            .format(oneWeekDates[index]),
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                topTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                                rightTitles: AxisTitles(
                                    sideTitles: SideTitles(showTitles: false)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    margin: const EdgeInsets.only(top: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F5),
                      border: Border.all(color: const Color(0xFFFC5C9C)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Catatan',
                            style: TextStyle(
                                color: Color(0xFFFC5C9C),
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 12),
                        _NoteItem(
                            text:
                                'Minum minimal 8 gelas air (250 ml per gelas) hari ini, ya Bunda!'),
                        SizedBox(height: 8),
                        _NoteItem(
                            text:
                                'Tambah asupan jika cuaca panas atau aktivitas padat.'),
                        SizedBox(height: 8),
                        _NoteItem(
                            text:
                                'Pusing, lelah, atau urine pekat bisa jadi tanda kurang cairan.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoteItem extends StatelessWidget {
  final String text;
  const _NoteItem({required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle, color: Colors.blue, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}