import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/features/qr_scanner/domain/entities/qr_result.dart';
import 'package:eservelink/features/qr_scanner/domain/repositories/qr_scanner_repository.dart';
import 'package:permission_handler/permission_handler.dart';

class QrScannerRepositoryImpl implements QrScannerRepository {
  @override
  Future<Either<Failure, bool>> requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return Right(status.isGranted);
    } catch (e) {
      return Left(PermissionFailure('Failed to request camera permission'));
    }
  }

  @override
  Future<Either<Failure, QrResult>> scanQrCode() async {
    // This will be handled by the UI navigation
    // Repository just validates permission
    final permissionResult = await requestCameraPermission();
    return permissionResult.fold((failure) => Left(failure), (granted) {
      if (!granted) {
        return Left(PermissionFailure('Camera permission denied'));
      }
      // Return a placeholder - actual scanning happens in UI
      return Right(QrResult(data: '', scannedAt: DateTime.now()));
    });
  }
}
