import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smart_civic/screens/login_screen.dart';
import 'package:smart_civic/screens/map_screen.dart';
import 'package:smart_civic/services/api_service.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<dynamic> _tasks = [];
  List<dynamic> _workers = [];
  List<dynamic> _alerts = [];
  List<dynamic> _attendance = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Auto-refresh every 10 seconds
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) => _fetchData());
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final tasksRes = await ApiService.getTasks();
      final workersRes = await ApiService.getWorkers();
      final alertsRes = await ApiService.getAlerts();
      final attRes = await ApiService.getAttendance();

      if (mounted) {
        setState(() {
          _tasks = tasksRes;
          _workers = workersRes;
          _alerts = alertsRes;
          _attendance = attRes;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  int get _activeWorkers => _workers.where((w) => w['duty_status'] == 'active').length;
  int get _inactiveWorkers => _workers.where((w) => w['duty_status'] != 'active').length;
  int get _completedTasks => _tasks.where((t) => t['status'] == 'completed').length;
  int get _pendingTasks => _tasks.where((t) => t['status'] == 'pending').length;
  int get _inProgressTasks => _tasks.where((t) => t['status'] == 'in_progress').length;

  @override
  Widget build(BuildContext context) {
    final adminName = ApiService.currentUser?['name'] ?? 'Admin';

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade700, Colors.indigo.shade500],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('SmartCivic', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('Welcome, $adminName', style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() => _isLoading = true);
              _fetchData();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => _showProfileMenu(context),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: Text(
                  adminName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
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
                    // Stats Cards
                    _buildStatsGrid(),
                    const SizedBox(height: 20),

                    // Action Buttons
                    _buildActionButtons(context),
                    const SizedBox(height: 24),

                    // Worker Table
                    _buildWorkerSection(),
                    const SizedBox(height: 24),

                    // Attendance Table
                    _buildAttendanceSection(),
                    const SizedBox(height: 24),

                    // Tasks Section
                    _buildTasksSection(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateTaskDialog(context),
        backgroundColor: Colors.indigo.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task),
        label: const Text('New Task'),
        elevation: 6,
      ),
    );
  }

  // ─────────── STATS GRID ───────────
  Widget _buildStatsGrid() {
    return Row(
      children: [
        _buildStatCard(
          icon: Icons.people_alt_rounded,
          label: 'Total Workers',
          value: '${_workers.length}',
          gradient: [const Color(0xFF667EEA), const Color(0xFF764BA2)],
          subtitle: '${_activeWorkers} active • ${_inactiveWorkers} off-duty',
        ),
        const SizedBox(width: 16),
        _buildStatCard(
          icon: Icons.task_alt_rounded,
          label: 'Total Tasks',
          value: '${_tasks.length}',
          gradient: [const Color(0xFF11998E), const Color(0xFF38EF7D)],
          subtitle: '$_completedTasks done • $_pendingTasks pending',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
    required String subtitle,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white.withOpacity(0.9), size: 28),
            const SizedBox(height: 12),
            Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 13, color: Colors.white70, fontWeight: FontWeight.w500)),
            const SizedBox(height: 6),
            Text(subtitle, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.6))),
          ],
        ),
      ),
    );
  }

  // ─────────── ACTION BUTTONS ───────────
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildGlassButton(
            icon: Icons.map_outlined,
            label: 'Live Map View',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen())),
          ),
        ),
        const SizedBox(width: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(
            children: [
              Icon(Icons.cleaning_services, color: Colors.indigo.shade600, size: 20),
              const SizedBox(width: 8),
              const Text('Sanitation', style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade600, Colors.indigo.shade400],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────── WORKER TABLE ───────────
  Widget _buildWorkerSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.badge_outlined, color: Colors.indigo.shade600),
                ),
                const SizedBox(width: 10),
                const Text('Worker Details', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${_workers.length} Total', style: TextStyle(fontSize: 12, color: Colors.indigo.shade700, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade50,
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Worker Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                Expanded(child: Text('Email', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                Expanded(child: Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          if (_workers.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(Icons.person_off_rounded, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No workers registered yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else
            ..._workers.map((w) => _buildWorkerRow(w)),
        ],
      ),
    );
  }

  Widget _buildWorkerRow(Map<String, dynamic> worker) {
    final isActive = worker['duty_status'] == 'active';
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
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isActive
                          ? [Colors.green.shade300, Colors.green.shade500]
                          : [Colors.grey.shade300, Colors.grey.shade400],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (worker['name'] ?? 'W')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(child: Text(worker['email'] ?? 'Unknown', overflow: TextOverflow.ellipsis)),
              ],
            ),
          ),
          Expanded(
            child: Text(
              worker['email'] ?? '-',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.shade50 : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: isActive ? Colors.green.shade200 : Colors.orange.shade200),
                ),
                child: Text(
                  isActive ? '● Active' : '○ Off-duty',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── ATTENDANCE TABLE ───────────
  Widget _buildAttendanceSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.co_present_outlined, color: Colors.teal.shade600),
                ),
                const SizedBox(width: 10),
                const Text('Live Attendance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text('${_attendance.length} Records', style: TextStyle(fontSize: 12, color: Colors.teal.shade700, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.grey.shade50,
            child: const Row(
              children: [
                Expanded(flex: 2, child: Text('Worker Name', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                Expanded(child: Text('Date', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                Expanded(child: Text('Check-in', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                Expanded(child: Text('Status', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
              ],
            ),
          ),
          if (_attendance.isEmpty)
            const Padding(
              padding: EdgeInsets.all(30),
              child: Column(
                children: [
                  Icon(Icons.history_toggle_off, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('No attendance records yet', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          else
            ..._attendance.take(10).map((a) => _buildAttendanceRow(a)),
        ],
      ),
    );
  }

  Widget _buildAttendanceRow(Map<String, dynamic> record) {
    final status = record['status'] ?? 'unknown';
    final isPresent = status == 'present';

    // Format Date (e.g., 2023-10-25T... => 2023-10-25)
    String dateStr = record['date'] ?? '-';
    if (dateStr.contains('T')) {
      dateStr = dateStr.split('T')[0];
    }
    
    // Format Time (e.g., 09:00:00 => 09:00)
    String timeStr = record['check_in_time'] ?? '-';
    if (timeStr.length > 5 && timeStr.contains(':')) {
      final parts = timeStr.split(':');
      timeStr = '${parts[0]}:${parts[1]}';
    }

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
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      (record['name'] ?? 'W')[0].toUpperCase(),
                      style: TextStyle(color: Colors.teal.shade700, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Flexible(child: Text(record['name'] ?? 'Unknown', overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w500))),
              ],
            ),
          ),
          Expanded(
            child: Text(
              dateStr,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            ),
          ),
          Expanded(
            child: Text(
              timeStr,
              style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isPresent ? Colors.teal.shade50 : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isPresent ? Colors.teal.shade700 : Colors.red.shade700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────── TASKS SECTION ───────────
  Widget _buildTasksSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
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
              const Text('Daily Tasks', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Progress Ring
              SizedBox(
                width: 120,
                height: 120,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: _tasks.isEmpty ? 0 : _completedTasks / _tasks.length,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo.shade600),
                      strokeCap: StrokeCap.round,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${_completedTasks}/${_tasks.length}',
                            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                          ),
                          const Text('Tasks', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 30),
              Expanded(
                child: Column(
                  children: [
                    _buildTaskStat('Completed', '$_completedTasks', Colors.green, Icons.check_circle),
                    const SizedBox(height: 12),
                    _buildTaskStat('Pending', '$_pendingTasks', Colors.orange, Icons.pending),
                    const SizedBox(height: 12),
                    _buildTaskStat('In Progress', '$_inProgressTasks', Colors.blue, Icons.work),
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
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  // ─────────── CREATE TASK DIALOG ───────────
  void _showCreateTaskDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    bool isLoading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 24, right: 24, top: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
                  const SizedBox(height: 20),
                  const Text('Create New Task', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  TextField(controller: titleCtrl, decoration: InputDecoration(labelText: 'Task Title', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 16),
                  TextField(controller: descCtrl, maxLines: 3, decoration: InputDecoration(labelText: 'Description', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: isLoading ? null : () async {
                        if (titleCtrl.text.isEmpty) return;
                        setModalState(() => isLoading = true);
                        try {
                          await ApiService.createTask(title: titleCtrl.text, description: descCtrl.text, latitude: 19.0760, longitude: 72.8777);
                          if (mounted) {
                            Navigator.pop(ctx);
                            _fetchData();
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Task created!'), backgroundColor: Colors.green));
                          }
                        } catch (e) {
                          setModalState(() => isLoading = false);
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
                          }
                        }
                      },
                      child: isLoading ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('Create Task'),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─────────── PROFILE MENU ───────────
  void _showProfileMenu(BuildContext context) {
    final adminName = ApiService.currentUser?['name'] ?? 'Admin';
    final adminEmail = ApiService.currentUser?['email'] ?? 'admin@smartcivic.com';
    final pendingCount = _tasks.where((t) => t['status'] == 'pending').length;
    final totalNotifs = pendingCount + _alerts.length;
    final slaText = _tasks.isEmpty ? 'No data' : '${((_completedTasks / _tasks.length) * 100).toStringAsFixed(0)}%';

    // Get the position of the avatar button to anchor popup near it
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width - 300, // right-aligned, 300px wide
        kToolbarHeight + 8,
        8,
        0,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      constraints: const BoxConstraints(minWidth: 280, maxWidth: 300),
      items: <PopupMenuEntry<dynamic>>[
        // Profile header
        PopupMenuItem(
          enabled: false,
          child: Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.indigo.shade100,
                child: Text(adminName[0].toUpperCase(), style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.indigo.shade700)),
              ),
              const SizedBox(height: 8),
              Text(adminName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
              Text(adminEmail, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              const SizedBox(height: 4),
            ],
          ),
        ),
        const PopupMenuDivider(),
        // Notifications
        PopupMenuItem(
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.notifications, color: Colors.blue.shade700, size: 22),
            title: const Text('Notifications', style: TextStyle(fontSize: 14)),
            trailing: totalNotifs > 0 ? Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10)),
              child: Text('$totalNotifs', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
            ) : null,
          ),
          onTap: () => Future.delayed(Duration.zero, () => _showNotificationsDialog(context)),
        ),
        // SLA
        PopupMenuItem(
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.analytics, color: Colors.green.shade700, size: 22),
            title: const Text('SLA Compliance', style: TextStyle(fontSize: 14)),
            trailing: Text(slaText, style: TextStyle(color: Colors.green.shade700, fontWeight: FontWeight.bold, fontSize: 13)),
          ),
          onTap: () => Future.delayed(Duration.zero, () => _showSlaDialog(context)),
        ),
        const PopupMenuDivider(),
        // Logout
        PopupMenuItem(
          child: const ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout, color: Colors.red, size: 22),
            title: Text('Logout', style: TextStyle(color: Colors.red, fontSize: 14)),
          ),
          onTap: () {
            ApiService.logout();
            Future.delayed(Duration.zero, () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
            });
          },
        ),
      ],
    );
  }

  // ─────────── NOTIFICATIONS SCREEN ───────────
  void _showNotificationsDialog(BuildContext context) {
    final pendingTasks = _tasks.where((t) => t['status'] == 'pending').toList();
    
    // Combine pending tasks and actual alerts
    List<Map<String, dynamic>> combinedNotifications = [];
    
    for (var a in _alerts) {
      combinedNotifications.add({
        'type': 'alert',
        'title': (a['type'] ?? 'Alert').toString().toUpperCase(),
        'message': a['message'] ?? 'Action required',
        'worker': a['worker_name'],
        'time': a['created_at'],
      });
    }
    
    for (var t in pendingTasks) {
      combinedNotifications.add({
        'type': 'task',
        'title': 'Pending Task: ${t['title']}',
        'message': 'Task is waiting for a worker to start.',
        'worker': null,
        'time': t['created_at'],
      });
    }

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxHeight: 500),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active, color: Colors.indigo.shade600),
                    const SizedBox(width: 8),
                    const Text('Notifications & Alerts', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(12)),
                      child: Text('${combinedNotifications.length} New', style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.bold, fontSize: 12)),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                const Divider(),
                if (combinedNotifications.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32),
                    child: Center(child: Text("All caught up! 🎉", style: TextStyle(color: Colors.grey, fontSize: 16))),
                  )
                else
                  Flexible(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: combinedNotifications.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final notif = combinedNotifications[index];
                        final isAlert = notif['type'] == 'alert';
                        
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: isAlert ? Colors.orange.shade50 : Colors.indigo.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              isAlert ? Icons.warning_amber_rounded : Icons.assignment_late,
                              color: isAlert ? Colors.orange.shade700 : Colors.indigo.shade700,
                              size: 20,
                            ),
                          ),
                          title: Text(notif['title'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(notif['message'], style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                              if (notif['worker'] != null) ...[
                                const SizedBox(height: 4),
                                Text('Worker: ${notif['worker']}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500)),
                              ]
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigo.shade50,
                      foregroundColor: Colors.indigo.shade700,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────── SLA COMPLIANCE SCREEN ───────────
  void _showSlaDialog(BuildContext context) {
    final completionRate = _tasks.isEmpty ? 0.0 : (_completedTasks / _tasks.length) * 100;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.analytics, color: Colors.green.shade700),
                    const SizedBox(width: 8),
                    const Text('SLA Compliance', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                SizedBox(
                  width: 140, height: 140,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CircularProgressIndicator(
                        value: completionRate / 100,
                        strokeWidth: 14,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          completionRate >= 80 ? Colors.green : completionRate >= 50 ? Colors.orange : Colors.red,
                        ),
                        strokeCap: StrokeCap.round,
                      ),
                      Center(
                        child: Text('${completionRate.toStringAsFixed(0)}%', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                _buildSlaRow('Total Tasks', '${_tasks.length}', Colors.indigo),
                _buildSlaRow('Completed', '$_completedTasks', Colors.green),
                _buildSlaRow('Pending', '$_pendingTasks', Colors.orange),
                _buildSlaRow('In Progress', '$_inProgressTasks', Colors.blue),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSlaRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 14)),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
