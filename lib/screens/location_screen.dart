import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utils/constants.dart';

// Location screen with map showing user's location
class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final MapController _mapController = MapController();
  LatLng? _userLocation;
  bool _isLoading = true;
  String? _errorMessage;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }


  // Get current location
  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Web platform - use browser geolocation API
      if (kIsWeb) {
        // For web, we'll show a default location or use browser geolocation
        // Using a default location for demonstration (you can implement browser geolocation API)
        final defaultLocation = const LatLng(0.0, 0.0);
        setState(() {
          _userLocation = defaultLocation;
          _isLoading = false;
          _errorMessage = 'Location feature requires mobile platform. Showing default map view.';
        });
        // If map is already rendered, move to location
        if (_mapReady) {
          _mapController.move(defaultLocation, 2.0);
        }
        return;
      }

      // Check location permission
      final permission = await Permission.location.request();
      if (!permission.isGranted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location permission denied. Please enable location access in settings.';
        });
        return;
      }

      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Location services are disabled. Please enable location services.';
        });
        return;
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final location = LatLng(position.latitude, position.longitude);
      setState(() {
        _userLocation = location;
        _isLoading = false;
      });

      // Center map on user location (only if map is already rendered)
      if (_mapReady) {
        _mapController.move(location, 15.0);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error getting location: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(AppConstants.textColor)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Location',
          style: TextStyle(
            color: Color(AppConstants.textColor),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(AppConstants.primaryColor)),
            onPressed: _getCurrentLocation,
            tooltip: 'Refresh location',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorState()
              : _userLocation == null
                  ? _buildErrorState()
                  : _buildMap(),
    );
  }

  // Build map widget
  Widget _buildMap() {
    // Mark map as ready after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _mapReady = true;
        });
      }
    });

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _userLocation!,
        initialZoom: 15.0,
        minZoom: 3.0,
        maxZoom: 18.0,
      ),
      children: [
        // OpenStreetMap tile layer
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.myfamily',
        ),
        // Marker layer for user location
        MarkerLayer(
          markers: [
            Marker(
              point: _userLocation!,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.location_on,
                color: Color(AppConstants.primaryColor),
                size: 40,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Build error state
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_off,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            const Text(
              'Location Unavailable',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(AppConstants.textColor),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unable to get your location',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: _getCurrentLocation,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryColor),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
