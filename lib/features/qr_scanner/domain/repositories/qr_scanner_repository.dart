import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/qr_scanner/domain/entities/qr_result.dart';

abstract class QrScannerRepository {
  Future<Either<Failure, bool>> requestCameraPermission();
  Future<Either<Failure, QrResult>> scanQrCode();
}
