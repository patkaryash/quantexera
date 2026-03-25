import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'login_screen.dart';
import 'package:smart_civic/services/api_service.dart';

class WorkerDashboard extends StatefulWidget {
  const WorkerDashboard({super.key});

  @override
  State<WorkerDashboard> createState() => _WorkerDashboardState();
}

class _WorkerDashboardState extends State<WorkerDashboard> {
  final ImagePicker _picker = ImagePicker();

  String workerName = 'Loading...';
  List<Map<String, dynamic>> notifications = [];
  List<Map<String, dynamic>> tasks = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  // Track locally attached images per task id
  final Map<int, List<XFile>> _taskImages = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final user = ApiService.currentUser;
      if (user != null) {
        workerName = user['name'] ?? 'Worker';
      }

      final fetchedTasks = await ApiService.getTasks();

      List<Map<String, dynamic>> loadedTasks = [];
      for (var t in fetchedTasks) {
        loadedTasks.add({
          'id': t['id'],
          'title': t['title'] ?? 'No Title',
          'description': t['description'] ?? '',
          'status': t['status'] ?? 'pending',
          'worker_name': t['worker_name'],
          'created_at': t['created_at'],
        });
      }

      // Build notifications from new tasks (tasks created recently show as notifications)
      List<Map<String, dynamic>> loadedNotifs = [];
      for (var t in fetchedTasks) {
        if (t['status'] == 'pending' || t['status'] == 'assigned') {
          loadedNotifs.add({
            'title': 'New Task Assigned',
            'message': t['title'] ?? 'Untitled',
            'time': 'Recent',
            'isRead': false,
          });
        }
      }

