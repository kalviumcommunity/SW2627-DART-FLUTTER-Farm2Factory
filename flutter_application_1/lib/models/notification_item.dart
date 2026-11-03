import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  entryCorrected,
  disputeUpdate,
  payoutReady,
  qcAlert,
  general,
}

class NotificationItem {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final String? referenceId;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;

  const NotificationItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.referenceId,
    required this.createdAt,
    this.readAt,
    this.isRead = false,
  });

  NotificationItem copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    String? referenceId,
    DateTime? createdAt,
    DateTime? readAt,
    bool? isRead,
  }) {
    return NotificationItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      referenceId: referenceId ?? this.referenceId,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'type': type.name,
      'title': title,
      'body': body,
      'referenceId': referenceId,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
      'isRead': isRead,
    };
  }

  factory NotificationItem.fromMap(String id, Map<String, dynamic> map) {
    NotificationType parseType(String? val) {
      switch (val) {
        case 'entryCorrected':
        case 'entry_corrected':
          return NotificationType.entryCorrected;
        case 'disputeUpdate':
        case 'dispute_update':
          return NotificationType.disputeUpdate;
        case 'payoutReady':
        case 'payout_ready':
          return NotificationType.payoutReady;
        case 'qcAlert':
        case 'qc_alert':
          return NotificationType.qcAlert;
        default:
          return NotificationType.general;
      }
    }

    DateTime parseDate(dynamic val) {
      if (val is Timestamp) return val.toDate();
      if (val is DateTime) return val;
      if (val is String) return DateTime.tryParse(val) ?? DateTime.now();
      return DateTime.now();
    }

    return NotificationItem(
      id: id,
      userId: (map['userId'] as String?) ?? '',
      type: parseType(map['type'] as String?),
      title: (map['title'] as String?) ?? 'Notification',
      body: (map['body'] as String?) ?? '',
      referenceId: map['referenceId'] as String?,
      createdAt: parseDate(map['createdAt']),
      readAt: map['readAt'] != null ? parseDate(map['readAt']) : null,
      isRead: (map['isRead'] as bool?) ?? (map['readAt'] != null),
    );
  }
}
