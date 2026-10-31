import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage_card/core/notifications/fcm_notification_sender.dart';
import 'package:garage_card/features/chat/View/conversation_list_screen.dart';
import 'package:garage_card/features/customer/nearby_garages/Widgets/garage_card_item.dart';
import 'package:garage_card/features/shared/models/conversation_model.dart';
import 'package:garage_card/features/shared/models/garage_model.dart';

void main() {
  group('ConversationModel Phone & Inquiry Tests', () {
    test('serializes and deserializes customerPhone and garagePhone', () {
      final now = DateTime.now();
      final conv = ConversationModel(
        id: 'conv_123',
        customerId: 'cust_abc',
        customerName: 'Rahul Verma',
        customerPhone: '+919876543210',
        garageId: 'gar_xyz',
        garageName: 'Apex Auto Care',
        garagePhone: '+919811122233',
        serviceJobTitle: 'Full Service Package',
        lastMessage: 'Hi, I would like to inquire about this service',
        lastSenderId: 'cust_abc',
        lastMessageTime: now,
        unreadCountCustomer: 0,
        unreadCountMerchant: 1,
        createdAt: now,
      );

      final map = conv.toFirestore();
      expect(map['customerPhone'], '+919876543210');
      expect(map['garagePhone'], '+919811122233');

      final fromMap = ConversationModel.fromFirestore(map, 'conv_123');
      expect(fromMap.customerPhone, '+919876543210');
      expect(fromMap.garagePhone, '+919811122233');
      expect(fromMap.customerName, 'Rahul Verma');
      expect(fromMap.garageName, 'Apex Auto Care');

      final updated = conv.copyWith(customerPhone: '+919999988888');
      expect(updated.customerPhone, '+919999988888');
      expect(updated.garagePhone, '+919811122233');
    });
  });

  group('FCM Notification Sender Payload Tests', () {
    test('builds correct high-priority FCM payload with android and webpush config', () {
      const payload = FcmNotificationPayload(
        title: 'New Service Inquiry',
        content: 'Inquiring about Periodic Service. Contact: +919876543210',
        subtitle: 'Tap to reply',
        deepLink: '/chat/conv_123?name=Rahul&phone=+919876543210',
        dataPayload: {
          'customerPhone': '+919876543210',
          'conversationId': 'conv_123',
        },
      );

      final body = payload.buildPayloadBody('token_device_abc');
      expect(body['to'], 'token_device_abc');
      expect(body['priority'], 'high');

      final notification = body['notification'] as Map<String, dynamic>;
      expect(notification['title'], 'New Service Inquiry');
      expect(
        notification['body'],
        'Inquiring about Periodic Service. Contact: +919876543210',
      );

      final webpush = body['webpush'] as Map<String, dynamic>;
      expect(webpush['notification']['title'], 'New Service Inquiry');
      expect(
        webpush['notification']['click_action'],
        '/chat/conv_123?name=Rahul&phone=+919876543210',
      );

      final data = body['data'] as Map<String, dynamic>;
      expect(data['customerPhone'], '+919876543210');
      expect(data['conversationId'], 'conv_123');
    });
  });

  group('GarageCardItem Action Buttons & Responsive Tests', () {
    testWidgets(
      'renders all non-basic action pills and featured package banner',
      (tester) async {
        final garage = GarageModel(
          id: 'gar_test_1',
          name: 'AutoTech Masters',
          address: '123 Marine Drive',
          phone: '+919876543210',
          email: 'info@autotech.com',
          city: 'Kochi',
          ownerUid: 'owner_test',
          servicesOffered: const ['Periodic Service', 'Wheel Alignment'],
        );

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: SingleChildScrollView(
                  child: GarageCardItem(
                    garage: garage,
                    userLat: 9.9312,
                    userLon: 76.2673,
                    onTap: () {},
                    onRequestService: () {},
                  ),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('AutoTech Masters'), findsOneWidget);
        expect(find.text('FEATURED'), findsOneWidget);
        expect(find.text('Periodic Service'), findsOneWidget);
        expect(find.text('Directions'), findsOneWidget);
        expect(find.text('Call'), findsOneWidget);
        expect(find.text('WhatsApp'), findsOneWidget);
        expect(find.text('Chat'), findsOneWidget);
        expect(find.text('View Packages & Book Service'), findsOneWidget);
      },
    );
  });

  group('ConversationListScreen Responsive Layout Tests', () {
    testWidgets('renders single pane list on mobile width (< 768px)', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: ConversationListScreen())),
      );

      await tester.pumpAndSettle();

      expect(find.text('Messages'), findsOneWidget);
      expect(find.byType(VerticalDivider), findsNothing);
    });

    testWidgets(
      'renders master-detail two-pane layout on desktop/tablet width (>= 768px)',
      (tester) async {
        tester.view.physicalSize = const Size(1024, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);

        await tester.pumpWidget(
          const ProviderScope(
            child: MaterialApp(home: ConversationListScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Messages'), findsOneWidget);
        expect(find.byType(VerticalDivider), findsOneWidget);
      },
    );
  });
}
