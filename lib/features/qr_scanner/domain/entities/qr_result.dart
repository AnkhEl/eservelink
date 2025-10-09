import 'package:equatable/equatable.dart';

class QrResult extends Equatable {
  final String data;
  final DateTime scannedAt;

  const QrResult({required this.data, required this.scannedAt});

  @override
  List<Object?> get props => [data, scannedAt];
}
