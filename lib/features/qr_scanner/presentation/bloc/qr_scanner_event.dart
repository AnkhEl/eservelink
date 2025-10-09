import 'package:equatable/equatable.dart';

abstract class QrScannerEvent extends Equatable {
  const QrScannerEvent();

  @override
  List<Object?> get props => [];
}

class RequestCameraPermissionEvent extends QrScannerEvent {}

class QrCodeScannedEvent extends QrScannerEvent {
  final String data;

  const QrCodeScannedEvent(this.data);

  @override
  List<Object?> get props => [data];
}

class ResetScannerEvent extends QrScannerEvent {}
