import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/cars/car_detail_screen.dart';
import 'screens/guest/guest_home_screen.dart';
import 'screens/shell_screen.dart';
import 'services/api_client.dart';
import 'services/auth_service.dart';
import 'services/booking_service.dart';
import 'services/car_service.dart';
import 'state/session_controller.dart';

class CarRentalApp extends StatefulWidget {
  const CarRentalApp({super.key});

  @override
  State<CarRentalApp> createState() => _CarRentalAppState();
}

class _CarRentalAppState extends State<CarRentalApp> {
  late final ApiClient apiClient;
  late final AuthService authService;
  late final CarService carService;
  late final BookingService bookingService;
  late final SessionController sessionController;

  @override
  void initState() {
    super.initState();
    apiClient = ApiClient.instance;
    authService = AuthService(apiClient);
    carService = CarService(apiClient);
    bookingService = BookingService(apiClient);
    sessionController = SessionController(authService)..bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'NHK Car Rental',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        scaffoldBackgroundColor: const Color(0xFFF7FAFC),
      ),
      home: AnimatedBuilder(
        animation: sessionController,
        builder: (context, _) {
          if (sessionController.isLoading) {
            return const _SplashScreen();
          }
          if (sessionController.user == null) {
            return GuestHomeScreen(
              carService: carService,
              onLogin: () => _openAuth(context, false),
              onRegister: () => _openAuth(context, true),
              onOpenCar: (carId) => _openCar(context, carId),
            );
          }
          return ShellScreen(
            sessionController: sessionController,
            authService: authService,
            carService: carService,
            bookingService: bookingService,
          );
        },
      ),
    );
  }

  void _openAuth(BuildContext context, bool register) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => register
            ? RegisterScreen(sessionController: sessionController)
            : LoginScreen(sessionController: sessionController),
      ),
    );
  }

  void _openCar(BuildContext context, String carId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CarDetailScreen(
          carId: carId,
          carService: carService,
          bookingService: bookingService,
          sessionController: sessionController,
        ),
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
