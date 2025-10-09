import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:eservelink/core/usecases/usecase.dart';
import 'package:eservelink/features/qr_scanner/domain/entities/qr_result.dart';
import 'package:eservelink/features/qr_scanner/domain/repositories/qr_scanner_repository.dart';

class ScanQrCode implements UseCase<QrResult, NoParams> {
  final QrScannerRepository repository;

  ScanQrCode(this.repository);

  @override
  Future<Either<Failure, QrResult>> call(NoParams params) async {
    return await repository.scanQrCode();
  }
}
