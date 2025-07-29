// import 'dart:async';
// import 'dart:convert';
// import 'dart:io';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:get/get.dart';
// import 'package:go_router/go_router.dart';
// import 'package:litchies/shared/constant/app_functions.dart';
// import 'package:path_provider/path_provider.dart';

// import '../../features/dashboard/api/dashboard_services.dart';
// import '../../main.dart';
// import '../../routes/app_pages.dart';
// import '../../routes/app_routes.dart';
// import 'common_service.dart';

// class NotificationService {
//   static final NotificationService _singleton = NotificationService._internal();
//   final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();

//   factory NotificationService() => _singleton;

//   static String? notificationNavigation;

//   NotificationService._internal() {
//     _initialize();
//   }

//   void _initialize() async {
//     // Initialize TZDateTime

//     const AndroidInitializationSettings initializationSettingsAndroid =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     const InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: initializationSettingsAndroid,
//       iOS: DarwinInitializationSettings(),
//     );
//     _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (details) {
//         // Extract the payload from the notification details
//         String? payload = details.payload;
//         print('Payload: $payload');

//         if (payload != null) {
//           // Parse the payload as JSON or handle as a simple string
//           Map<String, dynamic> data = jsonDecode(payload);

//           // Navigate based on the data received in the notification
//           if (data.containsKey("shop")) {
//             rootNavigatorKey.currentContext!
//                 .push("${AppRoutes.shopProfile}/${data["shop"]}");
//           } else if (data.containsKey("product")) {
//             rootNavigatorKey.currentContext!
//                 .push("${AppRoutes.productDetails}/${data["product"]}");
//           } else if (data.containsKey("offer")) {
//             rootNavigatorKey.currentContext!
//                 .push("${AppRoutes.couponScreen}/${data["offer"]}");
//           } else if (data.containsKey("redeemstatus")) {
//             rootNavigatorKey.currentContext!.push(AppRoutes.myPoints);
//           }
//         }
//       },
//     );
//     FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true,
//       badge: true,
//       sound: true,
//     );

//     FirebaseMessaging.instance.getToken().then((token) {
//       print('Token: $token');
//       try {
//         DashboardService().updateDeviceToken(token!);
//       } catch (e) {
//         print(e);
//       }
//     });
//     FirebaseMessaging.instance
//         .subscribeToTopic("allusers")
//         .catchError((err) {});

//     // Set the background messaging handler early on, as a named top-level function
//     FirebaseMessaging.onBackgroundMessage(backgroundHandler);

//     // Set the message handler to handle messages in the foreground
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       print('Received message');
//       print(message.notification?.title);
//       print(message.notification?.body);
//       // print(message)
//       if (message.notification?.title == null ||
//           message.notification?.body == null) {
//         return;
//       }
//       print(message.data);
//       print("Android :- ${message.notification?.android?.sound}");
//       print("IOS :- ${message.notification?.apple?.sound?.name}");
//       if (message.data.containsKey('redeemstatus')) {
//         AppFunctions.isOfferClaimed.value = true;
//       }

//       displayNotification(
//         0,
//         message.notification?.title ?? '',
//         message.notification?.body ?? '',
//         message.data,
//         img: GetPlatform.isAndroid
//             ? message.notification?.android?.imageUrl
//             : message.notification?.apple?.imageUrl,
//         sound: GetPlatform.isAndroid
//             ? message.notification?.android?.sound ??
//                 "litchies_notification_sound"
//             : message.notification?.apple?.sound?.name ??
//                 "litchies_notification_sound",
//       );
//     });

//     final NotificationAppLaunchDetails? notificationAppLaunchDetails =
//         await _flutterLocalNotificationsPlugin
//             .getNotificationAppLaunchDetails();

//     if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
//       Map<String, dynamic> data = jsonDecode(
//           notificationAppLaunchDetails?.notificationResponse?.payload ??
//               ""); // Parse the payload as JSON

//       if (data.containsKey("shop")) {
//         notificationNavigation = "${AppRoutes.shopProfile}/${data["shop"]}";
//       } else if (data.containsKey("product")) {
//         notificationNavigation =
//             "${AppRoutes.productDetails}/${data["product"]}";
//       } else if (data.containsKey("offer")) {
//         notificationNavigation = "${AppRoutes.couponScreen}/${data["offer"]}";
//       } else if (data.containsKey("redeemstatus")) {
//         notificationNavigation = AppRoutes.myPoints;
//       }
//       print(" Nav path :- $notificationNavigation");
//     }

//     // Set the message handler to handle messages in the background

//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       print('Received message in background');
//       print(message.notification?.title);
//       print(message.notification?.body);

//       if (message.data.containsKey("shop")) {
//         print(rootNavigatorKey.currentContext!);
//         rootNavigatorKey.currentContext!
//             .push("${AppRoutes.shopProfile}/${message.data["shop"]}");
//       } else if (message.data.containsKey("product")) {
//         rootNavigatorKey.currentContext!
//             .push("${AppRoutes.productDetails}/${message.data["product"]}");
//       }
//       if (message.data.containsKey("offer")) {
//         rootNavigatorKey.currentContext!
//             .push("${AppRoutes.couponScreen}/${message.data["offer"]}");
//       }
//       if (message.data.containsKey("redeemstatus")) {
//         rootNavigatorKey.currentContext!.push(AppRoutes.myPoints);
//       }
//     });

