import 'package:equatable/equatable.dart';
import 'package:eservelink/features/qr_scanner/domain/entities/qr_result.dart';

abstract class QrScannerState extends Equatable {
  const QrScannerState();

  @override
  List<Object?> get props => [];
}

class QrScannerInitial extends QrScannerState {}

class QrScannerLoading extends QrScannerState {}

class QrScannerPermissionGranted extends QrScannerState {}

class QrScannerPermissionDenied extends QrScannerState {
  final String message;

  const QrScannerPermissionDenied(this.message);

  @override
  List<Object?> get props => [message];
}

class QrScannerSuccess extends QrScannerState {
  final QrResult result;

  const QrScannerSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class QrScannerError extends QrScannerState {
  final String message;

  const QrScannerError(this.message);

  @override
  List<Object?> get props => [message];
}
