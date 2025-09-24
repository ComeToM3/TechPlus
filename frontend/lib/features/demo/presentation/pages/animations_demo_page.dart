import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/animations/animations.dart';
import '../../../../shared/widgets/buttons/animated_button.dart';

/// Page de démonstration des animations
class AnimationsDemoPage extends StatefulWidget {
  const AnimationsDemoPage({super.key});

  @override
  State<AnimationsDemoPage> createState() => _AnimationsDemoPageState();
}

class _AnimationsDemoPageState extends State<AnimationsDemoPage> {
  bool _showStaggeredList = false;
  bool _showShakeAnimation = false;
  bool _showPulseAnimation = false;
  bool _showBounceAnimation = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Démonstration des Animations'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section des animations de chargement
            _buildSection(
              title: 'Animations de Chargement',
              children: [
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    const LoadingSpinner(message: 'Chargement...'),
                    const PulsingLoader(message: 'Pulsation'),
                    const DotsLoader(message: 'Points'),
                    const BarsLoader(message: 'Barres'),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section des micro-interactions
            _buildSection(
              title: 'Micro-interactions',
              children: [
                const SizedBox(height: 16),
                Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    AnimatedTapWidget(
                      onTap: () => HapticFeedback.lightImpact(),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Tap Animation',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    HoverAnimationWidget(
                      onHover: () => HapticFeedback.selectionClick(),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Hover Animation',
                          style: TextStyle(
                            color: theme.colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    ShakeAnimationWidget(
                      shouldShake: _showShakeAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.error,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Shake Animation',
                          style: TextStyle(
                            color: theme.colorScheme.onError,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    PulseAnimationWidget(
                      isPulsing: _showPulseAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.tertiary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Pulse Animation',
                          style: TextStyle(
                            color: theme.colorScheme.onTertiary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    BounceAnimationWidget(
                      shouldBounce: _showBounceAnimation,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Bounce Animation',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(() => _showShakeAnimation = !_showShakeAnimation),
                      child: const Text('Toggle Shake'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => _showPulseAnimation = !_showPulseAnimation),
                      child: const Text('Toggle Pulse'),
                    ),
                    ElevatedButton(
                      onPressed: () => setState(() => _showBounceAnimation = !_showBounceAnimation),
                      child: const Text('Toggle Bounce'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section des animations d'éléments
            _buildSection(
              title: 'Animations d\'Éléments',
              children: [
                const SizedBox(height: 16),
                CustomAnimatedWidget(
                  config: AnimationConfig.fadeIn,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Fade In Animation'),
                  ),
                ),
                const SizedBox(height: 16),
                CustomAnimatedWidget(
                  config: AnimationConfig.slideInFromBottom,
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Slide In From Bottom'),
                  ),
                ),
                const SizedBox(height: 16),
                CustomAnimatedWidget(
                  config: AnimationConfig.scaleIn,
                  delay: const Duration(milliseconds: 400),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text('Scale In Animation'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section des animations de liste
            _buildSection(
              title: 'Animations de Liste',
              children: [
                const SizedBox(height: 16),
                AnimatedButton(
                  text: _showStaggeredList ? 'Masquer la Liste' : 'Afficher la Liste',
                  onPressed: () => setState(() => _showStaggeredList = !_showStaggeredList),
                  type: ButtonType.secondary,
                  isFullWidth: false,
                ),
                if (_showStaggeredList) ...[
                  const SizedBox(height: 16),
                  StaggeredListAnimation(
                    animationType: AnimationType.slideInFromBottom,
                    children: List.generate(5, (index) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text('Élément de liste ${index + 1}'),
                      );
                    }),
                  ),
                ],
              ],
            ),

            const SizedBox(height: 32),

            // Section des boutons avec états de chargement
            _buildSection(
              title: 'Boutons avec États de Chargement',
              children: [
                const SizedBox(height: 16),
                AnimatedButton(
                  text: 'Bouton Normal',
                  onPressed: () {},
                  type: ButtonType.primary,
                ),
                const SizedBox(height: 16),
                AnimatedButton(
                  text: 'Bouton en Chargement',
                  onPressed: _isLoading ? null : () {},
                  isLoading: _isLoading,
                  type: ButtonType.secondary,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    setState(() => _isLoading = !_isLoading);
                  },
                  child: Text(_isLoading ? 'Arrêter le Chargement' : 'Démarrer le Chargement'),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Section des transitions de page
            _buildSection(
              title: 'Transitions de Page',
              children: [
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () => _navigateWithTransition(
                        context,
                        const _DemoPage(title: 'Slide Up'),
                        PageTransitions.defaultRoute,
                      ),
                      child: const Text('Slide Up'),
                    ),
                    ElevatedButton(
                      onPressed: () => _navigateWithTransition(
                        context,
                        const _DemoPage(title: 'Slide Right'),
                        PageTransitions.detailRoute,
                      ),
                      child: const Text('Slide Right'),
                    ),
                    ElevatedButton(
                      onPressed: () => _navigateWithTransition(
                        context,
                        const _DemoPage(title: 'Fade'),
                        PageTransitions.settingsRoute,
                      ),
                      child: const Text('Fade'),
                    ),
                    ElevatedButton(
                      onPressed: () => _navigateWithTransition(
                        context,
                        const _DemoPage(title: 'Scale'),
                        PageTransitions.successRoute,
                      ),
                      child: const Text('Scale'),
                    ),
                    ElevatedButton(
                      onPressed: () => _navigateWithTransition(
                        context,
                        const _DemoPage(title: 'Modal'),
                        PageTransitions.modalRoute,
                      ),
                      child: const Text('Modal'),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  void _navigateWithTransition(
    BuildContext context,
    Widget page,
    Route Function(Widget) routeBuilder,
  ) {
    Navigator.of(context).push(routeBuilder(page));
  }
}

/// Page de démonstration simple pour les transitions
class _DemoPage extends StatelessWidget {
  final String title;

  const _DemoPage({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            const Text('Cette page démontre une transition de page.'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Retour'),
            ),
          ],
        ),
      ),
    );
  }
}
