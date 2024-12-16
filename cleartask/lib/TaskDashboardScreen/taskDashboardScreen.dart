import 'package:flutter/material.dart';

class TaskDashboardScreen extends StatefulWidget {
  const TaskDashboardScreen({super.key});

  @override
  _TaskDashboardScreenState createState() => _TaskDashboardScreenState();
}

class _TaskDashboardScreenState extends State<TaskDashboardScreen> {
  bool task1Completed = true;
  bool task2Completed = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with profile image and notification icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const CircleAvatar(
                  backgroundImage: AssetImage('assets/profile.png'), // Replace with actual profile image
                  radius: 25,
                ),
                IconButton(
                  icon: const Icon(Icons.notifications_none, color: Colors.teal),
                  onPressed: () {
                    // Handle notification tap
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Welcome message
            const Text(
              'Olá, Usuário!',
              style: TextStyle(fontSize: 18, color: Colors.black87),
            ),
            const Text(
              'Compromissos de hoje!',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const Text(
              'Do planejamento ao sucesso, apenas um clique de distância.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Calendar navigation
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                const Text('Seg\n18', style: TextStyle(color: Colors.black54)),
                const Text('Ter\n19', style: TextStyle(color: Colors.black54)),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.teal,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Qua\n20',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const Text('Qui\n21', style: TextStyle(color: Colors.black54)),
                const Text('Sex\n22', style: TextStyle(color: Colors.black54)),
                const Text('Sáb\n23', style: TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 20),

            // New task button
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    // Handle adding new task
                  },
                  icon: const Icon(Icons.add, color: Colors.teal),
                  label: const Text('Nova tarefa', style: TextStyle(color: Colors.teal)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.teal),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Task items
            _buildTaskItem('08:00 | Dar ração pro gato', task1Completed, (value) {
              setState(() {
                task1Completed = value!;
              });
            }),
            _buildTaskItem('Consulta Médica | 14h00', task2Completed, (value) {
              setState(() {
                task2Completed = value!;
              });
            }),
            const Spacer(),

            // Continue button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Handle continue action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Continue'),
              ),
            ),

            // Bottom navigation bar
            const SizedBox(height: 20),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Icon(Icons.home, color: Colors.teal),
                Icon(Icons.bookmark_border, color: Colors.grey),
                Icon(Icons.article_outlined, color: Colors.grey),
                Icon(Icons.settings, color: Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskItem(String title, bool completed, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.teal),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          Checkbox(
            value: completed,
            onChanged: onChanged,
            activeColor: Colors.teal,
          ),
        ],
      ),
    );
  }
}
