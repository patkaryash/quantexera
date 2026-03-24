import 'package:flutter/material.dart';
import 'package:smart_civic/screens/login_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: Colors.indigo,
        elevation: 0,
        title: const Text('SmartCivic Dashboard'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showProfileMenu(context),
              child: const CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon(Icons.person, color: Colors.indigo),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats Cards Row
              _buildStatsSection(),
              const SizedBox(height: 20),

              // Action Buttons Row
              _buildActionButtons(context),
              const SizedBox(height: 24),

              // Worker Details Section
              _buildWorkerDetails(),
              const SizedBox(height: 24),

              // Daily Tasks Section
              _buildDailyTasks(),
            ],
          ),
        ),
      ),
    );
  }

  /// Profile Popup Menu
  void _showProfileMenu(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Header
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.indigo.shade100,
                      child: Icon(Icons.person, size: 30, color: Colors.indigo.shade700),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Admin Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text('Administrator', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(),
                const SizedBox(height: 5),

                // Notifications
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.notifications, color: Colors.blue.shade700),
                  ),
                  title: const Text('Notifications'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(12)),
                    child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening Notifications...')));
                  },
                ),

                // SLA Compliance
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.analytics, color: Colors.green.shade700),
                  ),
                  title: const Text('SLA Compliance'),
                  subtitle: const Text('92% this month'),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Opening SLA Compliance...')));
                  },
                ),

                // Logout
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8)),
                    child: Icon(Icons.logout, color: Colors.red.shade700),
                  ),
                  title: const Text('Logout', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatsSection() {
    return Column(
      children: [
        // Total Workers Card with Alert
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.people, color: Colors.indigo.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'Total Workers',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '50',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 6,
                      children: [
                        _buildIndicator(Colors.green, 'Active: 30'),
                        _buildIndicator(Colors.blue, 'Inside: 20'),
                        _buildIndicator(Colors.orange, 'Outside: 10'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.shade200,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {},
                    borderRadius: BorderRadius.circular(16),
                    child: const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.warning_rounded, color: Colors.white, size: 36),
                        SizedBox(height: 8),
                        Text(
                          'ALERTS',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '3 New',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildIndicator(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MapPlaceholderScreen()),
              );
            },
            icon: const Icon(Icons.map_outlined),
            label: const Text('View Map'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'All',
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down),
                items: ['All', 'Sanitation', 'Roads', 'Parks', 'Water']
                    .map((dept) => DropdownMenuItem(
                          value: dept,
                          child: Text(dept),
                        ))
                    .toList(),
                onChanged: (value) {},
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWorkerDetails() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(Icons.badge_outlined, color: Colors.indigo),
                const SizedBox(width: 8),
                const Text(
                  'Worker Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {},
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Table Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade50,
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Worker Name', style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(child: Text('Present', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(child: Text('Absent', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600))),
                Expanded(child: Text('Overall', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          // Worker Rows
          _buildWorkerRow('Rahul Sharma', 3, 2),
          _buildWorkerRow('Amit Kumar', 1, 4),
          _buildWorkerRow('Suresh Patil', 4, 1),
          _buildWorkerRow('Vijay Singh', 5, 0),
        ],
      ),
    );
  }

  Widget _buildWorkerRow(String name, int present, int absent) {
    int total = present + absent;
    double percentage = present / total;
    Color statusColor = percentage >= 0.8
        ? Colors.green
        : percentage >= 0.5
            ? Colors.orange
            : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.indigo.shade100,
                  child: Text(
                    name[0],
                    style: TextStyle(
                      color: Colors.indigo.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(name),
              ],
            ),
          ),
          Expanded(
            child: Text(
              '$present',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              '$absent',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$present/$total',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTasks() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.task_alt, color: Colors.indigo),
              SizedBox(width: 8),
              Text(
                'Daily Tasks',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Circular Progress
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: 4 / 9,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
                      strokeCap: StrokeCap.round,
                    ),
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '4/9',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Tasks',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              // Task Stats
              Expanded(
                child: Column(
                  children: [
                    _buildTaskStat(
                      'Completed',
                      '4',
                      Colors.green,
                      Icons.check_circle,
                    ),
                    const SizedBox(height: 12),
                    _buildTaskStat(
                      'Pending',
                      '3',
                      Colors.orange,
                      Icons.pending,
                    ),
                    const SizedBox(height: 12),
                    _buildTaskStat(
                      'Remaining',
                      '2',
                      Colors.red,
                      Icons.schedule,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTaskStat(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

// Placeholder for Map Screen
class MapPlaceholderScreen extends StatelessWidget {
  const MapPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Tracking Map'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Map View',
              style: TextStyle(fontSize: 24, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Google Maps integration pending',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
