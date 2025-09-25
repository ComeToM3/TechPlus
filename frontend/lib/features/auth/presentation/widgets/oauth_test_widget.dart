import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/oauth_test.dart';
import '../../../../core/config/oauth_config.dart';

/// Widget de test OAuth pour l'administration
class OAuthTestWidget extends ConsumerStatefulWidget {
  const OAuthTestWidget({super.key});

  @override
  ConsumerState<OAuthTestWidget> createState() => _OAuthTestWidgetState();
}

class _OAuthTestWidgetState extends ConsumerState<OAuthTestWidget> {
  Map<String, bool> _testResults = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runTests();
  }

  Future<void> _runTests() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await OAuthTest.testOAuthConfiguration();
      setState(() {
        _testResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors du test OAuth: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.security,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Test Configuration OAuth',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_isLoading)
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _runTests,
                    tooltip: 'Relancer les tests',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_testResults.isEmpty && !_isLoading)
              Text(
                'Aucun test effectué',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              )
            else
              ..._testResults.entries.map((entry) {
                final isConfigured = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        isConfigured ? Icons.check_circle : Icons.error,
                        size: 16,
                        color: isConfigured ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          entry.key,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      if (isConfigured)
                        Text(
                          'Configuré',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                      else
                        Text(
                          'Manquant',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                );
              }),
            const SizedBox(height: 16),
            if (_testResults.isNotEmpty)
              _buildSummary(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSummary(ThemeData theme) {
    final allConfigured = _testResults.values.every((configured) => configured);
    final configuredCount = _testResults.values.where((configured) => configured).length;
    final totalCount = _testResults.length;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: allConfigured 
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: allConfigured ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            allConfigured ? Icons.check_circle : Icons.warning,
            color: allConfigured ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allConfigured 
                      ? 'Configuration OAuth Complète'
                      : 'Configuration OAuth Incomplète',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: allConfigured ? Colors.green.shade700 : Colors.orange.shade700,
                  ),
                ),
                Text(
                  '$configuredCount/$totalCount éléments configurés',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: allConfigured ? Colors.green.shade600 : Colors.orange.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
