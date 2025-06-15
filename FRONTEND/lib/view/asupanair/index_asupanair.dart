import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';



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
  late Reminder reminder = Reminder(reminderTimes: [], onReminder: () {});

  List<Map<String, int>> reminderTimes = [];

@override
void initState() {
  super.initState();
  initializeDateFormatting('id_ID', null).then((_) async {
    generateOneWeekDates();
    await loadFromLocal();
    await fetchData();
    await loadCustomReminders();
    await loadReminderPreference();
    await syncPendingMinum();
    await _setupNotificationsAndPermission(); // ← Tambahkan ini!
  });
}

Future<void> _setupNotificationsAndPermission() async {
  await _initializeNotifications();
  await requestNotificationPermission();
  // ...kalau mau: bisa tambahkan scheduleReminders dsb. di sini
}


Future<void> requestNotificationPermission() async {
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
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
    oneWeekDates = List.generate(
      7,
      (i) => DateTime.now().subtract(Duration(days: 6 - i)),
    );
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

      if (scheduledTime.isBefore(now)) {
        scheduledTime = scheduledTime.add(const Duration(days: 1));
      }

      await flutterLocalNotificationsPlugin.zonedSchedule(
        time['hour']! * 100 + time['minute']!,
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
            // sound: RawResourceAndroidNotificationSound('slow_spring_board'), // HAPUS baris ini
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  Future<void> saveCustomReminders() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stringList =
        reminderTimes.map((e) => '${e['hour']}:${e['minute']}').toList();
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('Jadwal Minum Air',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 17)),
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
                            Icon(Icons.alarm,
                                color: Colors.redAccent, size: 18),
                            SizedBox(width: 6),
                            Text(time.format(context),
                                style: GoogleFonts.poppins(fontSize: 14)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          setState(() {
                            reminderTimes.remove(t);
                          });
                          await saveCustomReminders();
                          if (isReminderOn) {
                            reminder.stop();
                            reminder = Reminder(
                              reminderTimes: reminderTimes,
                              onReminder: () =>
                                  NotificationAsupanAir.showReminderSnackbar(
                                      context),
                            );
                            reminder.start();
                            _scheduleReminders();
                          }
                          Navigator.pop(context);
                          showReminderDialog();
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
              icon: Icon(Icons.add_alarm),
              label: Text('Tambah Waktu',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 15)),
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
                      onReminder: () =>
                          NotificationAsupanAir.showReminderSnackbar(context),
                    );
                    reminder.start();
                    _scheduleReminders();
                  }
                }
                Navigator.pop(context);
                showReminderDialog();
              },
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Tutup',
                  style:
                      GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 15)),
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
        SnackBar(
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text('🎯 Target Tercapai!',
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w600, fontSize: 18)),
          content: Text(
            'Bunda sudah mencapai target 8 gelas hari ini. Lanjutkan kebiasaan baik ini ya!',
            style: GoogleFonts.poppins(fontSize: 15),
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Oke',
                  style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600, fontSize: 15)),
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

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFD),
      body: SafeArea(
        child: Column(
          children: [
            // Custom AppBar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x2034aaf4),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: Color(0xFF2277b6)),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'Hidrasi Harian',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w700,
                      fontSize: 21,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Color(0xFF2277b6)),
                    onPressed: () {
                      setState(() {
                        generateOneWeekDates();
                        loadFromLocal();
                        fetchData();
                      });
                    },
                  ),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Header
                    Text(
                      'Tetap jaga hidrasi sepanjang hari',
                      style: GoogleFonts.poppins(
                          fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Lacak kecukupan konsumsi air minum harian bunda di sini yuk',
                      style: GoogleFonts.poppins(
                          fontSize: 13, color: Colors.black54),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 16),

                    // Kartu Utama
                    Container(
                      padding: const EdgeInsets.all(24),
                      margin: const EdgeInsets.symmetric(vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.lightBlueAccent.withOpacity(0.14),
                            blurRadius: 18,
                            offset: const Offset(0, 7),
                          ),
                        ],
                        border: Border.all(
                          color:
                              Colors.lightBlueAccent.withOpacity(0.17),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('$totalML ml / 2000 ml',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15)),
                              Text(todayText,
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: Colors.black38)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: tambahGelasHariIni,
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.lightBlue.shade50,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blueAccent
                                          .withOpacity(0.09),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.all(12),
                                  child: Icon(Icons.water_drop_rounded,
                                      size: 64,
                                      color: Colors.blueAccent),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text('Tap untuk tambah konsumsi hari ini',
                              style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w500)),
                          const SizedBox(height: 3),
                          Text('1 gelas = 250 ml',
                              style: GoogleFonts.poppins(
                                  fontSize: 12, color: Colors.black54)),
                        ],
                      ),
                    ),

                    // Reminder row (text link only)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: showReminderDialog,
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 6, horizontal: 2),
                              child: Text(
                                'Atur Jadwal Minum',
                                style: GoogleFonts.poppins(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Text('Pengingat',
                                  style: GoogleFonts.poppins(fontSize: 13)),
                              const SizedBox(width: 8),
                              Switch(
                                value: isReminderOn,
                                activeColor: Colors.blueAccent,
                                onChanged: (val) async {
                                  setState(() => isReminderOn = val);
                                  await saveReminderPreference(val);
                                  if (val) {
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
                    ),

                    const SizedBox(height: 20),

                    // Bar Chart modern
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.08),
                            blurRadius: 11,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                            color: Colors.lightBlueAccent.withOpacity(0.13)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Riwayat Minum Bunda',
                                  style: GoogleFonts.poppins(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15)),
                              Text(rangeText,
                                  style: GoogleFonts.poppins(
                                      color: Colors.blueGrey,
                                      fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          SizedBox(
                            height: 180,
                            child: BarChart(
                              BarChartData(
                                maxY: 8,
                                gridData: FlGridData(show: true),
                                borderData: FlBorderData(show: false),
                                barGroups: List.generate(
                                  7,
                                  (index) => BarChartGroupData(
                                    x: index,
                                    barRods: [
                                      BarChartRodData(
                                        toY: dailyGelas[index].toDouble(),
                                        width: 20,
                                        color: Colors.lightBlueAccent,
                                        borderRadius:
                                            BorderRadius.circular(6),
                                        backDrawRodData:
                                            BackgroundBarChartRodData(
                                          show: true,
                                          toY: 8,
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                titlesData: FlTitlesData(
                                  leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 36,
                                          interval: 1,
                                          getTitlesWidget: (v, meta) =>
                                              Text(
                                                v.toStringAsFixed(0),
                                                style:
                                                    GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  color: Colors.blueGrey,
                                                ),
                                              ))),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, _) {
                                        int index = value.toInt();
                                        if (index < 0 ||
                                            index >=
                                                oneWeekDates.length) {
                                          return const SizedBox();
                                        }
                                        return Text(
                                          DateFormat('dd/MM').format(
                                              oneWeekDates[index]),
                                          style: GoogleFonts.poppins(
                                              fontSize: 11,
                                              color: Colors.black87),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                  rightTitles: AxisTitles(
                                      sideTitles:
                                          SideTitles(showTitles: false)),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Note
                    Container(
                      margin:
                          const EdgeInsets.only(top: 22, bottom: 20),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blueGrey.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                        border: Border.all(
                            color: Colors.blueAccent.withOpacity(0.18)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Catatan Penting',
                              style: GoogleFonts.poppins(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15)),
                          const SizedBox(height: 13),
                          _NoteItem(
                              text:
                                  'Minum minimal 8 gelas air (250 ml per gelas) hari ini, ya Bunda!'),
                          const SizedBox(height: 8),
                          _NoteItem(
                              text:
                                  'Tambah asupan jika cuaca panas atau aktivitas padat.'),
                          const SizedBox(height: 8),
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
        const Icon(Icons.check_circle, color: Colors.blueAccent, size: 19),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
