import 'package:url_launcher/url_launcher.dart';

class MapUtils {
  /// Launch Google Maps with the specified address
  static Future<void> openGoogleMaps({
    String? address,
    String? latitude,
    String? longitude,
  }) async {
    String url;
    
    if (latitude != null && longitude != null) {
      // Use coordinates if available
      url = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    } else if (address != null) {
      // Use address if coordinates not available
      final encodedAddress = Uri.encodeComponent(address);
      url = 'https://www.google.com/maps/search/?api=1&query=$encodedAddress';
    } else {
      throw ArgumentError('Either address or coordinates must be provided');
    }

    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Google Maps');
      }
    } catch (e) {
      print('Error launching Google Maps: $e');
      // Fallback: try to launch with different mode
      try {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      } catch (fallbackError) {
        print('Fallback error: $fallbackError');
        rethrow;
      }
    }
  }

  /// Launch Google Maps with navigation directions
  static Future<void> openGoogleMapsDirections({
    String? fromAddress,
    String? toAddress,
    String? fromLatLng,
    String? toLatLng,
  }) async {
    String url;
    
    if (fromLatLng != null && toLatLng != null) {
      // Use coordinates for directions
      url = 'https://www.google.com/maps/dir/?api=1&origin=$fromLatLng&destination=$toLatLng&travelmode=driving';
    } else if (fromAddress != null && toAddress != null) {
      // Use addresses for directions
      final encodedFrom = Uri.encodeComponent(fromAddress);
      final encodedTo = Uri.encodeComponent(toAddress);
      url = 'https://www.google.com/maps/dir/?api=1&origin=$encodedFrom&destination=$encodedTo&travelmode=driving';
    } else {
      throw ArgumentError('Both origin and destination must be provided');
    }

    final uri = Uri.parse(url);
    
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not launch Google Maps');
      }
    } catch (e) {
      print('Error launching Google Maps directions: $e');
      rethrow;
    }
  }

  /// Parse coordinates from a string like "6.9271,79.8612"
  static Map<String, String>? parseCoordinates(String? coordString) {
    if (coordString == null || coordString.isEmpty) return null;
    
    final parts = coordString.split(',');
    if (parts.length != 2) return null;
    
    try {
      final lat = double.parse(parts[0].trim());
      final lng = double.parse(parts[1].trim());
      return {
        'latitude': lat.toString(),
        'longitude': lng.toString(),
      };
    } catch (e) {
      print('Error parsing coordinates: $e');
      return null;
    }
  }
}