import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/sessions/domain/entities/ping_entity.dart';

class PingModel extends PingEntity {
  const PingModel({
    required super.id,
    required super.sessionId,
    required super.customerId,
    required super.customerName,
    required super.tableNumber,
    required super.timestamp,
    required super.isAcknowledged,
    String? message,
  });

  /// Factory to create a PingModel from a Firestore DocumentSnapshot
  factory PingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return PingModel(
      id: doc.id,
      sessionId: data['sessionId'] as String,
      customerId: data['customerId'] as String,
      customerName: data['customerName'] as String,
      tableNumber: data['tableNumber'] as String,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isAcknowledged: data['isAcknowledged'] as bool,
      message: data['message'] as String?,
    );
  }

  /// Factory to create a PingModel from a domain entity
  factory PingModel.fromEntity(PingEntity entity) {
    return PingModel(
      id: entity.id,
      sessionId: entity.sessionId,
      customerId: entity.customerId,
      customerName: entity.customerName,
      tableNumber: entity.tableNumber,
      timestamp: entity.timestamp,
      isAcknowledged: entity.isAcknowledged,
      message: entity.message,
    );
  }

  /// Converts the model back to a domain entity
  PingEntity toEntity() {
    return PingEntity(
      id: id,
      sessionId: sessionId,
      customerId: customerId,
      customerName: customerName,
      tableNumber: tableNumber,
      timestamp: timestamp,
      isAcknowledged: isAcknowledged,
      message: message,
    );
  }

  /// Converts the model into a Firestore-compatible map
  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'customerId': customerId,
      'customerName': customerName,
      'tableNumber': tableNumber,
      'timestamp': Timestamp.fromDate(timestamp),
      'isAcknowledged': isAcknowledged,
      'message': message,
    };
  }
}
