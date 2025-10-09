import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../config/app_theme.dart';

/// Debug widget to show token information (for development/admin use)
class TokenInfoWidget extends StatefulWidget {
  final bool showInProduction;
  
  const TokenInfoWidget({
    super.key,
    this.showInProduction = false,
  });

  @override
  State<TokenInfoWidget> createState() => _TokenInfoWidgetState();
}

class _TokenInfoWidgetState extends State<TokenInfoWidget> {
  Map<String, dynamic>? _tokenInfo;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadTokenInfo();
  }

  Future<void> _loadTokenInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final tokenInfo = await authProvider.getTokenInfo();
      setState(() {
        _tokenInfo = tokenInfo;
      });
    } catch (e) {
      setState(() {
        _tokenInfo = {'error': e.toString()};
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Don't show in production unless explicitly enabled
    if (!widget.showInProduction && !const bool.fromEnvironment('dart.vm.product')) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: const EdgeInsets.all(AppSizes.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Token Information',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _loadTokenInfo,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: AppSizes.sm),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_tokenInfo != null) ...[
              if (_tokenInfo!.containsKey('error'))
                Text(
                  'Error: ${_tokenInfo!['error']}',
                  style: const TextStyle(color: Colors.red),
                )
              else ...[
                _buildInfoRow('Valid', _tokenInfo!['isValid']?.toString() ?? 'Unknown'),
                if (_tokenInfo!['tokenAge'] != null)
                  _buildInfoRow('Token Age', '${_tokenInfo!['tokenAge']} days'),
                if (_tokenInfo!['daysRemaining'] != null)
                  _buildInfoRow('Days Remaining', '${_tokenInfo!['daysRemaining']} days'),
                if (_tokenInfo!['expiryDate'] != null)
                  _buildInfoRow('Expires On', _tokenInfo!['expiryDate'].toString().split('.')[0]),
                if (_tokenInfo!['isExpired'] != null)
                  Container(
                    padding: const EdgeInsets.all(AppSizes.sm),
                    decoration: BoxDecoration(
                      color: _tokenInfo!['isExpired'] == true 
                          ? Colors.red.withOpacity(0.1)
                          : Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppSizes.radiusSm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _tokenInfo!['isExpired'] == true 
                              ? Icons.warning 
                              : Icons.check_circle,
                          color: _tokenInfo!['isExpired'] == true 
                              ? Colors.red 
                              : Colors.green,
                        ),
                        const SizedBox(width: AppSizes.sm),
                        Text(
                          _tokenInfo!['isExpired'] == true 
                              ? 'Token Expired' 
                              : 'Token Active',
                          style: TextStyle(
                            color: _tokenInfo!['isExpired'] == true 
                                ? Colors.red 
                                : Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(value),
        ],
      ),
    );
  }
}