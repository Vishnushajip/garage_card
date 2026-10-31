import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import 'package:garage_card/core/firebase/firebase_config.dart';
import 'package:garage_card/core/notifications/push_notification_service.dart';

class FcmNotificationPayload {
  const FcmNotificationPayload({
    required this.title,
    required this.content,
    this.subtitle,
    this.targetTokens = const [],
    this.dataPayload = const {},
    this.recipientUid,
    this.garageId,
    this.deepLink,
    this.type = 'general',
  });

  final String title;
  final String content;
  final String? subtitle;
  final List<String> targetTokens;
  final Map<String, String> dataPayload;
  final String? recipientUid;
  final String? garageId;
  final String? deepLink;
  final String type;

  Map<String, dynamic> buildPayloadBody(String token) {
    return {
      'to': token,
      'priority': 'high',
      'notification': {
        'title': title,
        'body': content,
        'subtitle': subtitle,
        'sound': 'wefix_chime',
      },
      'data': {
        'title': title,
        'body': content,
        'subtitle': subtitle ?? '',
        'deepLink': deepLink ?? '',
        ...dataPayload,
      },
      'webpush': {
        'headers': {'Urgency': 'high'},
        'notification': {
          'title': title,
          'body': content,
          'icon': '/icons/Icon-192.png',
          'click_action': deepLink ?? '/',
        },
      },
    };
  }
}

class FcmNotificationSender {
  FcmNotificationSender._();

  static void send({
    required String title,
    required String content,
    String? subtitle,
    List<String> targetTokens = const [],
    Map<String, String> dataPayload = const {},
    String? recipientUid,
    String? garageId,
    String? deepLink,
    String type = 'general',
  }) {
    unawaited(
      _dispatch(
        FcmNotificationPayload(
          title: title,
          content: content,
          subtitle: subtitle,
          targetTokens: targetTokens,
          dataPayload: dataPayload,
          recipientUid: recipientUid,
          garageId: garageId,
          deepLink: deepLink,
          type: type,
        ),
      ),
    );
  }

  static Future<void> _dispatch(FcmNotificationPayload payload) async {
    try {
      final effectiveTokens = <String>{...payload.targetTokens};
      String? targetUid = payload.recipientUid;

      if (FirebaseConfig.isInitialized) {
        if (targetUid == null && payload.garageId != null) {
          try {
            final garageDoc = await FirebaseFirestore.instance
                .collection('garages')
                .doc(payload.garageId)
                .get();
            if (garageDoc.exists) {
              targetUid = garageDoc.data()?['ownerUid'] as String?;
              final gTokens = garageDoc.data()?['fcmTokens'];
              if (gTokens is List) {
                effectiveTokens.addAll(gTokens.map((e) => e.toString()));
              }
            }
          } catch (_) {}
        }

        if (targetUid != null) {
          try {
            final userDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(targetUid)
                .get();
            if (userDoc.exists) {
              final uTokens = userDoc.data()?['fcmTokens'];
              if (uTokens is List) {
                effectiveTokens.addAll(uTokens.map((e) => e.toString()));
              }
            }
          } catch (_) {}

          final notifId =
              'notif_${DateTime.now().millisecondsSinceEpoch}_${payload.type}';
          final inAppDoc = {
            'id': notifId,
            'recipientUid': targetUid,
            'title': payload.title,
            'body': payload.content,
            'subtitle': payload.subtitle,
            'type': payload.type,
            'deepLink': payload.deepLink,
            'garageId': payload.garageId,
            'isRead': false,
            'data': payload.dataPayload,
            'createdAt': DateTime.now().toIso8601String(),
          };

          try {
            await FirebaseFirestore.instance
                .collection('users')
                .doc(targetUid)
                .collection('notifications')
                .doc(notifId)
                .set(inAppDoc);
          } catch (_) {}
        }
      }

      final tokensList = effectiveTokens
          .where((t) => t.isNotEmpty)
          .take(4)
          .toList();

      for (final token in tokensList) {
        try {
          final bodyJson = payload.buildPayloadBody(token);

          await http
              .post(
                Uri.parse('https://fcm.googleapis.com/fcm/send'),
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(bodyJson),
              )
              .timeout(const Duration(seconds: 4));
        } catch (_) {}
      }

      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null && currentUid == targetUid) {
        final service = PushNotificationService();
        await service.displayLocalNotification(
          RemoteMessage(
            messageId: 'local_${DateTime.now().millisecondsSinceEpoch}',
            data: {
              'title': payload.title,
              'body': payload.content,
              'subtitle': payload.subtitle ?? '',
              'deepLink': payload.deepLink ?? '',
              ...payload.dataPayload,
            },
          ),
        );
      }
    } catch (_) {}
  }
}
