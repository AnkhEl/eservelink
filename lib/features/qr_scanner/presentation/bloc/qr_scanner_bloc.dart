import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:eservelink/features/qr_scanner/domain/entities/qr_result.dart';
import 'package:eservelink/features/qr_scanner/domain/repositories/qr_scanner_repository.dart';
import 'package:eservelink/features/qr_scanner/presentation/bloc/qr_scanner_event.dart';
import 'package:eservelink/features/qr_scanner/presentation/bloc/qr_scanner_state.dart';

class QrScannerBloc extends Bloc<QrScannerEvent, QrScannerState> {
  final QrScannerRepository repository;

  QrScannerBloc({required this.repository}) : super(QrScannerInitial()) {
    on<RequestCameraPermissionEvent>(_onRequestCameraPermission);
    on<QrCodeScannedEvent>(_onQrCodeScanned);
    on<ResetScannerEvent>(_onResetScanner);
  }

  Future<void> _onRequestCameraPermission(
    RequestCameraPermissionEvent event,
    Emitter<QrScannerState> emit,
  ) async {
    emit(QrScannerLoading());
    final result = await repository.requestCameraPermission();
    result.fold((failure) => emit(QrScannerPermissionDenied(failure.message)), (
      granted,
    ) {
      if (granted) {
        emit(QrScannerPermissionGranted());
      } else {
        emit(const QrScannerPermissionDenied('Camera permission is required'));
      }
    });
  }

  void _onQrCodeScanned(
    QrCodeScannedEvent event,
    Emitter<QrScannerState> emit,
  ) {
    final result = QrResult(data: event.data, scannedAt: DateTime.now());
    emit(QrScannerSuccess(result));
  }

  void _onResetScanner(ResetScannerEvent event, Emitter<QrScannerState> emit) {
    emit(QrScannerInitial());
  }
}
