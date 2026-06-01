import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/booking_service.dart';
import '../services/car_service.dart';
import '../state/session_controller.dart';
import 'bookings/bookings_screen.dart';
import 'cars/car_detail_screen.dart';
import 'cars/cars_browser_screen.dart';
import 'profile/profile_screen.dart';

class ShellScreen extends StatefulWidget {
  const ShellScreen({
    super.key,
    required this.sessionController,
    required this.authService,
    required this.carService,
    required this.bookingService,
  });

  final SessionController sessionController;
  final AuthService authService;
  final CarService carService;
  final BookingService bookingService;

  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      CarsBrowserScreen(
        carService: widget.carService,
        onOpenCar: _openCar,
        showFeaturedHeader: true,
      ),
      BookingsScreen(bookingService: widget.bookingService),
      ProfileScreen(
        sessionController: widget.sessionController,
        authService: widget.authService,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _index == 0
              ? 'Cars'
              : _index == 1
              ? 'Bookings'
              : 'Profile',
        ),
      ),
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.directions_car_outlined),
            selectedIcon: Icon(Icons.directions_car),
            label: 'Cars',
          ),
          NavigationDestination(
            icon: Icon(Icons.book_outlined),
            selectedIcon: Icon(Icons.book),
            label: 'Bookings',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  void _openCar(String carId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CarDetailScreen(
          carId: carId,
          carService: widget.carService,
          bookingService: widget.bookingService,
          sessionController: widget.sessionController,
        ),
      ),
    );
  }
}
