import 'location_service.dart';
import 'notification_service.dart';
import 'api_service.dart';
import 'storage_service.dart';

class SafetyService {
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  Future<void> sendEmergencyAlert(String message) async {
    try {
      final position = await _locationService.getCurrentLocation();
      final alertData = {
        'message': message,
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _storageService.saveString('last_alert', alertData.toString());

      await _apiService.postRequest('emergency', alertData);

      await _notificationService.showNotification(
        title: 'Emergency Alert Sent!',
        body: 'Your alert has been successfully sent.',
      );
    } catch (e) {
      await _notificationService.showNotification(
        title: 'Emergency Failed',
        body: 'Could not send emergency alert: $e',
      );
    }
  }
}
