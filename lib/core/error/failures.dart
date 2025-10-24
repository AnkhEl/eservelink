abstract class Failure {
  final String message;
  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server Failure']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache Failure']);
}

class UnexpectedFailure extends Failure {
  const UnexpectedFailure([super.message = 'Unexpected Failure']);
}

class PermissionFailure extends Failure {
  const PermissionFailure([super.message = 'Unexpected Failure']);
}

class LocationFailure extends Failure {
  const LocationFailure(super.message);
}

class ReviewNotFoundFailure extends Failure {
  const ReviewNotFoundFailure() : super('Review not found');
}

class NoReviewsFoundFailure extends Failure {
  const NoReviewsFoundFailure() : super('No reviews found for this restaurant');
}

class ReviewFetchFailure extends Failure {
  const ReviewFetchFailure(super.message);
}

class ReviewCreateFailure extends Failure {
  const ReviewCreateFailure(super.message);
}

class ReviewUpdateFailure extends Failure {
  const ReviewUpdateFailure(super.message);
}

class ReviewDeleteFailure extends Failure {
  const ReviewDeleteFailure(super.message);
}

class SessionFailure extends Failure {
  const SessionFailure(super.message);
}

class TableNotFoundFailure extends Failure {
  const TableNotFoundFailure() : super('Table not found');
}

class TableOccupiedFailure extends Failure {
  const TableOccupiedFailure() : super('This table is currently occupied');
}

class SessionNotFoundFailure extends Failure {
  const SessionNotFoundFailure() : super('Session not found');
}

class NoActiveSessionFailure extends Failure {
  const NoActiveSessionFailure() : super('No active session found');
}

class InvalidQrCodeFailure extends Failure {
  const InvalidQrCodeFailure() : super('Invalid QR code');
}

class SessionAlreadyActiveFailure extends Failure {
  const SessionAlreadyActiveFailure()
    : super('You already have an active session');
}

class UnauthorizedSessionAccessFailure extends Failure {
  const UnauthorizedSessionAccessFailure()
    : super('Unauthorized access to this session');
}

class PingFailure extends Failure {
  const PingFailure(super.message);
}

class ChatFailure extends Failure {
  const ChatFailure(super.message);
}