      // Also load alerts from backend
      if (user != null && user['id'] != null) {
        try {
          final fetchedAlerts = await ApiService.getWorkerAlerts(user['id']);
          for (var a in fetchedAlerts) {
            loadedNotifs.add({
              'title': (a['type'] ?? 'Alert').toString().toUpperCase(),
              'message': a['message'] ?? '',
              'time': 'Recent',
              'isRead': false,
            });
          }
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          tasks = loadedTasks;
          notifications = loadedNotifs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get unreadCount => notifications.where((n) => !n['isRead']).length;
  int get _completedTasks => tasks.where((t) => t['status'] == 'completed').length;
  int get _pendingTasks => tasks.where((t) => t['status'] != 'completed').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: _buildAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGreeting(),
                    const SizedBox(height: 16),
                    _buildProfileCard(),
                    const SizedBox(height: 20),
                    _buildStatsRow(),
                    const SizedBox(height: 24),
                    _buildTasksList(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  // ─────────── APP BAR ───────────
  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const Text('Worker Dashboard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.indigo.shade700, Colors.indigo.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh, color: Colors.white),
          onPressed: () {
            setState(() => _isLoading = true);
            _fetchData();
          },
        ),
        Stack(
          children: [
            IconButton(
              onPressed: _showNotifications,
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                  child: Text('$unreadCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                ),
              ),
          ],
        ),
        IconButton(
          onPressed: _logout,
          icon: const Icon(Icons.logout_outlined, color: Colors.white),
          tooltip: 'Logout',
        ),
      ],
    );
  }

  // ─────────── GREETING ───────────
  Widget _buildGreeting() {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? "Good Morning" : hour < 17 ? "Good Afternoon" : "Good Evening";

    return Row(
      children: [
        Text("$greeting, $workerName 👋", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: Colors.indigo.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(Icons.cleaning_services, color: Colors.indigo.shade600, size: 16),
              const SizedBox(width: 4),
              Text('Sanitation', style: TextStyle(color: Colors.indigo.shade600, fontSize: 12, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  // ─────────── PROFILE CARD ───────────
  Widget _buildProfileCard() {
    final email = ApiService.currentUser?['email'] ?? '';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [Colors.indigo.shade600, const Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(color: Colors.indigo.withValues(alpha: 0.3), blurRadius: 12, offset: const Offset(0, 6)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                workerName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(workerName, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                const Text('Sanitation Worker', style: TextStyle(color: Colors.white70, fontSize: 13)),
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(email, style: const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text('● Online', style: TextStyle(color: Colors.greenAccent, fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ─────────── STATS ───────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatCard('Total', tasks.length, [const Color(0xFF667EEA), const Color(0xFF764BA2)], Icons.assignment),
        const SizedBox(width: 10),
        _buildStatCard('Done', _completedTasks, [const Color(0xFF11998E), const Color(0xFF38EF7D)], Icons.check_circle),
        const SizedBox(width: 10),
        _buildStatCard('Pending', _pendingTasks, [const Color(0xFFFC5C7D), const Color(0xFF6A82FB)], Icons.pending),
      ],
    );
  }

  Widget _buildStatCard(String title, int value, List<Color> gradient, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: gradient[0].withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 24),
            const SizedBox(height: 8),
            Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  // ─────────── TASKS LIST ───────────
  Widget _buildTasksList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.task_alt, color: Colors.indigo.shade600),
            ),
            const SizedBox(width: 10),
            const Text('Assigned Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(20)),
              child: Text('${tasks.length} tasks', style: TextStyle(fontSize: 12, color: Colors.indigo.shade700, fontWeight: FontWeight.w600)),
            ),
          ],
        ),
        const SizedBox(height: 14),
        if (tasks.isEmpty)
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8)],
            ),
            child: const Center(
              child: Column(
                children: [
                  Icon(Icons.inbox_rounded, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No tasks assigned yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
          )
        else
          ...tasks.map((task) => _buildTaskCard(task)),
      ],
    );
  }

  // ─────────── TASK CARD ───────────
  Widget _buildTaskCard(Map<String, dynamic> task) {
    final int taskId = task['id'];
    final List<XFile> images = _taskImages[taskId] ?? [];
    final bool isCompleted = task['status'] == 'completed';
    final bool isInProgress = task['status'] == 'in_progress';

    Color statusColor = isCompleted
        ? Colors.green
        : isInProgress
            ? Colors.orange
            : Colors.blue;

    IconData statusIcon = isCompleted
        ? Icons.check_circle
        : isInProgress
            ? Icons.timelapse
            : Icons.pending;

    double progress = isCompleted ? 1 : isInProgress ? 0.6 : 0.2;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 12, offset: const Offset(0, 4))],
        border: isCompleted ? Border.all(color: Colors.green.shade200, width: 1) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(task['title'], style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      task['status'].toString().replaceAll('_', ' ').toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ],
          ),

          if (task['description'] != null && task['description'].toString().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(task['description'], style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ],

          // Show who completed it
          if (isCompleted && task['worker_name'] != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_pin, color: Colors.green.shade700, size: 16),
                  const SizedBox(width: 6),
                  Text('Completed by: ${task['worker_name']}', style: TextStyle(color: Colors.green.shade700, fontSize: 12, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Progress Bar
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

          // Images
          if (images.isEmpty)
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(10)),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, color: Colors.grey, size: 16),
                  SizedBox(width: 8),
                  Text('No images uploaded', style: TextStyle(color: Colors.grey, fontSize: 12)),
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
                        ? Image.network(images[i].path, width: 60, height: 60, fit: BoxFit.cover)
                        : Image.file(File(images[i].path), width: 60, height: 60, fit: BoxFit.cover),
                  ),
                ),
              ),
            ),

          if (!isCompleted) ...[
            const SizedBox(height: 12),
            // Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(taskId, ImageSource.camera),
                    icon: const Icon(Icons.camera_alt, size: 18),
                    label: Text('Camera (${images.length})'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _completeTask(task),
                    icon: const Icon(Icons.check, size: 18),
                    label: const Text('Complete'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ─────────── IMAGE PICKER ───────────
  Future<void> _pickImage(int taskId, ImageSource source) async {
    try {
      final XFile? img = await _picker.pickImage(source: source, preferredCameraDevice: CameraDevice.rear, imageQuality: 80);
      if (img != null) {
        setState(() {
          _taskImages.putIfAbsent(taskId, () => []);
          _taskImages[taskId]!.add(img);
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(source == ImageSource.camera ? 'Photo captured!' : 'Image added!'), backgroundColor: Colors.green),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(kIsWeb && source == ImageSource.camera ? 'Camera requires HTTPS. Use gallery instead.' : 'Failed: $e'), backgroundColor: Colors.orange),
        );
      }
    }
  }

  // ─────────── COMPLETE TASK ───────────
  void _completeTask(Map<String, dynamic> task) async {
    final int taskId = task['id'];
    final images = _taskImages[taskId] ?? [];

    if (images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one image first'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      await ApiService.completeTask(taskId);
      await _fetchData(); // Refresh to see updated status and worker name
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task completed! 🎉'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error completing task: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // ─────────── NOTIFICATIONS ───────────
  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.notifications_active, color: Colors.indigo.shade600),
                        const SizedBox(width: 8),
                        const Text('Notifications', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        if (unreadCount > 0)
                          TextButton(
                            onPressed: () {
                              setState(() { for (var n in notifications) { n['isRead'] = true; } });
                              Navigator.pop(context);
                            },
                            child: const Text('Mark all read'),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: notifications.isEmpty
                    ? const Center(child: Text('No notifications', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: notifications.length,
                        itemBuilder: (context, index) {
                          final n = notifications[index];
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                            decoration: BoxDecoration(
                              color: n['isRead'] ? Colors.white : Colors.indigo.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: n['isRead'] ? Colors.grey.shade200 : Colors.indigo.shade200),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: Colors.indigo.shade100,
                                child: Icon(Icons.assignment, color: Colors.indigo.shade700),
                              ),
                              title: Text(
                                n['title'],
                                style: TextStyle(fontWeight: n['isRead'] ? FontWeight.normal : FontWeight.bold),
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
                              trailing: n['isRead'] ? null : Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.indigo, shape: BoxShape.circle)),
                              onTap: () => setState(() => n['isRead'] = true),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────── LOGOUT ───────────
  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 10), Text('Logout')]),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ApiService.logout();
              Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