//     // Set the message handler to handle messages in the terminated app state

//     FirebaseMessaging.instance
//         .getInitialMessage()
//         .then((RemoteMessage? message) {
//       if (message != null) {
//         print('Received message in terminated app state');
//         print(message.notification?.title);
//         print(message.notification?.body);
//         if (message.notification?.title == null ||
//             message.notification?.body == null) {
//           return;
//         }

//         if (message.data.containsKey("shop")) {
//           notificationNavigation =
//               "${AppRoutes.shopProfile}/${message.data["shop"]}";
//         } else if (message.data.containsKey("product")) {
//           notificationNavigation =
//               "${AppRoutes.productDetails}/${message.data["product"]}";
//         } else if (message.data.containsKey("offer")) {
//           notificationNavigation =
//               "${AppRoutes.couponScreen}/${message.data["offer"]}";
//         } else if (message.data.containsKey("redeemstatus")) {
//           notificationNavigation = AppRoutes.myPoints;
//         }
//         // displayNotification(
//         //   0,
//         //   message.notification?.title ?? '',
//         //   message.notification?.body ?? '',
//         //   message.data,
//         //   img: GetPlatform.isAndroid
//         //       ? message.notification?.android?.imageUrl
//         //       : message.notification?.apple?.imageUrl,
//         //   sound: GetPlatform.isAndroid
//         //       ? message.notification?.android?.sound ??
//         //           "litchies_notification_sound"
//         //       : message.notification?.apple?.sound?.name ??
//         //           "litchies_notification_sound",
//         // );
//       }
//     });

//     // Request permission for notification

//     FirebaseMessaging.instance.requestPermission(
//       sound: true,
//       badge: true,
//       alert: true,
//       provisional: false,
//     );
//   }

//   Future<void> handleNotification(RemoteMessage message) async {
//     // Handle notification here
//     print('Received notification');
//     print(message.notification?.title);
//     print(message.notification?.body);
//     print(message.data);

//     if (message.notification?.title == null ||
//         message.notification?.body == null) {
//       return;
//     }

//     displayNotification(
//       0,
//       message.notification?.title ?? '',
//       message.notification?.body ?? '',
//       message.data,
//       img: GetPlatform.isAndroid
//           ? message.notification?.android?.imageUrl
//           : message.notification?.apple?.imageUrl,
//       sound: GetPlatform.isAndroid
//           ? message.notification?.android?.sound ??
//               "litchies_notification_sound"
//           : message.notification?.apple?.sound?.name ??
//               "litchies_notification_sound",
//     );
//   }

//   Future<String> _saveFile(List<int> data, String fileName) async {
//     final directory = await getTemporaryDirectory();
//     final filePath = '${directory.path}/$fileName';
//     final file = File(filePath);
//     await file.writeAsBytes(data);
//     return filePath;
//   }

//   // display notification
//   Future<void> displayNotification(
//     int id,
//     String title,
//     String body,
//     dynamic payload, {
//     String? img,
//     String sound = "litchies_notification_sound",
//   }) async {
//     if (sound.toLowerCase() == "default") {
//       sound = "litchies_notification_sound";
//     }
//     print("Sound :- $sound");
//     BigPictureStyleInformation? bigPictureStyleInformation;
//     String filePath = '';

//     // Handle image for Android
//     if (img != null && img.isURL) {
//       try {
//         final value = await CommonService.to.getImage(img);
//         filePath = await _saveFile(value.data, 'notification_image.jpg');
//         bigPictureStyleInformation = BigPictureStyleInformation(
//           ByteArrayAndroidBitmap.fromBase64String(base64Encode(value.data)),
//           largeIcon:
//               ByteArrayAndroidBitmap.fromBase64String(base64Encode(value.data)),
//           contentTitle: title,
//           summaryText: body,
//         );
//       } catch (e) {
//         print('Error loading image for notification: $e');
//       }
//     }

//     String channelId = 'litchies';
//     String channelName = 'Litchies';

//     if (sound == "litchies_notification_sound") {
//       channelId = 'litchies';
//       channelName = 'Litchies';
//     } else if (sound == "coins") {
//       channelId = 'litchiesCoins';
//       channelName = 'Litchies Coins';
//     }
//     // Android-specific notification details
//     AndroidNotificationDetails androidPlatformChannelSpecifics =
//         AndroidNotificationDetails(
//       channelId, channelName,
//       channelDescription: 'Litchies notifications', // Channel description
//       importance: Importance.max,
//       priority: Priority.high,
//       styleInformation: bigPictureStyleInformation,
//       sound: RawResourceAndroidNotificationSound(sound), // Custom sound
//       largeIcon: bigPictureStyleInformation?.largeIcon,
//     );

//     // iOS-specific notification details
//     DarwinNotificationDetails iosPlatformChannelSpecifics =
//         DarwinNotificationDetails(
//       attachments: img != null
//           ? [
//               DarwinNotificationAttachment(filePath),
//             ]
//           : null,
//       sound: sound,
//     );

//     NotificationDetails platformChannelSpecifics = NotificationDetails(
//       android: androidPlatformChannelSpecifics,
//       iOS: iosPlatformChannelSpecifics,
//     );

//     // Show the notification
//     await _flutterLocalNotificationsPlugin.show(
//       id,
//       title,
//       body,
//       platformChannelSpecifics,
//       payload: jsonEncode(payload),
//     );
//   }
// }
