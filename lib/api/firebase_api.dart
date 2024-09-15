import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:papapreco/service/navigator_service.dart';
import 'package:papapreco/service/notification_service.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.notification?.body}");
}

class FirebaseApi {
  final _firebaseMessaging = FirebaseMessaging.instance;

  Future<void> initNotifications() async {
    await _firebaseMessaging.requestPermission();

    final fCMToken = await _firebaseMessaging.getToken();
    print('fCM Token: $fCMToken');

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


    /********************************************************************/


    /*FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      // lidar com a mensagem quando o app está em primeiro plano
      print("Received a message while in the foreground: ${message.notification?.body}");
      // mostrar um alerta ou uma notificação local
    });*/

     // Configure o canal de notificações para Android
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // Id do canal
      'High Importance Notifications', // Nome do canal
      description: 'This channel is used for important notifications.', // Descrição
      importance: Importance.high,
    );

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Received a message while in the foreground: ${message.notification?.body}");

      if (message.notification != null) {
        flutterLocalNotificationsPlugin.show(
          message.hashCode,
          message.notification!.title,
          message.notification!.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              channel.id,
              channel.name,
              channelDescription: channel.description,
              importance: Importance.high,
              priority: Priority.high,
            ),
          ),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // lidar com a notificação quando o app está em segundo plano ou fechado
      if (message.data.containsKey('page')) {
        final page = message.data['page'];
        final palavra = message.data['palavra'];
        //Navigator.pushNamed(navigatorKey.currentContext!, '/$page');
        Navigator.pushNamed(
              navigatorKey.currentContext!, '/$page',
              arguments: <String, Object>{"palavra": palavra});
      }
    });

    //ERRO TELA BRANCA?
    /*FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      // lidar com a notificação quando o app é iniciado pelo clique
      if (message != null && message.data.containsKey('page')) {
        final page = message.data['page'];
        final palavra = message.data['palavra'];
        //Navigator.pushNamed(navigatorKey.currentContext!, '/$page');
        Navigator.pushNamed(
              navigatorKey.currentContext!, '/$page',
              arguments: <String, Object>{"palavra": palavra});
      }
    });*/
  }
}