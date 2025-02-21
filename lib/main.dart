import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_app_clima/presentation/screens/home_screens.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Asegurar inicialización
  await dotenv.load(fileName: ".env"); // Cargar el archivo .env

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App Clima',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomeScreen(),
    );        
  }
}
