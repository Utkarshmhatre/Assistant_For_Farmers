import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DistributionScreen extends StatefulWidget {
  const DistributionScreen({super.key});

  @override
  State<DistributionScreen> createState() => _DistributionScreenState();
}

class _DistributionScreenState extends State<DistributionScreen> {
  final MapController _mapController = MapController();
  final LatLng _center = const LatLng(45.521563, -122.677433);
  final List<Marker> _markers = [];
  List<LatLng> _routePoints = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  bool _isSearchVisible = false;
  bool _isCalculatingRoute = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermission();
  }

  Future<void> _checkLocationPermission() async {
    try {
      // First check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location services are disabled. Please enable them in settings.'),
          ));
        }
        return;
      }

      // Then check for permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'Location permissions are denied. Some features may not work.'),
            ));
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text(
                'Location permissions are permanently denied. Please enable them in settings.'),
          ));
        }
        return;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error checking location permission: $e'),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Distribution Network'),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _center,
              zoom: 11.0,
              onTap: _handleMapTap,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                tileProvider: NetworkTileProvider(),
              ),
              MarkerLayer(markers: _markers),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: _routePoints,
                    strokeWidth: 4.0,
                    color: Colors.blue,
                  ),
                ],
              ),
            ],
          ),
          if (_isSearchVisible)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Search for a place',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) => _searchPlaces(value),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _searchPlaces(_searchController.text),
                    ),
                  ],
                ),
              ),
            ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: _optimizeRoute,
            heroTag: 'optimize',
            child: const Icon(Icons.route),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _clearRoute,
            heroTag: 'clear',
            child: const Icon(Icons.clear),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            onPressed: _getCurrentLocation,
            heroTag: 'location',
            child: const Icon(Icons.my_location),
          ),
        ],
      ),
    );
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _markers.add(Marker(
        width: 40.0,
        height: 40.0,
        point: point,
        builder: (ctx) =>
            const Icon(Icons.location_on, color: Colors.red, size: 40),
      ));
      _routePoints.add(point);
    });
    if (_routePoints.length > 1) {
      _getRoutePoints();
    }
  }

  Future<void> _getRoutePoints() async {
    if (_routePoints.length < 2 || _isCalculatingRoute) return;

    setState(() {
      _isLoading = true;
      _isCalculatingRoute = true;
    });

    List<LatLng> newRoutePoints = [];

    try {
      // Calculate route between last two points only
      LatLng start = _routePoints[_routePoints.length - 2];
      LatLng end = _routePoints[_routePoints.length - 1];

      String url = 'https://router.project-osrm.org/route/v1/driving/'
          '${start.longitude},${start.latitude};${end.longitude},${end.latitude}'
          '?overview=full&geometries=geojson';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> coordinates =
            data['routes'][0]['geometry']['coordinates'];

        // Keep existing route points
        newRoutePoints.addAll(_routePoints.sublist(0, _routePoints.length - 2));

        // Add new route segment
        for (var coord in coordinates) {
          newRoutePoints.add(LatLng(coord[1], coord[0]));
        }

        setState(() {
          _routePoints = newRoutePoints;
        });
      }
    } catch (e) {
      print('Error getting route points: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: Unable to get route. Please try again.')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
        _isCalculatingRoute = false;
      });
    }
  }

  void _optimizeRoute() {
    if (_routePoints.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Add at least two points to optimize the route')),
      );
      return;
    }

    setState(() {
      _routePoints.sort((a, b) => a.latitude.compareTo(b.latitude));
      _markers.clear();
      for (var point in _routePoints) {
        _markers.add(Marker(
          width: 40.0,
          height: 40.0,
          point: point,
          builder: (ctx) =>
              const Icon(Icons.location_on, color: Colors.red, size: 40),
        ));
      }
    });

    _getRoutePoints();
  }

  void _clearRoute() {
    setState(() {
      _markers.clear();
      _routePoints.clear();
    });
  }

  void _searchPlaces(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String url =
          'https://nominatim.openstreetmap.org/search?format=json&q=$query';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data.isNotEmpty) {
          final place = data[0];
          final latLng =
              LatLng(double.parse(place['lat']), double.parse(place['lon']));

          setState(() {
            _markers.add(Marker(
              width: 40.0,
              height: 40.0,
              point: latLng,
              builder: (ctx) =>
                  const Icon(Icons.location_on, color: Colors.red, size: 40),
            ));
            _routePoints.add(latLng);
          });

          _mapController.move(latLng, 14);
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No results found for "$query"')),
            );
          }
        }
      }
    } catch (e) {
      print('Error searching places: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'Error: Unable to search for places. Please try again.')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled');
      }

      // Check for permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception('Location permission denied');
      }

      // Get position with timeout
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      if (mounted) {
        final latLng = LatLng(position.latitude, position.longitude);

        setState(() {
          _markers.add(Marker(
            width: 40.0,
            height: 40.0,
            point: latLng,
            builder: (ctx) =>
                const Icon(Icons.my_location, color: Colors.blue, size: 40),
          ));
          _routePoints.add(latLng);
        });

        _mapController.move(latLng, 14);
      }
    } catch (e) {
      print('Error getting current location: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting current location: $e')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
