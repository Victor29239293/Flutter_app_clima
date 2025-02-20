
import 'package:flutter_app_clima/presentation/screens/providers/clima_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final climaProvider = ChangeNotifierProvider<ClimaService>((ref) {
  return ClimaService();
});
