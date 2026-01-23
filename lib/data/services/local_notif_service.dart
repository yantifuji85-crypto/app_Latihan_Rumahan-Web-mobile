import 'dart:math';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifService {
  LocalNotifService._();
  static final LocalNotifService I = LocalNotifService._();

  final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  bool _inited = false;

  // ANDROID CHANNEL
  static const String _channelId = "workout_reminder";
  static const String _channelName = "Workout Reminder";
  static const String _channelDesc = "Pengingat ajakan latihan harian";

  // ================= INIT =================
  Future<void> init() async {
    if (_inited) return;

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(settings);

    // ANDROID CHANNEL (WAJIB)
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    _inited = true;
  }

  // ================= PERMISSION =================
  Future<bool> requestPermissionIfNeeded() async {
    await init();

    // iOS permission
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final ok = await ios.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return ok ?? false;
    }

    // Android 13+ permission
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final ok = await android.requestNotificationsPermission();
      return ok ?? true; // android <13 biasanya true
    }

    return true;
  }

  // ================= DETAILS =================
  NotificationDetails _details() {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
    );

    const ios = DarwinNotificationDetails();
    return const NotificationDetails(android: android, iOS: ios);
  }

  // ================= TEST NOTIF =================
  Future<void> showTest() async {
    await init();

    await _plugin.show(
      1001,
      "🔥 Ayo latihan!",
      _pickMessage(),
      _details(),
    );
  }

  // ================= DAILY SIMPLE =================
  /// Notif harian simpel (tanpa timezone)
  /// ✅ PAKAI INEXACT biar gak butuh izin "Exact alarm"
  Future<void> scheduleDailySimple() async {
    await init();

    try {
      await _plugin.periodicallyShow(
        2001,
        "💪 Waktunya latihan!",
        _pickMessage(),
        RepeatInterval.daily,
        _details(),
        androidScheduleMode: AndroidScheduleMode.inexact, // ✅ FIX UTAMA
      );
    } catch (_) {
      // Kalau device tertentu masih rewel, minimal gak bikin app crash
      // (notif test tetap bisa dipakai buat buktiin aktif)
    }
  }

  // ================= CANCEL =================
  Future<void> cancelAll() async {
    await init();
    await _plugin.cancelAll();
  }

  // ================= MESSAGE =================
  String _pickMessage() {
    const options = [
      "Cuma 5 menit hari ini juga cukup. Gas sekarang 💥",
      "Biar konsisten, 1 latihan aja dulu. Yang penting jalan 🔥",
      "Push-up dikit, squat dikit — badan lo besok berterima kasih 😤",
      "Target mingguan nggak kejar sendiri bro. Ayo sikat 1 sesi 💪",
      "Mood jelek? Latihan dulu. Habis itu biasanya lebih enak 😎",
      "Main HP boleh, tapi jangan lupa: 10 menit latihan juga bisa 😁",
      "Gak perlu sempurna, yang penting konsisten. Mulai sekarang ✨",
      "Latihan singkat > gak latihan sama sekali. Ayo mulai 🏁",
    ];
    return options[Random().nextInt(options.length)];
  }
}
