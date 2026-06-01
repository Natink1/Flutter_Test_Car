import 'package:flutter/material.dart';
import '../../services/car_service.dart';
import '../cars/cars_browser_screen.dart';

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({
    super.key,
    required this.carService,
    required this.onLogin,
    required this.onRegister,
    required this.onOpenCar,
  });

  final CarService carService;
  final VoidCallback onLogin;
  final VoidCallback onRegister;
  final ValueChanged<String> onOpenCar;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NHK Car Rental'),
        actions: [
          TextButton(onPressed: onLogin, child: const Text('Login')),
          const SizedBox(width: 8),
          FilledButton.tonal(
            onPressed: onRegister,
            child: const Text('Register'),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: CarsBrowserScreen(
        carService: carService,
        onOpenCar: onOpenCar,
        showFeaturedHeader: true,
      ),
    );
  }
}
