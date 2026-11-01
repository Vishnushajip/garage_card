import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

import '../../firebase_options.dart';
import 'fcm_token_model.dart';
import 'notification_event_matrix.dart';

import 'dart:convert';

import 'web_notification_helper.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) async {
  if (response.actionId == 'chat_reply_action') {
    final replyText = response.input;
    final payload = response.payload;
    if (replyText != null && replyText.trim().isNotEmpty && payload != null) {
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
        }
        await PushNotificationService.executeInlineChatReply(
          payload,
          replyText.trim(),
        );
      } catch (_) {}
    }
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (kIsWeb) return;
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    final service = PushNotificationService();
    await service.initialize();
    await service.displayLocalNotification(message);
  } catch (_) {}
}

class PushNotificationService {
  PushNotificationService({
    this.messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    this.firestore,
    this.auth,
  }) : _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final FirebaseMessaging? messaging;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;

  static const String channelId = 'garage_card_high_importance';
  static const String channelName = 'WeFix Alerts';
  static const String channelDescription =
      'High priority alerts for vehicle service updates, estimates, and invoices.';

  static const String defaultWebVapidKey =
      'BEl62iUYgUivxIkv69yViEuiBIa-Ib9-SkvMeAtA3LFgDzkrxZJjSgSnfckjBJuWiVUfwyH-4wtCL8e3NnDE5hg';

  final StreamController<RemoteMessage> _foregroundMessageController =
      StreamController<RemoteMessage>.broadcast();
  Stream<RemoteMessage> get onForegroundMessage =>
      _foregroundMessageController.stream;

  final StreamController<String> _deepLinkController =
      StreamController<String>.broadcast();
  Stream<String> get onDeepLink => _deepLinkController.stream;

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    _isInitialized = true;

    await _setupLocalNotifications();

    if (messaging == null) return;

