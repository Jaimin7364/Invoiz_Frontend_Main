import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/admin_service.dart';
import 'user_details_screen.dart';

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({super.key});

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AdminService _adminService = AdminService();

  Map<String, dynamic>? _stats;
  bool _loadingStats = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadStats();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadStats() async {
    try {
      final response = await _adminService.getAdminStats();
      if (response.isSuccess && mounted) {
        setState(() {
          _stats = response.data;
          _loadingStats = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loadingStats = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Panel'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Dashboard', icon: Icon(Icons.dashboard)),
            Tab(text: 'Users', icon: Icon(Icons.people)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDashboardTab(),
          const UserManagementTab(),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    if (_loadingStats) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_stats == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Failed to load statistics'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    final users = _stats!['users'] as Map<String, dynamic>;
    final subscriptions = _stats!['subscriptions'] as Map<String, dynamic>;
    final revenue = _stats!['revenue'] as Map<String, dynamic>;

    return RefreshIndicator(
      onRefresh: _loadStats,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Statistics Overview',
              style: AppTextStyles.h3,
            ),
            const SizedBox(height: 16),
            
            // User Stats
            _buildStatCard(
              title: 'Users',
              stats: [
                StatItem('Total', users['total'].toString(), Icons.people),
                StatItem('Active', users['active'].toString(), Icons.check_circle, Colors.green),
                StatItem('Suspended', users['suspended'].toString(), Icons.block, Colors.red),
                StatItem('Inactive', users['inactive'].toString(), Icons.circle_outlined, Colors.grey),
              ],
            ),
            const SizedBox(height: 16),

            // Subscription Stats
            _buildStatCard(
              title: 'Subscriptions',
              stats: [
                StatItem('Active', subscriptions['active'].toString(), Icons.verified, Colors.green),
                StatItem('Expired', subscriptions['expired'].toString(), Icons.hourglass_empty, Colors.orange),
                StatItem('No Subscription', subscriptions['none'].toString(), Icons.not_interested, Colors.grey),
              ],
            ),
            const SizedBox(height: 16),

            // Revenue Stats
            _buildStatCard(
              title: 'Revenue (Last 30 Days)',
              stats: [
                StatItem('Total Revenue', '₹${revenue['last_30_days'].toStringAsFixed(2)}', Icons.currency_rupee, AppColors.primary),
                StatItem('Transactions', revenue['transactions_count'].toString(), Icons.receipt, AppColors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({required String title, required List<StatItem> stats}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.h4,
            ),
            const Divider(),
            ...stats.map((stat) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(stat.icon, color: stat.color, size: 20),
                      const SizedBox(width: 8),
                      Text(stat.label, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                  Text(
                    stat.value,
                    style: AppTextStyles.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                      color: stat.color,
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class StatItem {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;

  StatItem(this.label, this.value, this.icon, [this.color]);
}

class UserManagementTab extends StatefulWidget {
  const UserManagementTab({super.key});

  @override
  State<UserManagementTab> createState() => _UserManagementTabState();
}

class _UserManagementTabState extends State<UserManagementTab> {
  final AdminService _adminService = AdminService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _users = [];
  bool _loading = true;
  int _currentPage = 1;
  int _totalPages = 1;
  String _subscriptionFilter = 'all';
  String _accountStatusFilter = 'all';

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _loading = true);

    try {
      final response = await _adminService.getUsers(
        page: _currentPage,
        search: _searchController.text,
        subscriptionStatus: _subscriptionFilter,
        accountStatus: _accountStatusFilter,
      );

      if (response.isSuccess && mounted) {
        setState(() {
          _users = response.data!['users'];
          final pagination = response.data!['pagination'];
          _totalPages = pagination['total_pages'];
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading users: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search and Filters
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search by name, email, or mobile',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      _loadUsers();
                    },
                  ),
                ),
                onSubmitted: (_) => _loadUsers(),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _subscriptionFilter,
                      decoration: const InputDecoration(
                        labelText: 'Subscription',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'expired', child: Text('Expired')),
                        DropdownMenuItem(value: 'none', child: Text('None')),
                      ],
                      onChanged: (value) {
                        setState(() => _subscriptionFilter = value!);
                        _loadUsers();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _accountStatusFilter,
                      decoration: const InputDecoration(
                        labelText: 'Account Status',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All')),
                        DropdownMenuItem(value: 'Active', child: Text('Active')),
                        DropdownMenuItem(value: 'Suspended', child: Text('Suspended')),
                        DropdownMenuItem(value: 'Inactive', child: Text('Inactive')),
                      ],
                      onChanged: (value) {
                        setState(() => _accountStatusFilter = value!);
                        _loadUsers();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Users List
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _users.isEmpty
                  ? const Center(child: Text('No users found'))
                  : RefreshIndicator(
                      onRefresh: _loadUsers,
                      child: ListView.builder(
                        itemCount: _users.length,
                        itemBuilder: (context, index) {
                          final user = _users[index];
                          return _buildUserCard(user);
                        },
                      ),
                    ),
        ),

        // Pagination
        if (_totalPages > 1)
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 1
                      ? () {
                          setState(() => _currentPage--);
                          _loadUsers();
                        }
                      : null,
                ),
                Text('Page $_currentPage of $_totalPages'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _currentPage < _totalPages
                      ? () {
                          setState(() => _currentPage++);
                          _loadUsers();
                        }
                      : null,
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final subscription = user['subscription'];
    final hasActiveSubscription = user['has_active_subscription'] ?? false;
    final accountStatus = user['account_status'];

    Color statusColor = Colors.grey;
    if (accountStatus == 'Active') statusColor = Colors.green;
    if (accountStatus == 'Suspended') statusColor = Colors.red;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withOpacity(0.2),
          child: Icon(
            Icons.person,
            color: statusColor,
          ),
        ),
        title: Text(
          user['full_name'] ?? 'Unknown',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(user['email'] ?? ''),
            const SizedBox(height: 4),
            Row(
              children: [
                _buildStatusChip(accountStatus, statusColor),
                const SizedBox(width: 8),
                if (subscription != null)
                  _buildStatusChip(
                    hasActiveSubscription ? 'Subscribed' : 'Expired',
                    hasActiveSubscription ? Colors.green : Colors.orange,
                  ),
              ],
            ),
          ],
        ),
        isThreeLine: true,
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _navigateToUserDetails(user),
      ),
    );
  }

  Widget _buildStatusChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _navigateToUserDetails(Map<String, dynamic> user) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(userId: user['_id']),
      ),
    ).then((_) => _loadUsers()); // Refresh list when coming back
  }
}
