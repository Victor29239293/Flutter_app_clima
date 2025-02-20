class City {
  final String name;
  final String country;
  final double latitude;
  final double longitude;

  City({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
  });

  // Método para convertir un JSON a una instancia de City
  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'],
      country: json['country'],
      latitude: json['lat'] ?? 0.0,
      longitude: json['lon'] ?? 0.0,
    );
  }

  // Método para convertir una instancia de City a JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'lat': latitude,
      'lon': longitude,
    };
  }
}