    if (!kIsWeb) {
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    }
    await _configureFCMListeners();
    await _checkInitialMessage();
  }

  Future<void> _setupLocalNotifications() async {
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const initSettings = InitializationSettings(android: androidInit);

      await _localNotifications.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse response) async {
              if (response.actionId == 'chat_reply_action') {
                final replyText = response.input;
                final payload = response.payload;
                if (replyText != null &&
                    replyText.trim().isNotEmpty &&
                    payload != null) {
                  await PushNotificationService.executeInlineChatReply(
                    payload,
                    replyText.trim(),
                  );
                }
                return;
              }
              final payload = response.payload;
              if (payload != null && payload.isNotEmpty) {
                _deepLinkController.add(payload);
              }
            },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      if (!kIsWeb) {
        final androidPlugin = _localNotifications
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidPlugin != null) {
          const channel = AndroidNotificationChannel(
            channelId,
            channelName,
            description: channelDescription,
            importance: Importance.max,
            playSound: true,
            sound: RawResourceAndroidNotificationSound('wefix_chime'),
            enableVibration: true,
          );
          await androidPlugin.createNotificationChannel(channel);
        }
      }
    } catch (_) {}
  }

  Future<NotificationSettings?> requestPermission() async {
    if (messaging == null) return null;

    final settings = await messaging!.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (!kIsWeb) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();
      if (androidPlugin != null) {
        await androidPlugin.requestNotificationsPermission();
      }
    }

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      await registerDeviceToken();
    }

    return settings;
  }

  String? _currentToken;
  String? get currentToken => _currentToken;

  Future<void> registerDeviceToken({String? customVapidKey}) async {
    if (messaging == null) return;

    try {
      String? token;
      try {
        token = await messaging!.getToken(
          vapidKey: kIsWeb ? (customVapidKey ?? defaultWebVapidKey) : null,
        );
      } catch (_) {
        if (kIsWeb) {
          try {
            token = await messaging!.getToken();
          } catch (_) {}
        }
      }

      if (token != null && token.isNotEmpty) {
        _currentToken = token;
        await _saveTokenToFirestore(token);
      }

      messaging!.onTokenRefresh.listen((newToken) {
        _currentToken = newToken;
        _saveTokenToFirestore(newToken);
      });
    } catch (_) {}
  }

  Future<void> _saveTokenToFirestore(String token) async {
    if (firestore == null || auth == null) return;
    final user = auth!.currentUser;
    if (user == null) return;

    final tokenModel = FcmTokenModel(
      token: token,
      userId: user.uid,
      platform: kIsWeb ? 'web' : 'android',
      deviceId: '${user.uid}_${kIsWeb ? 'web' : 'android'}',
      updatedAt: DateTime.now(),
      isActive: true,
    );

    try {
      await firestore!
          .collection('users')
          .doc(user.uid)
          .collection('fcmTokens')
          .doc(token)
          .set(tokenModel.toFirestore(), SetOptions(merge: true));

      final userDocRef = firestore!.collection('users').doc(user.uid);
      final snap = await userDocRef.get();
      List<String> tokens = [];
      if (snap.exists &&
          snap.data() != null &&
          snap.data()!['fcmTokens'] is List) {
        tokens = List<String>.from(snap.data()!['fcmTokens'] as List);
      }
      tokens.remove(token);
      tokens.insert(0, token);
      if (tokens.length > 4) {
        tokens = tokens.sublist(0, 4);
      }
      await userDocRef.set({'fcmTokens': tokens}, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> removeDeviceToken() async {
    if (firestore == null || auth == null || messaging == null) return;
    final user = auth!.currentUser;
    if (user == null) return;

    try {
      if (_currentToken != null) {
        await firestore!
            .collection('users')
            .doc(user.uid)
            .collection('fcmTokens')
            .doc(_currentToken!)
            .delete();
      }
      await messaging!.deleteToken();
      _currentToken = null;
    } catch (_) {}
  }

  Future<void> _configureFCMListeners() async {
    if (messaging == null) return;

    await messaging!.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      _foregroundMessageController.add(message);
      await displayLocalNotification(message);
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final deepLink = message.data['deepLink'] as String?;
      if (deepLink != null && deepLink.isNotEmpty) {
        _deepLinkController.add(deepLink);
      }
    });
  }

  Future<void> _checkInitialMessage() async {
    if (messaging == null) return;

    try {
      final initialMessage = await messaging!.getInitialMessage();
      if (initialMessage != null) {
        final deepLink = initialMessage.data['deepLink'] as String?;
        if (deepLink != null && deepLink.isNotEmpty) {
          _deepLinkController.add(deepLink);
        }
      }
    } catch (_) {}
  }

  Future<void> displayLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    final title = notification?.title ?? message.data['title'] ?? 'WeFix';
    final body = notification?.body ?? message.data['body'] ?? '';
    final imageUrl =
        notification?.android?.imageUrl ??
        notification?.apple?.imageUrl ??
        message.data['imageUrl'] as String?;
    final deepLink = message.data['deepLink'] as String? ?? '/';

    if (kIsWeb) {
      showBrowserNotification(
        title: title,
        body: body,
        imageUrl: imageUrl,
        deepLink: deepLink,
      );
      return;
    }

    ByteArrayAndroidBitmap? bigPictureBitmap;
    if (imageUrl != null && imageUrl.isNotEmpty && !kIsWeb) {
      bigPictureBitmap = await _downloadImageBitmap(imageUrl);
    }

    final isChat =
        message.data['type'] == 'chat' ||
        message.data['isChat'] == 'true' ||
        deepLink.startsWith('/chat');

    final androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('wefix_chime'),
      enableVibration: true,
      actions: isChat
          ? [
              const AndroidNotificationAction(
                'chat_reply_action',
                'Reply',
                inputs: [
                  AndroidNotificationActionInput(label: 'Type reply...'),
                ],
                allowGeneratedReplies: true,
              ),
            ]
          : null,
      styleInformation: bigPictureBitmap != null
          ? BigPictureStyleInformation(
              bigPictureBitmap,
              contentTitle: title,
              summaryText: body,
              hideExpandedLargeIcon: false,
            )
          : null,
      largeIcon: bigPictureBitmap,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    final id = message.messageId.hashCode;
    String payload = deepLink;
    if (isChat) {
      final payloadData = {
        'conversationId': message.data['conversationId'] ?? '',
        'senderId': message.data['senderId'] ?? '',
        'senderRole': message.data['senderRole'] ?? 'customer',
        'deepLink': deepLink,
      };
      payload = jsonEncode(payloadData);
    }

    await _localNotifications.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: notificationDetails,
      payload: payload,
    );
  }

  Future<ByteArrayAndroidBitmap?> _downloadImageBitmap(String url) async {
    try {
      final response = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 5));
      if (response.statusCode == 200 && response.bodyBytes.isNotEmpty) {
        return ByteArrayAndroidBitmap(response.bodyBytes);
      }
    } catch (_) {}
    return null;
  }

  static Future<void> executeInlineChatReply(
    String payload,
    String replyText,
  ) async {
    try {
      String conversationId = '';
      String senderRole = 'customer';
      String senderId = '';

      if (payload.startsWith('{')) {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        conversationId = data['conversationId'] as String? ?? '';
        senderId = data['senderId'] as String? ?? '';
        senderRole = data['senderRole'] as String? ?? 'customer';
      } else if (payload.startsWith('/chat/')) {
        conversationId = payload.replaceFirst('/chat/', '');
      }

      if (conversationId.isEmpty) return;

      final currentUid = FirebaseAuth.instance.currentUser?.uid ?? senderId;
      final messageId = DateTime.now().millisecondsSinceEpoch.toString();
      final now = DateTime.now();

      final convRef = FirebaseFirestore.instance
          .collection('conversations')
          .doc(conversationId);
      final msgRef = convRef.collection('messages').doc(messageId);

      final batch = FirebaseFirestore.instance.batch();
      batch.set(msgRef, {
        'conversationId': conversationId,
        'senderId': currentUid,
        'senderRole': senderRole,
        'text': replyText,
        'createdAt': now.toIso8601String(),
        'isRead': false,
      });

      final isCustomer = senderRole == 'customer';
      batch.update(convRef, {
        'lastMessage': replyText,
        'lastMessageTime': now.toIso8601String(),
        'lastSenderId': currentUid,
        if (isCustomer)
          'unreadCountMerchant': FieldValue.increment(1)
        else
          'unreadCountCustomer': FieldValue.increment(1),
      });

      await batch.commit();
    } catch (_) {}
  }

  Future<void> sendDirectFcmNotification({
    required List<String> targetTokens,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    for (final token in targetTokens) {
      if (token.isEmpty) continue;
      try {
        await http.post(
          Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'to': token,
            'notification': {
              'title': title,
              'body': body,
              'sound': 'wefix_chime',
            },
            'data': data ?? {},
          }),
        );
      } catch (_) {}
    }
  }

  Future<void> triggerChatNotification({
    required String recipientUid,
    required String conversationId,
    required String senderName,
    required String messageText,
    required String myUid,
    required String myRole,
  }) async {
    final title = 'New message from $senderName';
    final payloadData = {
      'conversationId': conversationId,
      'senderId': myUid,
      'senderRole': myRole,
      'type': 'chat',
      'isChat': 'true',
      'deepLink': '/chat/$conversationId',
    };

    if (firestore != null) {
      final notifId =
          'chat_${conversationId}_${DateTime.now().millisecondsSinceEpoch}';
      try {
        await firestore!
            .collection('users')
            .doc(recipientUid)
            .collection('notifications')
            .doc(notifId)
            .set({
              'recipientUid': recipientUid,
              'title': title,
              'body': messageText,
              'type': 'chat',
              'referenceId': conversationId,
              'deepLink': '/chat/$conversationId',
              'eventId': notifId,
              'isRead': false,
              'createdAt': DateTime.now().toIso8601String(),
            });

        final userDoc = await firestore!
            .collection('users')
            .doc(recipientUid)
            .get();
        if (userDoc.exists && userDoc.data()?['fcmTokens'] is List) {
          final tokens = List<String>.from(
            userDoc.data()!['fcmTokens'] as List,
          );
          await sendDirectFcmNotification(
            targetTokens: tokens,
            title: title,
            body: messageText,
            data: payloadData,
          );
        }
      } catch (_) {}
    }

    if (auth?.currentUser?.uid == recipientUid) {
      await displayLocalNotification(
        RemoteMessage(
          messageId: 'chat_${DateTime.now().millisecondsSinceEpoch}',
          data: {'title': title, 'body': messageText, ...payloadData},
        ),
      );
    }
  }

  Future<void> triggerEventNotification({
    required NotificationEventType eventType,
    required String recipientUid,
    required String entityId,
    required String qualifier,
    String? title,
    String? body,
    String? customImageUrl,
    String? customDeepLink,
    String? garageId,
  }) async {
    final def = NotificationEventMatrix.definitions[eventType];
    if (def == null) return;

    final resolvedTitle = title ?? def.defaultTitle;
    final resolvedBody = body ?? def.defaultBody;
    final resolvedImage = customImageUrl ?? def.defaultImageUrl;
    final resolvedLink =
        customDeepLink ??
        NotificationEventMatrix.resolveDeepLink(
          type: eventType,
          entityId: entityId,
        );
    final idempotencyKey = NotificationEventMatrix.generateIdempotencyKey(
      type: eventType,
      entityId: entityId,
      qualifier: qualifier,
    );

    final notificationDoc = {
      'recipientUid': recipientUid,
      'title': resolvedTitle,
      'body': resolvedBody,
      'type': eventType.name,
      'referenceId': entityId,
      'imageUrl': resolvedImage,
      'deepLink': resolvedLink,
      'garageId': garageId,
      'eventId': idempotencyKey,
      'isRead': false,
      'createdAt': DateTime.now().toIso8601String(),
    };

    if (firestore != null) {
      try {
        await firestore!
            .collection('users')
            .doc(recipientUid)
            .collection('notifications')
            .doc(idempotencyKey)
            .set(notificationDoc, SetOptions(merge: true));

        final userDoc = await firestore!
            .collection('users')
            .doc(recipientUid)
            .get();
        if (userDoc.exists && userDoc.data()?['fcmTokens'] is List) {
          final tokens = List<String>.from(
            userDoc.data()!['fcmTokens'] as List,
          );
          await sendDirectFcmNotification(
            targetTokens: tokens,
            title: resolvedTitle,
            body: resolvedBody,
            data: {
              'type': eventType.name,
              'referenceId': entityId,
              'deepLink': resolvedLink,
            },
          );
        }
      } catch (_) {}
    }

    if (auth?.currentUser?.uid == recipientUid) {
      await displayLocalNotification(
        RemoteMessage(
          messageId: idempotencyKey,
          data: {
            'title': resolvedTitle,
            'body': resolvedBody,
            'imageUrl': resolvedImage,
            'deepLink': resolvedLink,
            'type': eventType.name,
          },
        ),
      );
    }
  }

  void dispose() {
    _foregroundMessageController.close();
    _deepLinkController.close();
  }
}

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  if (Firebase.apps.isEmpty) {
    return PushNotificationService(
      messaging: null,
      firestore: null,
      auth: null,
    );
  }
  final service = PushNotificationService(
    messaging: FirebaseMessaging.instance,
    firestore: FirebaseFirestore.instance,
    auth: FirebaseAuth.instance,
  );
  ref.onDispose(service.dispose);
  return service;
});
