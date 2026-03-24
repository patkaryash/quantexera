import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  final ImagePicker _picker = ImagePicker();

  final workerData = {
    'name': 'Rahul Sharma',
    'designation': 'Sanitation Worker',
    'phone': '+91 98765 43210',
  };

  final List<Map<String, dynamic>> notifications = [
    {
      'title': 'New Task Assigned',
      'message': 'Admin assigned: Clean the litter in west side',
      'time': '10 mins ago',
      'isRead': false,
    },
    {
      'title': 'Task Update',
      'message': 'Admin assigned: Upload progress photos',
      'time': '1 hour ago',
      'isRead': false,
    },
    {
      'title': 'Reminder',
      'message': 'Complete pending tasks before shift ends',
      'time': '3 hours ago',
      'isRead': true,
    },
  ];

  final List<Map<String, dynamic>> tasks = [
    {
      'title': 'Clean the litter in west side',
      'status': 'in_progress',
      'sla': '5 hrs',
      'images': <XFile>[],
    },
    {
      'title': 'Upload progress photos',
      'status': 'pending',
      'sla': '2 hrs',
      'images': <XFile>[],
    },
  ];

  int get unreadCount => notifications.where((n) => !n['isRead']).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: _appBar(),
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _greeting(),
              const SizedBox(height: 10),
              _profile(),
              const SizedBox(height: 20),
              _stats(),
              const SizedBox(height: 20),
              _tasksList(),
            ],
          ),
        ),
      ),
    );
  }

  // APP BAR with gradient and notifications
  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      title: const Text("Worker Dashboard"),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
          ),
        ),
      ),
      actions: [
        // Notification Icon with Badge
        Stack(
          children: [
            IconButton(
              onPressed: _showNotifications,
              icon: const Icon(Icons.notifications_outlined),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout_outlined),
          tooltip: 'Logout',
        ),
      ],
    );
  }

  // GREETING
  Widget _greeting() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12
        ? "Good Morning"
        : hour < 17
            ? "Good Afternoon"
            : "Good Evening";

    return Text(
      "$greeting, ${workerData['name']} 👋",
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // PROFILE CARD with gradient
  Widget _profile() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: Colors.indigo, size: 30),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workerData['name']!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                workerData['designation']!,
                style: const TextStyle(color: Colors.white70),
              ),
              Text(
                workerData['phone']!,
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          )
        ],
      ),
    );
  }

  // STATS ROW
  Widget _stats() {
    int completed = tasks.where((t) => t['status'] == 'completed').length;
    int pending = tasks.length - completed;

    return Row(
      children: [
        _statCard("Total", tasks.length, Colors.blue),
        _statCard("Done", completed, Colors.green),
        _statCard("Pending", pending, Colors.orange),
      ],
    );
  }

  Widget _statCard(String title, int value, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
        ),
        child: Column(
          children: [
            Text(
              "$value",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  // TASKS LIST
  Widget _tasksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Assigned Tasks",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...tasks.map((task) => _taskCard(task)),
      ],
    );
  }

  // TASK CARD with progress bar
  Widget _taskCard(Map<String, dynamic> task) {
    List<XFile> images = task['images'];

    Color statusColor = task['status'] == 'completed'
        ? Colors.green
        : task['status'] == 'in_progress'
            ? Colors.orange
            : Colors.blue;

    IconData statusIcon = task['status'] == 'completed'
        ? Icons.check_circle
        : task['status'] == 'in_progress'
            ? Icons.timelapse
            : Icons.pending;

    double progress = task['status'] == 'completed'
        ? 1
        : task['status'] == 'in_progress'
            ? 0.6
            : 0.2;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 15),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Task", style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      task['status'].toString().replaceAll('_', ' '),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Text(task['title'], style: const TextStyle(fontSize: 14)),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text("SLA: ${task['sla']}", style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),

          const SizedBox(height: 12),

          // PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              color: statusColor,
              minHeight: 6,
            ),
          ),

          const SizedBox(height: 12),

          // IMAGES
          if (images.isEmpty)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, color: Colors.grey, size: 18),
                  SizedBox(width: 8),
                  Text("No images uploaded", style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: images.length,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: kIsWeb
                        ? Image.network(images[i].path,
                            width: 60, height: 60, fit: BoxFit.cover)
                        : Image.file(File(images[i].path),
                            width: 60, height: 60, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 12),

          // BUTTONS
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showImagePickerDialog(task),
                  icon: const Icon(Icons.add_photo_alternate, size: 18),
                  label: Text("Add (${images.length})"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: task['status'] == 'completed'
                      ? null
                      : () => _completeTask(task),
                  icon: const Icon(Icons.check, size: 18),
                  label: Text(task['status'] == 'completed' ? "Done" : "Complete"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // IMAGE PICKER DIALOG (Camera / Gallery)
  void _showImagePickerDialog(Map<String, dynamic> task) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Task Photo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Upload photos to report task progress',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _imageOptionButton(
                      icon: Icons.camera_alt,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(task, ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _imageOptionButton(
                      icon: Icons.photo_library,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage(task, ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _imageOptionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.indigo.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.indigo.shade700),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.indigo.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PICK IMAGE
  Future<void> _pickImage(Map<String, dynamic> task, ImageSource source) async {
    try {
      final XFile? img = await _picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 80,
      );

      if (img != null) {
        setState(() => task['images'].add(img));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(source == ImageSource.camera
                  ? 'Photo captured!'
                  : 'Image added!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(kIsWeb && source == ImageSource.camera
                ? 'Camera requires HTTPS. Use gallery instead.'
                : 'Failed: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  // COMPLETE TASK
  void _completeTask(Map<String, dynamic> task) {
    if (task['images'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please add at least one image first"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => task['status'] = 'completed');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Task completed! 🎉"),
        backgroundColor: Colors.green,
      ),
    );
  }

  // NOTIFICATIONS
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      const Icon(Icons.notifications, color: Colors.indigo),
                      const SizedBox(width: 8),
                      const Text(
                        'Notifications',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (unreadCount > 0)
                        TextButton(
                          onPressed: () {
                            setState(() {
                              for (var n in notifications) {
                                n['isRead'] = true;
                              }
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Mark all read'),
                        ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: notifications.length,
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: n['isRead'] ? Colors.white : Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: n['isRead'] ? Colors.grey.shade200 : Colors.indigo.shade200,
                          ),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(12),
                          leading: CircleAvatar(
                            backgroundColor: Colors.indigo.shade100,
                            child: Icon(Icons.assignment, color: Colors.indigo.shade700),
                          ),
                          title: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  n['title'],
                                  style: TextStyle(
                                    fontWeight: n['isRead'] ? FontWeight.normal : FontWeight.bold,
                                  ),
                                ),
                              ),
                              if (!n['isRead'])
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Colors.indigo,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(n['message'], style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                              const SizedBox(height: 4),
                              Text(n['time'], style: TextStyle(color: Colors.grey.shade400, fontSize: 11)),
                            ],
                          ),
                          onTap: () => setState(() => n['isRead'] = true),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // LOGOUT
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.logout, color: Colors.red),
            SizedBox(width: 10),
            Text('Logout'),
          ],
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
