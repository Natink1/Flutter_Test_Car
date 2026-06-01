import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../state/session_controller.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.sessionController,
    required this.authService,
  });

  final SessionController sessionController;
  final AuthService authService;

  @override
  Widget build(BuildContext context) {
    final user = sessionController.user!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Profile',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),
        Card(
          elevation: 0,
          child: ListTile(
            title: Text(user.name),
            subtitle: Text('${user.email}\nRole: ${user.role}'),
            isThreeLine: true,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonal(
          onPressed: () async {
            await sessionController.logout();
          },
          child: const Text('Logout'),
        ),
      ],
    );
  }
}
