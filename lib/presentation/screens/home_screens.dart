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
    String currentHour = DateTime.now().hour.toString().padLeft(2, '0');
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
                  size: 30,
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
                  icon: Icon(Icons.more_vert, color: Colors.white))
            ],
          )
        ],
      ),
      body: Stack(
        children: [
          // Fondo con imagen o gradiente
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
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 50),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            Text(
                              ' ${location.name} , ',
                              style: const TextStyle(
                                  fontSize: 28,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  ' ${location.country}',
                                  style: const TextStyle(
                                      fontSize: 28,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(
                                  width: 8,
                                ),
                                const Icon(Icons.location_on,
                                    color: Colors.white),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Image.network('https:${current.condition.icon}',
                        width: 100, height: 100),
                    Text(
                      "${current.tempC} °C",
                      style: const TextStyle(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      "Sensación térmica:  °C",
                      style:
                          const TextStyle(fontSize: 18, color: Colors.white70),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.black.withOpacity(0.3),
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Row(
                          children: [
                            Icon(Icons.cloud, color: Colors.white),
                            const SizedBox(width: 10),
                            const Text(
                              "Pronóstico del Clima",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: Colors.black.withOpacity(0.3),
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
                                        'https:${hourlyForecast.condition.icon}'),
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
                    SizedBox(
                      height: 25,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Colors.black.withOpacity(0.3),
                          ),
                          padding: EdgeInsets.all(25),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Prevision de tormentas durante 6 horas',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          )),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 20, right: 20),
                      child: Row(
                        children: [
                          Text(
                            'Detalle de Clima',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: GridView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 columnas
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 1.6,
                        ),
                        children: [
                          weatherCard(Icons.thermostat, 'Temperatura aparente',
                              '${current.tempC} °C'),
                          weatherCard(
                              Icons.air, 'Viento', '${current.windKph} Km/h'),
                          weatherCard(Icons.water_drop, 'Humedad',
                              '${current.humidity} %'),
                          weatherCard(
                              Icons.wb_sunny, 'Índice UV', '${current.uv}'),
                          weatherCard(Icons.visibility, 'Visibilidad',
                              '${current.visKm} km'),
                          weatherCard(Icons.compress, 'Presión del aire',
                              '${current.pressureMb} hPa'),
                        ],
                      ),
                    )
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget weatherCard(IconData icon, String title, String value) {
    return Container(
      width: 150, // Tamaño fijo para evitar cambios en diferentes dispositivos
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
      ),
      padding: EdgeInsets.all(13),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // Evita que el widget se expanda demasiado
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 35),
          SizedBox(height: 8),
          Text(title,
              style: TextStyle(color: Colors.white70, fontSize: 16),
              textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
