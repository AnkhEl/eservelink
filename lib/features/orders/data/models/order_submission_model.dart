import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eservelink/features/orders/domain/entities/order_submission_entity.dart';
import 'package:eservelink/features/sessions/data/models/order_item_model.dart';
import 'package:eservelink/features/sessions/domain/entities/order_item.dart';

class OrderSubmissionModel extends OrderSubmissionEntity {
  const OrderSubmissionModel({
    required super.id,
    required super.sessionId,
    required super.customerId,
    required super.customerName,
    required super.waiterId,
    required super.waiterName,
    required super.restaurantId,
    required super.items,
    required super.subtotal,
    required super.tax,
    required super.total,
    required super.status,
    required super.submittedAt,
    super.confirmedAt,
    super.preparingAt,
    super.servedAt,
    super.notes,
  });

  /// Calculate totals (subtotal, tax, total) from items
  /// Tax rate is 15% (configurable)
  static Map<String, double> calculateTotals(
    List<OrderItem> items, {
    double taxRate = 0.15,
  }) {
    final subtotal = items.fold<double>(
      0,
      (double sum, item) => sum + item.subtotal,
    );
    final tax = subtotal * taxRate;
    final total = subtotal + tax;

    return {'subtotal': subtotal, 'tax': tax, 'total': total};
  }

  /// Create from Firestore
  factory OrderSubmissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return OrderSubmissionModel(
      id: doc.id,
      sessionId: data['sessionId'] as String,
      customerId: data['customerId'] as String,
      customerName: data['customerName'] as String,
      waiterId: data['waiterId'] as String,
      waiterName: data['waiterName'] as String,
      restaurantId: data['restaurantId'] as String,
      items:
          (data['items'] as List<dynamic>)
              .map(
                (item) => OrderItemModel.fromMap(item as Map<String, dynamic>),
              )
              .toList(),
      subtotal: (data['subtotal'] as num).toDouble(),
      tax: (data['tax'] as num).toDouble(),
      total: (data['total'] as num).toDouble(),
      status: _statusFromString(data['status'] as String),
      submittedAt: (data['submittedAt'] as Timestamp).toDate(),
      confirmedAt:
          data['confirmedAt'] != null
              ? (data['confirmedAt'] as Timestamp).toDate()
              : null,
      preparingAt:
          data['preparingAt'] != null
              ? (data['preparingAt'] as Timestamp).toDate()
              : null,
      servedAt:
          data['servedAt'] != null
              ? (data['servedAt'] as Timestamp).toDate()
              : null,
      notes: data['notes'] as String?,
    );
  }

  /// Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'sessionId': sessionId,
      'customerId': customerId,
      'customerName': customerName,
      'waiterId': waiterId,
      'waiterName': waiterName,
      'restaurantId': restaurantId,
      'items':
          items.map((item) => OrderItemModel.fromEntity(item).toMap()).toList(),
      'subtotal': subtotal,
      'tax': tax,
      'total': total,
      'status': _statusToString(status),
      'submittedAt': Timestamp.fromDate(submittedAt),
      'confirmedAt':
          confirmedAt != null ? Timestamp.fromDate(confirmedAt!) : null,
      'preparingAt':
          preparingAt != null ? Timestamp.fromDate(preparingAt!) : null,
      'servedAt': servedAt != null ? Timestamp.fromDate(servedAt!) : null,
      'notes': notes,
    };
  }

  /// Convert to entity
  OrderSubmissionEntity toEntity() {
    return OrderSubmissionEntity(
      id: id,
      sessionId: sessionId,
      customerId: customerId,
      customerName: customerName,
      waiterId: waiterId,
      waiterName: waiterName,
      restaurantId: restaurantId,
      items: items,
      subtotal: subtotal,
      tax: tax,
      total: total,
      status: status,
      submittedAt: submittedAt,
      confirmedAt: confirmedAt,
      preparingAt: preparingAt,
      servedAt: servedAt,
      notes: notes,
    );
  }

  /// Create from entity
  factory OrderSubmissionModel.fromEntity(OrderSubmissionEntity entity) {
    return OrderSubmissionModel(
      id: entity.id,
      sessionId: entity.sessionId,
      customerId: entity.customerId,
      customerName: entity.customerName,
      waiterId: entity.waiterId,
      waiterName: entity.waiterName,
      restaurantId: entity.restaurantId,
      items: entity.items,
      subtotal: entity.subtotal,
      tax: entity.tax,
      total: entity.total,
      status: entity.status,
      submittedAt: entity.submittedAt,
      confirmedAt: entity.confirmedAt,
      preparingAt: entity.preparingAt,
      servedAt: entity.servedAt,
      notes: entity.notes,
    );
  }

  /// CopyWith
  OrderSubmissionModel copyWith({
    String? id,
    String? sessionId,
    String? customerId,
    String? customerName,
    String? waiterId,
    String? waiterName,
    String? restaurantId,
    List<OrderItem>? items,
    double? subtotal,
    double? tax,
    double? total,
    OrderSubmissionStatus? status,
    DateTime? submittedAt,
    DateTime? confirmedAt,
    DateTime? preparingAt,
    DateTime? servedAt,
    String? notes,
  }) {
    return OrderSubmissionModel(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      waiterId: waiterId ?? this.waiterId,
      waiterName: waiterName ?? this.waiterName,
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
      subtotal: subtotal ?? this.subtotal,
      tax: tax ?? this.tax,
      total: total ?? this.total,
      status: status ?? this.status,
      submittedAt: submittedAt ?? this.submittedAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      preparingAt: preparingAt ?? this.preparingAt,
      servedAt: servedAt ?? this.servedAt,
      notes: notes ?? this.notes,
    );
  }

  /// Status conversion helpers
  static OrderSubmissionStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return OrderSubmissionStatus.pending;
      case 'confirmed':
        return OrderSubmissionStatus.confirmed;
      case 'preparing':
        return OrderSubmissionStatus.preparing;
      case 'served':
        return OrderSubmissionStatus.served;
      case 'cancelled':
        return OrderSubmissionStatus.cancelled;
      default:
        return OrderSubmissionStatus.pending;
    }
  }

  static String _statusToString(OrderSubmissionStatus status) {
    switch (status) {
      case OrderSubmissionStatus.pending:
        return 'pending';
      case OrderSubmissionStatus.confirmed:
        return 'confirmed';
      case OrderSubmissionStatus.preparing:
        return 'preparing';
      case OrderSubmissionStatus.served:
        return 'served';
      case OrderSubmissionStatus.cancelled:
        return 'cancelled';
    }
  }
}
