import 'dart:math' as Math;
import 'package:dartz/dartz.dart';
import 'package:eservelink/core/error/failures.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  /// Get the current location of the device
  /// Returns Either<Failure, Position> with latitude and longitude
  Future<Either<Failure, Position>> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Left(LocationFailure('Location services are disabled'));
      }

      // Check location permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // Request permission if not granted
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Left(LocationFailure('Location permissions are denied'));
        }
      }

      if (permission == LocationPermission.deniedForever) {
        // Location permissions are permanently denied
        return Left(
          LocationFailure(
            'Location permissions are permanently denied. Please enable them in app settings.',
          ),
        );
      }

      // Get current position with high accuracy
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return Right(position);
    } on LocationServiceDisabledException {
      return Left(LocationFailure('Location services are disabled'));
    } on PermissionDeniedException {
      return Left(LocationFailure('Location permission is denied'));
    } catch (e) {
      return Left(LocationFailure('Failed to get location: ${e.toString()}'));
    }
  }

  /// Request location permission explicitly
  /// Returns Either<Failure, bool> - true if permission is granted
  Future<Either<Failure, bool>> requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      if (status.isGranted) {
        return const Right(true);
      } else if (status.isDenied) {
        return Left(LocationFailure('Location permission was denied'));
      } else if (status.isPermanentlyDenied) {
        return Left(
          LocationFailure(
            'Location permission is permanently denied. Please enable it in app settings.',
          ),
        );
      }
      return Left(LocationFailure('Failed to request location permission'));
    } catch (e) {
      return Left(
        LocationFailure(
          'Error requesting location permission: ${e.toString()}',
        ),
      );
    }
  }

  /// Get the distance between two coordinates in kilometers
  /// Uses the Haversine formula
  static double calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const double earthRadiusKm = 6371;
    final double dLat = _toRadians(lat2 - lat1);
    final double dLng = _toRadians(lng2 - lng1);

    final double a =
        (Math.sin(dLat / 2) * Math.sin(dLat / 2)) +
        Math.cos(_toRadians(lat1)) *
            Math.cos(_toRadians(lat2)) *
            Math.sin(dLng / 2) *
            Math.sin(dLng / 2);

    final double c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  static double _toRadians(double degrees) {
    return degrees * (Math.pi / 180);
  }
}
