import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app_clima/infrastructure/models/OpenWheather/City.dart';
import 'package:flutter_app_clima/infrastructure/models/OpenWheather/WeatherOfTheDay.dart';
import 'package:geolocator/geolocator.dart';

class ClimaService extends ChangeNotifier {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.weatherapi.com/v1',
      queryParameters: {
        'key': '550c884eb5b840bf88d51709251802',
        'lang': 'es',
      },
    ),
  );

  /// **Solicita permisos de ubicación**
  Future<bool> solicitarPermisosUbicacion() async {
    LocationPermission permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        debugPrint('El usuario denegó los permisos de ubicación.');
        return false;
      }
    }
    if (permiso == LocationPermission.deniedForever) {
      debugPrint('Los permisos están denegados permanentemente.');
      return false;
    }
    return true;
  }

  /// **Obtiene el clima según la ubicación actual**
  Future<WeatherOfTheDay?> obtenerClimaPorUbicacion() async {
    bool permisosOtorgados = await solicitarPermisosUbicacion();
    if (!permisosOtorgados) return null;

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return obtenerClima(position.latitude, position.longitude);
    } catch (e) {
      debugPrint('Error al obtener la ubicación: $e');
      return null;
    }
  }

  /// **Obtiene el clima basado en latitud y longitud**
  Future<WeatherOfTheDay?> obtenerClima(double lat, double lon) async {
    try {
      final response = await _dio.get(
        '/forecast.json',
        queryParameters: {'q': '$lat,$lon'},
      );

      debugPrint('Respuesta del servidor: ${response.data}');

      if (response.data == null || response.data.isEmpty) {
        debugPrint('Error: La respuesta de la API es null o vacía.');
        return null;
      }

      return WeatherOfTheDay.fromJson(response.data);
    } catch (e) {
      debugPrint('Error al obtener el clima: $e');
      return null;
    }
  }

  /// **Obtiene el clima basado en el nombre de una ciudad**
  Future<WeatherOfTheDay?> obtenerClimaPorCiudad(String ciudad) async {
    if (ciudad.isEmpty) return null;

    try {
      final response = await _dio.get(
        '/forecast.json',
        queryParameters: {'q': ciudad},
      );

      debugPrint('Respuesta del servidor para $ciudad: ${response.data}');

      if (response.data == null || response.data.isEmpty) {
        debugPrint('Error: La respuesta de la API es null o vacía.');
        return null;
      }

      return WeatherOfTheDay.fromJson(response.data);
    } catch (e) {
      debugPrint('Error al obtener el clima para $ciudad: $e');
      return null;
    }
  }
   /// **Busca ciudades similares basadas en el nombre ingresado**
  Future<List<City>> buscarCiudad(String nombreCiudad) async {
    if (nombreCiudad.isEmpty) return [];

    try {
      final response = await _dio.get(
        '/search.json',
        queryParameters: {'q': nombreCiudad},
      );

      debugPrint('Resultados de búsqueda para "$nombreCiudad": ${response.data}');

      if (response.data == null || response.data.isEmpty) {
        debugPrint('No se encontraron ciudades similares.');
        return [];
      }

      // Convertir la respuesta JSON en una lista de objetos City
      return (response.data as List)
          .map((json) => City.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error al buscar ciudades: $e');
      return [];
    }
  }
}
