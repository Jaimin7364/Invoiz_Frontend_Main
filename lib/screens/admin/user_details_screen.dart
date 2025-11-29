import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/admin_service.dart';
import 'package:intl/intl.dart';

class UserDetailsScreen extends StatefulWidget {
  final String userId;

  const UserDetailsScreen({super.key, required this.userId});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final AdminService _adminService = AdminService();
  
  Map<String, dynamic>? _userDetails;
  bool _loading = true;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _loadUserDetails();
  }

  Future<void> _loadUserDetails() async {
    setState(() => _loading = true);

    try {
      final response = await _adminService.getUserDetails(widget.userId);
      print('User details response: ${response.isSuccess}');
      print('User details data: ${response.data}');
      
      if (mounted) {
        if (response.isSuccess && response.data != null) {
          setState(() {
            // Merge user data and transactions into single object for easier access
            final userData = response.data!['user'] as Map<String, dynamic>;
            final transactions = response.data!['transactions'];
            _userDetails = {
              ...userData,
              'transactions': transactions,
            };
            _loading = false;
          });
        } else {
          setState(() => _loading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message ?? 'Failed to load user details'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error loading user details: $e');
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading user details: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleAccountStatus() async {
    if (_userDetails == null || _processing) return;

    final currentStatus = _userDetails!['account_status'];
    final newStatus = currentStatus == 'Active' ? 'Suspended' : 'Active';
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${newStatus == 'Suspended' ? 'Suspend' : 'Activate'} Account'),
        content: Text(
          'Are you sure you want to ${newStatus == 'Suspended' ? 'suspend' : 'activate'} this account?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus == 'Suspended' ? Colors.red : Colors.green,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _processing = true);

    try {
      final response = newStatus == 'Suspended'
          ? await _adminService.deactivateAccount(
              userId: widget.userId,
              reason: 'Suspended by admin',
            )
          : await _adminService.activateAccount(userId: widget.userId);

      if (response.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Account ${newStatus == 'Suspended' ? 'suspended' : 'activated'} successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadUserDetails(); // Reload to get updated data
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to update account status'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  Future<void> _showExtendSubscriptionDialog() async {
    final daysController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Extend Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the number of days to extend the subscription:'),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Days',
                hintText: 'e.g., 30',
                border: OutlineInputBorder(),
                suffixText: 'days',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will extend the subscription end date.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (daysController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Extend'),
          ),
        ],
      ),
    );

    if (confirmed == true && daysController.text.isNotEmpty) {
      final days = int.tryParse(daysController.text);
      if (days != null && days > 0) {
        await _modifySubscription(days, isExtend: true);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid number of days'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    daysController.dispose();
  }

  Future<void> _showReduceSubscriptionDialog() async {
    final daysController = TextEditingController();
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reduce Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter the number of days to reduce from the subscription:'),
            const SizedBox(height: 16),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Days',
                hintText: 'e.g., 10',
                border: OutlineInputBorder(),
                suffixText: 'days',
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This will reduce the subscription end date.',
              style: TextStyle(fontSize: 12, color: Colors.orange),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (daysController.text.isNotEmpty) {
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Reduce'),
          ),
        ],
      ),
    );

    if (confirmed == true && daysController.text.isNotEmpty) {
      final days = int.tryParse(daysController.text);
      if (days != null && days > 0) {
        await _modifySubscription(days, isExtend: false);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid number of days'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
    daysController.dispose();
  }

  Future<void> _modifySubscription(int days, {required bool isExtend}) async {
    setState(() => _processing = true);

    try {
      final response = await _adminService.modifySubscription(
        userId: widget.userId,
        days: days,
        isExtend: isExtend,
      );

      if (response.isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Subscription ${isExtend ? 'extended' : 'reduced'} by $days days successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        _loadUserDetails(); // Reload to get updated data
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? 'Failed to modify subscription'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _processing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Details'),
        actions: [
          if (_userDetails != null && !_processing)
            IconButton(
              icon: Icon(
                _userDetails!['account_status'] == 'Active'
                    ? Icons.block
                    : Icons.check_circle,
              ),
              onPressed: _toggleAccountStatus,
              tooltip: _userDetails!['account_status'] == 'Active'
                  ? 'Suspend Account'
                  : 'Activate Account',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUserDetails,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _userDetails == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Failed to load user details'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadUserDetails,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildUserInfoCard(),
                      const SizedBox(height: 16),
                      _buildSubscriptionCard(),
                      const SizedBox(height: 16),
                      _buildTransactionsCard(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildUserInfoCard() {
    final user = _userDetails!;
    final accountStatus = user['account_status'];
    
    Color statusColor = Colors.grey;
    if (accountStatus == 'Active') statusColor = Colors.green;
    if (accountStatus == 'Suspended') statusColor = Colors.red;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('User Information', style: AppTextStyles.h4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: statusColor, width: 2),
                  ),
                  child: Text(
                    accountStatus,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(),
            _buildInfoRow('Name', user['full_name'] ?? 'N/A'),
            _buildInfoRow('Email', user['email'] ?? 'N/A'),
            _buildInfoRow('Mobile', user['mobile_number'] ?? 'N/A'),
            _buildInfoRow('User Type', user['user_type'] ?? 'N/A'),
            _buildInfoRow('Role', user['role'] ?? 'N/A'),
            _buildInfoRow(
              'Created At',
              user['created_at'] != null
                  ? DateFormat('MMM dd, yyyy HH:mm').format(DateTime.parse(user['created_at']))
                  : 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    final subscription = _userDetails!['subscription'];
    final hasActive = _userDetails!['has_active_subscription'] ?? false;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subscription Details', style: AppTextStyles.h4),
                if (subscription != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: hasActive
                          ? Colors.green.withOpacity(0.2)
                          : Colors.orange.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: hasActive ? Colors.green : Colors.orange,
                        width: 2,
                      ),
                    ),
                    child: Text(
                      hasActive ? 'Active' : 'Expired',
                      style: TextStyle(
                        color: hasActive ? Colors.green : Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const Divider(),
            if (subscription == null)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No subscription found'),
                ),
              )
            else ...[
              _buildInfoRow('Plan Name', subscription['plan_name'] ?? 'N/A'),
              _buildInfoRow('Plan Type', subscription['plan_type'] ?? 'N/A'),
              _buildInfoRow('Amount', '₹${subscription['amount'] ?? 0}'),
              _buildInfoRow(
                'Start Date',
                subscription['start_date'] != null
                    ? DateFormat('MMM dd, yyyy').format(DateTime.parse(subscription['start_date']))
                    : 'N/A',
              ),
              _buildInfoRow(
                'End Date',
                subscription['end_date'] != null
                    ? DateFormat('MMM dd, yyyy').format(DateTime.parse(subscription['end_date']))
                    : 'N/A',
              ),
              if (subscription['end_date'] != null) ...[
                const SizedBox(height: 12),
                if (hasActive) ...[
                  // Show remaining days for active subscription
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.timer, color: Colors.green, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${_getRemainingDays(DateTime.parse(subscription['end_date']))} days remaining',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Show expired message
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Expired ${_getTimeAgo(DateTime.parse(subscription['end_date']))}',
                          style: const TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              // Subscription modification buttons (only show if subscription exists)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _processing ? null : () => _showExtendSubscriptionDialog(),
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Extend'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: const BorderSide(color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _processing ? null : () => _showReduceSubscriptionDialog(),
                      icon: const Icon(Icons.remove_circle_outline),
                      label: const Text('Reduce'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.orange,
                        side: const BorderSide(color: Colors.orange),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionsCard() {
    final transactions = _userDetails!['transactions'] as List? ?? [];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Transaction History', style: AppTextStyles.h4),
            const Divider(),
            if (transactions.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('No transactions found'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: transactions.length,
                itemBuilder: (context, index) {
                  final transaction = transactions[index];
                  return _buildTransactionItem(transaction);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    final status = transaction['status'] ?? transaction['payment_status'] ?? 'Unknown';
    Color statusColor = Colors.grey;
    if (status == 'Success' || status == 'success' || status == 'completed') statusColor = Colors.green;
    if (status == 'Failed' || status == 'failed') statusColor = Colors.red;
    if (status == 'Pending' || status == 'pending') statusColor = Colors.orange;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: statusColor.withOpacity(0.2),
        child: Icon(Icons.receipt, color: statusColor),
      ),
      title: Text(
        transaction['plan_name'] ?? 'N/A',
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        DateFormat('MMM dd, yyyy HH:mm').format(
          DateTime.parse(transaction['created_at']),
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '₹${transaction['amount'] ?? 0}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: statusColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _getRemainingDays(DateTime endDate) {
    final now = DateTime.now();
    final difference = endDate.difference(now);
    return difference.inDays;
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${difference.inDays ~/ 365 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${difference.inDays ~/ 30 > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'just now';
    }
  }
}
