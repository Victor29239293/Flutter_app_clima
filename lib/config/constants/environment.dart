import 'package:flutter_dotenv/flutter_dotenv.dart';

class Environment {
  static String get theWeatherApi {
    final apiKey = dotenv.env['THE_WEATHER_API'];
    if (apiKey == null || apiKey.isEmpty) {
      return 'No hay API disponible';
    }
    return apiKey;
  }
}
