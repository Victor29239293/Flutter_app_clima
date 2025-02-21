import 'package:flutter/material.dart';
import 'package:flutter_app_clima/infrastructure/models/OpenWheather/WeatherOfTheDay.dart';
import 'package:flutter_app_clima/infrastructure/models/OpenWheather/City.dart';
import 'package:flutter_app_clima/presentation/screens/providers/consumir_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BuscarCiudadScreen extends ConsumerStatefulWidget {
  const BuscarCiudadScreen({super.key});

  @override
  _BuscarCiudadScreenState createState() => _BuscarCiudadScreenState();
}

class _BuscarCiudadScreenState extends ConsumerState<BuscarCiudadScreen> {
  late Future<WeatherOfTheDay?> climaFuture;
  final TextEditingController _cityController = TextEditingController();
  List<City> ciudadesGuardadas = [];
  City? ciudadActual;

  @override
  void initState() {
    super.initState();
    _obtenerClimaPorUbicacion();
  }

  Future<void> _obtenerClimaPorUbicacion() async {
    climaFuture = ref.read(climaProvider.notifier).obtenerClimaPorUbicacion();
    final clima = await climaFuture;
    if (clima != null) {
      setState(() {
        ciudadActual = City(
          name: clima.location.name,
          country: clima.location.country,
          latitude: clima.location.lat,
          longitude: clima.location.lon,
        );
      });
    }
  }

  void _buscarCiudad(String ciudad) {
    setState(() {
      climaFuture =
          ref.read(climaProvider.notifier).obtenerClimaPorCiudad(ciudad);
    });
  }

  Future<List<City>> _buscarCiudadesSimilares(String ciudad) async {
    return await ref.read(climaProvider.notifier).buscarCiudad(ciudad);
  }

  void _showSearchModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.7,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Buscar Ciudad",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: _cityController,
                  decoration: InputDecoration(
                    labelText: "Nombre de la ciudad",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {}); // Para actualizar la lista de sugerencias
                  },
                ),
                SizedBox(height: 10),
                Expanded(
                  child: FutureBuilder<List<City>>(
                    future: _cityController.text.isEmpty
                        ? null
                        : _buscarCiudadesSimilares(_cityController.text),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error al buscar ciudades.'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return Center(
                            child: Text('No se encontraron ciudades.'));
                      } else {
                        final ciudades = snapshot.data!;
                        return ListView.builder(
                          itemCount: ciudades.length,
                          itemBuilder: (context, index) {
                            final ciudad = ciudades[index];
                            return ListTile(
                              title: Text('${ciudad.name}, ${ciudad.country}'),
                              onTap: () {
                                Navigator.pop(context);
                                _buscarCiudad(ciudad.name);
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Color.fromARGB(230, 0, 0, 0),
        title: Text(
          'Administrar Ciudades',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(214, 0, 0, 0),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: FutureBuilder<WeatherOfTheDay?>(
              future: climaFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(
                      child: Text('No se encontró información del clima.'));
                } else {
                  final climaData = snapshot.data!;
                  final location = climaData.location;
                  final current = climaData.current;
                  return Column(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: Colors.white,
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 25, horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(Icons.location_on,
                                          color: Colors.red),
                                      SizedBox(width: 5),
                                      Text(
                                        '${location.name},${location.country}',
                                        style: TextStyle(
                                            fontSize: 21,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    '${current.tempC}°C',
                                    style: TextStyle(
                                        fontSize: 21,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(Icons.cloud, color: Colors.blueGrey),
                                  SizedBox(width: 5),
                                  Text(
                                    current.condition.text,
                                    style: TextStyle(
                                        fontSize: 22, color: Colors.grey[700]),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                }
              },
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: FloatingActionButton(
                onPressed: () => _showSearchModal(context),
                child: Icon(Icons.add),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
