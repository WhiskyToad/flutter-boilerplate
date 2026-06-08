import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:skelter/presentation/reminder/model/reminder_model.dart';
import 'package:skelter/widgets/styling/app_colors.dart';

class NotificationService {
  NotificationService._();

  final basicChannel = 'basic_channel';
  final basicChannelName = 'Basic notifications';
  final basicChannelDescription =
      'Notification channel for basic notifications';
  final basicChannelSound = 'resource://raw/basic';
  final reminderChannel = 'reminder_channel';
  final reminderChannelName = 'Reminders';
  final reminderChannelDescription = 'Notification channel for reminders';
  final reminderChannelSound = 'resource://raw/reminder';
  final appIcon = 'resource://drawable/ic_notification';
  final defaultNotificationTitle = 'New Notification';
  final defaultNotificationBody = '';

  static final NotificationService instance = NotificationService._();
  final AwesomeNotifications _awesomeNotifications = AwesomeNotifications();

  final _onNotificationTapController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get onNotificationTap =>
      _onNotificationTapController.stream;

  Map<String, dynamic>? get initialNotificationPayload => null;

  Future<void> initialize() async {
    await _initializeAwesomeNotifications();
    await _requestPermissions();
  }

  Future<void> _initializeAwesomeNotifications() async {
    await _awesomeNotifications.initialize(appIcon, [
      NotificationChannel(
        channelKey: basicChannel,
        channelName: basicChannelName,
        channelDescription: basicChannelDescription,
        ledColor: AppColors.white,
        defaultColor: AppColors.brand500,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        playSound: true,
        soundSource: basicChannelSound,
        enableVibration: true,
      ),
      NotificationChannel(
        channelKey: reminderChannel,
        channelName: reminderChannelName,
        channelDescription: reminderChannelDescription,
        ledColor: AppColors.white,
        defaultColor: AppColors.brand500,
        importance: NotificationImportance.High,
        channelShowBadge: true,
        playSound: true,
        soundSource: reminderChannelSound,
        enableVibration: true,
      ),
    ], debug: kDebugMode);

    await _awesomeNotifications.setListeners(
      onActionReceivedMethod: _onActionReceivedMethod,
      onNotificationCreatedMethod: _onNotificationCreatedMethod,
      onNotificationDisplayedMethod: _onNotificationDisplayedMethod,
      onDismissActionReceivedMethod: _onDismissActionReceivedMethod,
    );
  }

  Future<void> _requestPermissions() async {
    final isAllowed = await _awesomeNotifications.isNotificationAllowed();
    if (!isAllowed) {
      await _awesomeNotifications.requestPermissionToSendNotifications();
    }
  }

  Future<void> showNotification({
    Map<String, dynamic>? data,
    String? imageUrl,
    String? title,
    String? body,
  }) async {
    final notificationId =
        (data?['notification_id']?.toString().hashCode ??
            DateTime.now().millisecondsSinceEpoch) &
        0x7FFFFFFF;

    await _awesomeNotifications.createNotification(
      content: NotificationContent(
        id: notificationId,
        channelKey: basicChannel,
        title: title ?? defaultNotificationTitle,
        body: body ?? defaultNotificationBody,
        payload: data?.cast(),
        bigPicture: imageUrl,
        notificationLayout: imageUrl != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        wakeUpScreen: true,
        category: NotificationCategory.Message,
      ),
    );
  }

  @pragma('vm:entry-point')
  static Future<void> _onNotificationCreatedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> _onNotificationDisplayedMethod(
    ReceivedNotification receivedNotification,
  ) async {}

  @pragma('vm:entry-point')
  static Future<void> _onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    final payloadMap = receivedAction.payload ?? {};
    instance._onNotificationTapController.add(payloadMap);
  }

  @pragma('vm:entry-point')
  static Future<void> _onDismissActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {}

  Future<bool> scheduleReminder(ReminderModel reminder) async {
    try {
      final notificationId = reminder.id.toString().hashCode & 0x7FFFFFFF;

      await _awesomeNotifications.createNotification(
        content: NotificationContent(
          id: notificationId,
          channelKey: reminderChannel,
          title: reminder.title,
          body: reminder.description,
          wakeUpScreen: true,
          category: NotificationCategory.Reminder,
          autoDismissible: false,
        ),
        schedule: NotificationCalendar.fromDate(
          date: reminder.scheduledDateTime,
          allowWhileIdle: true,
          preciseAlarm: true,
        ),
      );
      return true;
    } catch (e) {
      debugPrint('Error scheduling reminder: $e');
      return false;
    }
  }

  void dispose() {
    _onNotificationTapController.close();
  }
}
