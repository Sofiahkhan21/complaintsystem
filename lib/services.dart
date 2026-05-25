import 'dart:math';

import 'package:complaintsystem/screens/admin/admin_dashbord.dart';
import 'package:complaintsystem/screens/admin/complaints.dart';
import 'package:complaintsystem/components/navigation.dart';
import 'package:complaintsystem/screens/authority/authority_complaint.dart';
import 'package:complaintsystem/screens/investigator/investigator_complaints.dart';
import 'package:complaintsystem/screens/users/reminder_notification.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotifcationHelper {
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void requestNotificatinPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      sound: true,
    );
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      if (kDebugMode) {
        print('user gived permission');
      }
    } else {
      if (kDebugMode) {
        print('user denied permission');
      }
    }
  }
//  Future<void> scheduleReminder() async {
 
//     var androidDetails = AndroidNotificationDetails(
//       'channelId',
//       'Reminder',
//       importance: Importance.max,
//       priority: Priority.high,
//     );
//     var iOSDetails = DarwinNotificationDetails();
//     var generalNotificationDetails =
//         NotificationDetails(android: androidDetails, iOS: iOSDetails);

//     // Schedule a notification 5 seconds from now
//      await flutterLocalNotificationsPlugin.zonedSchedule(
//       0,
//       'Reminder',
//       'This is a scheduled reminder!',
//       tz.TZDateTime.now(tz.local).add(Duration(seconds: 5)),  // 5 seconds from now
//       generalNotificationDetails,
//       androidAllowWhileIdle: true,
//       uiLocalNotificationDateInterpretation:
//           UILocalNotificationDateInterpretation.absoluteTime,
//       matchDateTimeComponents: DateTimeComponents.time,
//     );
//   }
  Future<String> gettokenid() async {
    String? token = await messaging.getToken();
    return token!;
  }

  void firebasemegs(BuildContext context) {
    FirebaseMessaging.onMessage.listen((message) {
      print(message.notification!.title);
      print(message.notification!.body);
      localnotify(context, message);
      showNotification(message);
    });
  }

  void localnotify(BuildContext context, RemoteMessage message) async {
    var androidsetting =
        const AndroidInitializationSettings('@drawable/notilogo');
    var initialzationsetting = InitializationSettings(android: androidsetting);

    flutterLocalNotificationsPlugin.initialize(
      initialzationsetting,
      onDidReceiveNotificationResponse: (details) {
        handleMessage(context, message);
      },
    );
  }
void scheduleNotification(int id, String title, DateTime dateTime) {
  tz.initializeTimeZones();
 AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(), 'High importance',
        importance: Importance.max);
  flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    title,
    'Reminder for $title',
    tz.TZDateTime.from(dateTime, tz.local),
    NotificationDetails(
      android: AndroidNotificationDetails(   channel.id.toString(),
       channel.name.toString(),
      importance: Importance.max,
      priority: Priority.high,),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.time, // Can be adjusted for recurrence
  );
}
  Future<void> showNotification(RemoteMessage message) async {
    AndroidNotificationChannel channel = AndroidNotificationChannel(
        Random.secure().nextInt(100000).toString(), 'High importance',
        importance: Importance.max);

    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      channel.id.toString(),
      channel.name.toString(),
      channelDescription: 'abc',
      importance: Importance.high,
      priority: Priority.high,
      styleInformation: BigTextStyleInformation(''),
    );

    NotificationDetails notificationDetails =
        NotificationDetails(android: androidNotificationDetails);

    await flutterLocalNotificationsPlugin.show(0, message.notification!.title,
        message.notification!.body, notificationDetails);
  }

  static Future<void> background(RemoteMessage message) async {
    await Firebase.initializeApp();
    print(
        'this is background notification ${message.notification!.title.toString()}');
  }

  void handleMessage(BuildContext context, RemoteMessage message) {
    if (message.data["id"] != null) {
      if (message.data["id"] == 'new') {
        MyNavigation.push(
            context,
            AuthorityComplaint(
         
            ));
      }
      if(message.data['id']=='investigator'){
         MyNavigation.push(
            context,
            AuthorityComplaint(
         
            ));

      }
      if(message.data['id']=='authority'){
         MyNavigation.push(
            context,
            InvestigatorComplaints(
         
            ));
      }

      if (message.data["data"] == 'reminder') {
        var newRoute = MaterialPageRoute(
            builder: (context) => ReminderNotification(
                  // id: message.data["id"],
                  // name: message.data["username"],
                ));
        Navigator.pushAndRemoveUntil(context, newRoute, (route) => false);
      }
    }
  }

  Future<void> terminatedandback(BuildContext context) async {
    // For terminated state
    RemoteMessage? initialmsg = await messaging.getInitialMessage();

    if (initialmsg != null) {
      handleMessage(context, initialmsg);
    }

    // for background
    FirebaseMessaging.onMessageOpenedApp.listen((msg) {
      handleMessage(context, msg);
    });
  }
}
