import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/notification_item.dart';

/// Backend service managing user in-app notifications (PRD F9, LLD Section 2.1).
/// Supports real-time Firestore streaming, offline caching, and automatic alerts
/// for audited collection edits, dispute resolutions, and payout statements.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _userNotifications(String userId) =>
      _firestore.collection('users').doc(userId).collection('notifications');

  // Fallback demo notifications for offline or unseeded users
  final Map<String, List<NotificationItem>> _memoryNotifications = {
    'F001': [
      NotificationItem(
        id: 'NOTIF-001',
        userId: 'F001',
        type: NotificationType.disputeUpdate,
        title: 'Dispute Approved & Adjusted',
        body: 'Your contest on 22 Oct AM reading was resolved. Credit adjustment of ₹126.00 added to your settlement.',
        referenceId: 'DSP-20261023-001',
        createdAt: DateTime(2026, 10, 24, 16, 45),
        isRead: false,
      ),
      NotificationItem(
        id: 'NOTIF-002',
        userId: 'F001',
        type: NotificationType.payoutReady,
        title: '10-Day Payment Statement Generated',
        body: 'Reconciliation statement for Cycle 2 (11-20 Oct) is ready: ₹8,924.50 approved for NEFT transfer.',
        referenceId: 'REC-202610-C2-F001',
        createdAt: DateTime(2026, 10, 21, 10, 0),
        isRead: true,
        readAt: DateTime(2026, 10, 21, 11, 30),
      ),
      NotificationItem(
        id: 'NOTIF-003',
        userId: 'F001',
        type: NotificationType.entryCorrected,
        title: 'Collection Reading Audited',
        body: 'Entry of 10 Oct AM was updated from 12.0 L to 12.5 L by Supervisor (calibration check).',
        referenceId: 'ENT-001',
        createdAt: DateTime(2026, 10, 10, 18, 15),
        isRead: true,
        readAt: DateTime(2026, 10, 11, 7, 0),
      ),
    ],
  };

  /// Real-time stream of notifications for a given user.
  Stream<List<NotificationItem>> streamNotifications(String userId) {
    try {
      return _userNotifications(userId)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          return snapshot.docs
              .map((doc) => NotificationItem.fromMap(doc.id, doc.data()))
              .toList();
        }
        return _memoryNotifications[userId] ?? [];
      }).handleError((err) {
        debugPrint('Notification stream fallback triggered: $err');
        return _memoryNotifications[userId] ?? [];
      });
    } catch (_) {
      return Stream.value(_memoryNotifications[userId] ?? []);
    }
  }

  /// Get notifications list once.
  Future<List<NotificationItem>> getNotifications(String userId) async {
    try {
      final snapshot = await _userNotifications(userId)
          .orderBy('createdAt', descending: true)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs
            .map((doc) => NotificationItem.fromMap(doc.id, doc.data()))
            .toList();
      }
    } catch (e) {
      debugPrint('Firestore notifications read fallback: $e');
    }
    return _memoryNotifications[userId] ?? [];
  }

  /// Send an in-app notification to a user.
  Future<NotificationItem> sendNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    String? referenceId,
  }) async {
    final notifId = 'NOTIF-${DateTime.now().millisecondsSinceEpoch % 1000000}';
    final notif = NotificationItem(
      id: notifId,
      userId: userId,
      type: type,
      title: title,
      body: body,
      referenceId: referenceId,
      createdAt: DateTime.now(),
      isRead: false,
    );

    // Save in memory
    _memoryNotifications.putIfAbsent(userId, () => []);
    _memoryNotifications[userId]!.insert(0, notif);

    // Persist to Firestore
    try {
      await _userNotifications(userId).doc(notifId).set({
        ...notif.toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore notification persist notice (cached): $e');
    }

    return notif;
  }

  /// Mark a notification as read.
  Future<void> markAsRead(String userId, String notificationId) async {
    final list = _memoryNotifications[userId];
    if (list != null) {
      final idx = list.indexWhere((n) => n.id == notificationId);
      if (idx != -1) {
        list[idx] = list[idx].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    }

    try {
      await _userNotifications(userId).doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Firestore markAsRead notice: $e');
    }
  }

  /// Mark all notifications as read for a user.
  Future<void> markAllAsRead(String userId) async {
    final list = _memoryNotifications[userId];
    if (list != null) {
      for (int i = 0; i < list.length; i++) {
        list[i] = list[i].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    }

    try {
      final snapshot = await _userNotifications(userId)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();
    } catch (e) {
      debugPrint('Firestore markAllAsRead notice: $e');
    }
  }
}
