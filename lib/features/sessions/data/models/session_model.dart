import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:eservelink/features/sessions/data/models/order_item_model.dart';

class SessionModel extends SessionEntity {
  const SessionModel({
    required super.id,
    required super.restaurantId,
    required super.tableId,
    required super.customerId,
    required super.customerName,
    super.waiterId,
    super.waiterName,
    required super.status,
    required super.startTime,
    super.endTime,
    required super.totalAmount,
    required super.items,
    required super.isPaid,
    required super.canReview,
    super.lastPingTime,
  });

  // ✅ CORRECT - Business logic in MODEL, not entity
  bool get isWaitingForWaiter =>
      status == SessionStatus.waitingForWaiter && waiterId == null;

  bool get isActive => status == SessionStatus.active && waiterId != null;

  bool get hasWaiter => waiterId != null;

  bool get canRequestPayment => status == SessionStatus.active && !isPaid;

  bool get canAddItems =>
      status == SessionStatus.active ||
      status == SessionStatus.waitingForWaiter;

  // Convert from Firestore
  factory SessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SessionModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      tableId: data['tableId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      waiterId: data['waiterId'],
      waiterName: data['waiterName'],
      status: _statusFromString(data['status'] ?? 'waitingForWaiter'),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime:
          data['endTime'] != null
              ? (data['endTime'] as Timestamp).toDate()
              : null,
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      items:
          (data['items'] as List<dynamic>?)
              ?.map((item) => OrderItemModel.fromMap(item))
              .toList() ??
          [],
      isPaid: data['isPaid'] ?? false,
      canReview: data['canReview'] ?? false,
      lastPingTime:
          data['lastPingTime'] != null
              ? (data['lastPingTime'] as Timestamp).toDate()
              : null,
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'restaurantId': restaurantId,
      'tableId': tableId,
      'customerId': customerId,
      'customerName': customerName,
      'waiterId': waiterId,
      'waiterName': waiterName,
      'status': _statusToString(status),
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'totalAmount': totalAmount,
      'items':
          items.map((item) => OrderItemModel.fromEntity(item).toMap()).toList(),
      'isPaid': isPaid,
      'canReview': canReview,
      'lastPingTime':
          lastPingTime != null ? Timestamp.fromDate(lastPingTime!) : null,
    };
  }

  // Convert from entity
  factory SessionModel.fromEntity(SessionEntity entity) {
    return SessionModel(
      id: entity.id,
      restaurantId: entity.restaurantId,
      tableId: entity.tableId,
      customerId: entity.customerId,
      customerName: entity.customerName,
      waiterId: entity.waiterId,
      waiterName: entity.waiterName,
      status: entity.status,
      startTime: entity.startTime,
      endTime: entity.endTime,
      totalAmount: entity.totalAmount,
      items: entity.items,
      isPaid: entity.isPaid,
      canReview: entity.canReview,
      lastPingTime: entity.lastPingTime,
    );
  }

  // Helper methods
  static SessionStatus _statusFromString(String status) {
    switch (status) {
      case 'waitingForWaiter':
        return SessionStatus.waitingForWaiter;
      case 'active':
        return SessionStatus.active;
      case 'paymentRequested':
        return SessionStatus.paymentRequested;
      case 'completed':
        return SessionStatus.completed;
      case 'cancelled':
        return SessionStatus.cancelled;
      default:
        return SessionStatus.waitingForWaiter;
    }
  }

  static String _statusToString(SessionStatus status) {
    switch (status) {
      case SessionStatus.waitingForWaiter:
        return 'waitingForWaiter';
      case SessionStatus.active:
        return 'active';
      case SessionStatus.paymentRequested:
        return 'paymentRequested';
      case SessionStatus.completed:
        return 'completed';
      case SessionStatus.cancelled:
        return 'cancelled';
    }
  }
}
