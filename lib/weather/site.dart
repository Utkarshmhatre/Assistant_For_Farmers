class Site {
  final String id;
  final String name;
  final String city;
  final double lat;
  final double lon;
  final double? avg;
  final String? conditions; // Add conditions field

  Site({
    required this.id,
    required this.name,
    required this.city,
    required this.lat,
    required this.lon,
    this.avg,
    this.conditions, // Conditions as optional field
  });

  // Factory constructor to parse JSON data
  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'],
      name: json['name'],
      city: json['city'] ?? 'Unknown',
      lat: json['lat'],
      lon: json['lon'],
      avg: json['avg'] != null ? json['avg'].toDouble() : null,
      conditions: json['conditions'], // Parse conditions from JSON
    );
  }

  // To convert object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'city': city,
      'lat': lat,
      'lon': lon,
      'avg': avg,
      'conditions': conditions, // Include conditions in the JSON output
    };
  }
}
