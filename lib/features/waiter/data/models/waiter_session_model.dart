import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/sessions/data/models/session_model.dart';
import 'package:eservelink/features/sessions/data/models/order_item_model.dart';
import 'package:eservelink/features/sessions/domain/entities/session_entity.dart';
import 'package:eservelink/features/waiter/domain/entities/waiter_session_entity.dart';

class WaiterSessionModel extends SessionModel {
  final bool hasPing;
  final int unreadMessages;

  const WaiterSessionModel({
    required super.id,
    required super.restaurantId,
    super.restaurantName,
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
    this.hasPing = false,
    this.unreadMessages = 0,
  });

  factory WaiterSessionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return WaiterSessionModel(
      id: doc.id,
      restaurantId: data['restaurantId'] ?? '',
      restaurantName: data['restaurantName'] ?? '',
      tableId: data['tableId'] ?? '',
      customerId: data['customerId'] ?? '',
      customerName: data['customerName'] ?? '',
      waiterId: data['waiterId'],
      waiterName: data['waiterName'],
      status: SessionModel.statusFromString(data['status'] ?? 'waitingForWaiter'),
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null ? (data['endTime'] as Timestamp).toDate() : null,
      totalAmount: (data['totalAmount'] ?? 0.0).toDouble(),
      items: (data['items'] as List<dynamic>?)
          ?.map((item) => OrderItemModel.fromMap(item))
          .toList() ??
          [],
      isPaid: data['isPaid'] ?? false,
      canReview: data['canReview'] ?? false,
      lastPingTime: data['lastPingTime'] != null
          ? (data['lastPingTime'] as Timestamp).toDate()
          : null,
      hasPing: data['hasPing'] ?? false,
      unreadMessages: data['unreadMessages'] ?? 0,
    );
  }

  @override
  WaiterSessionEntity toEntity() {
    return WaiterSessionEntity(
      id: id,
      restaurantId: restaurantId,
      restaurantName: restaurantName,
      tableId: tableId,
      customerId: customerId,
      customerName: customerName,
      waiterId: waiterId,
      waiterName: waiterName,
      status: status,
      startTime: startTime,
      endTime: endTime,
      totalAmount: totalAmount,
      items: items,
      isPaid: isPaid,
      canReview: canReview,
      lastPingTime: lastPingTime,
      hasPing: hasPing,
      unreadMessages: unreadMessages,
    );
  }

  @override
  Map<String, dynamic> toFirestore() {
    final base = super.toFirestore();
    return {
      ...base,
      'hasPing': hasPing,
      'unreadMessages': unreadMessages,
    };
  }
}
