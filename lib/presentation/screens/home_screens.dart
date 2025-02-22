import 'package:flutter/material.dart';
import 'package:flutter_app_clima/infrastructure/models/OpenWheather/WeatherOfTheDay.dart';
import 'package:flutter_app_clima/presentation/screens/BuscarCiudadScreen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app_clima/presentation/screens/providers/consumir_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Future<WeatherOfTheDay?>? climaFuture;

  @override
  void initState() {
    super.initState();
    climaFuture = ref.read(climaProvider.notifier).obtenerClimaPorUbicacion();
  }

  Future<void> refreshData() async {
    setState(() {
      climaFuture = ref.read(climaProvider.notifier).obtenerClimaPorUbicacion();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF0F2027),
        actions: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.file_copy,
                  color: Colors.white,
                  size: isSmallScreen ? 24 : 30,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BuscarCiudadScreen()),
                  );
                },
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_vert, color: Colors.white),
              )
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0F2027),
                  Color(0xFF203A43),
                  Color(0xFF2C5364),
                ],
              ),
            ),
          ),
          RefreshIndicator(
            onRefresh: refreshData,
            child: FutureBuilder<WeatherOfTheDay?>(
              future: climaFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                }

                if (snapshot.hasError || snapshot.data == null) {
                  return const Center(
                    child: Text(
                      "Error: No se pudo obtener el clima",
                      style: TextStyle(fontSize: 20, color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  );
                }

                final climaData = snapshot.data!;
                final location = climaData.location;
                final current = climaData.current;
                final currentHour = DateTime.now().hour.toString();

                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding:
                      EdgeInsets.symmetric(horizontal: isSmallScreen ? 10 : 20),
                  children: [
                    SizedBox(height: isSmallScreen ? 30 : 50),
                    Center(
                      child: Column(
                        children: [
                          Text(
                            '${location.name},',
                            style: TextStyle(
                              fontSize: 28,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on, color: Colors.red),
                              SizedBox(width: 5),
                              Text(
                                location.country,
                                style: TextStyle(
                                  fontSize: 24,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Image.network('https:${current.condition.icon}',
                          width: 100, height: 100),
                    ),
                    Text(
                      "${current.tempC} °C",
                      style: TextStyle(
                        fontSize: 60,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 13),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.transparent.withOpacity(0.1),
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(15),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: climaData.forecast.forecastday[0].hour
                                .where((hourlyForecast) {
                              String forecastHour = hourlyForecast.time!
                                  .split(' ')[1]
                                  .split(':')[0];
                              return int.parse(forecastHour) >=
                                  int.parse(currentHour);
                            }).map((hourlyForecast) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '${hourlyForecast.time?.split(' ')[1]}',
                                      style: TextStyle(
                                          fontSize: 20,
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 8),
                                    Image.network(
                                        'https:${hourlyForecast.condition.icon}',
                                        width: 50,
                                        height: 50),
                                    SizedBox(height: 8),
                                    Text(
                                      '${hourlyForecast.tempC}°',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: isSmallScreen ? 2 : 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 1.2,
                      children: [
                        weatherCard(Icons.water_drop, "Humedad",
                            "${current.humidity}%", isSmallScreen),
                        weatherCard(Icons.air, "Viento",
                            "${current.windKph} km/h", isSmallScreen),
                        weatherCard(Icons.thermostat, "Sensación térmica",
                            "${current.feelslikeC}°C", isSmallScreen),
                        weatherCard(Icons.compress, "Presión",
                            "${current.pressureMb} hPa", isSmallScreen),
                        weatherCard(Icons.visibility, "Visibilidad",
                            "${current.visKm} km", isSmallScreen),
                        weatherCard(Icons.wb_sunny, "Índice UV",
                            "${current.uv}", isSmallScreen),
                      ],
                    ),
                    SizedBox(height: 30),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget weatherCard(
      IconData icon, String title, String value, bool isSmallScreen) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.transparent.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(isSmallScreen ? 12 : 18),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: isSmallScreen ? 26 : 38),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isSmallScreen ? 14 : 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: isSmallScreen ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
