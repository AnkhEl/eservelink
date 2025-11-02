import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/notifications/data/datasources/notification_remote_data_source.dart';
import 'package:eservelink/features/notifications/domain/entities/notification_entity.dart';
import 'package:eservelink/features/notifications/domain/repositories/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;

  NotificationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, NotificationEntity>> createNotification({
    required String userId,
    required NotificationType type,
    required String title,
    required String body,
    required Map<String, dynamic> data,
    String? actionUrl,
  }) async {
    try {
      final notification = await remoteDataSource.createNotification(
        userId: userId,
        type: type,
        title: title,
        body: body,
        data: data,
        actionUrl: actionUrl,
      );
      return Right(notification.toEntity());
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<NotificationEntity>>> streamNotifications({
    required String userId,
  }) {
    try {
      return remoteDataSource
          .streamNotifications(userId: userId)
          .map(
            (models) => Right(models.map((model) => model.toEntity()).toList()),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Stream<Either<Failure, List<NotificationEntity>>> streamUnreadNotifications({
    required String userId,
  }) {
    try {
      return remoteDataSource
          .streamUnreadNotifications(userId: userId)
          .map(
            (models) => Right(models.map((model) => model.toEntity()).toList()),
          );
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString())));
    }
  }

  @override
  Future<Either<Failure, void>> markAsRead({
    required String notificationId,
  }) async {
    try {
      await remoteDataSource.markAsRead(notificationId: notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> markAllAsRead({required String userId}) async {
    try {
      await remoteDataSource.markAllAsRead(userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, int>> getUnreadCount({required String userId}) async {
    try {
      final count = await remoteDataSource.getUnreadCount(userId: userId);
      return Right(count);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteNotification({
    required String notificationId,
  }) async {
    try {
      await remoteDataSource.deleteNotification(notificationId: notificationId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAllNotifications({
    required String userId,
  }) async {
    try {
      await remoteDataSource.deleteAllNotifications(userId: userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
