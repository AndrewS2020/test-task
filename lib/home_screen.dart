import 'package:flutter/material.dart';
import 'package:swim_success/features/pace_selector/presentation/pace_selector_screen.dart' show PaceSelectorScreen;
import 'package:swim_success/features/users/presentation/screens/user_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121220),
      appBar: AppBar(
        title: const Text('Swim Success'),
        backgroundColor: const Color(0xFF1E1E2E),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.pool, size: 64, color: Color(0xFF42A5F5)),
            const SizedBox(height: 24),
            const Text(
              'Swim Success',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Text(
              'Flutter Developer Test Task',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
            const SizedBox(height: 48),
            _buildTaskButton(
              context,
              icon: Icons.timer_outlined,
              title: 'Pace Selector',
              subtitle: 'Set your best 100m freestyle time',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PaceSelectorScreen()),
              ),
            ),
            const SizedBox(height: 16),
            _buildTaskButton(
              context,
              icon: Icons.people_outline,
              title: 'User List',
              subtitle: 'Browse and search users',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const UserListScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Material(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF42A5F5).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: const Color(0xFF42A5F5), size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
