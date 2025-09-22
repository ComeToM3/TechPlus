import 'package:flutter/material.dart';
import 'accessible_button.dart';
import 'accessible_text_field.dart';
import '../../../core/accessibility/screen_reader_service.dart';

/// Démonstration des composants accessibles
class AccessibilityDemo extends StatefulWidget {
  const AccessibilityDemo({super.key});

  @override
  State<AccessibilityDemo> createState() => _AccessibilityDemoState();
}

class _AccessibilityDemoState extends State<AccessibilityDemo> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final List<FocusNode> _focusNodes = [];
  int _currentSection = 0;

  @override
  void initState() {
    super.initState();
    // Créer les focus nodes pour la navigation au clavier
    for (int i = 0; i < 5; i++) {
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _handleButtonPress(String buttonName) {
    ScreenReaderService.announceAction('Bouton pressé', target: buttonName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$buttonName pressé'),
        action: SnackBarAction(
          label: 'Annuler',
          onPressed: () {
            ScreenReaderService.announceAction('Action annulée');
          },
        ),
      ),
    );
  }

  void _handleFormSubmit() {
    if (_emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty) {
      ScreenReaderService.announceSuccess('Formulaire soumis avec succès');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Formulaire soumis avec succès')),
      );
    } else {
      ScreenReaderService.announceError('Veuillez remplir tous les champs');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Démonstration Accessibilité'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              ScreenReaderService.announceInfo('Aide sur l\'accessibilité');
              _showAccessibilityHelp();
            },
            tooltip: 'Aide sur l\'accessibilité',
          ),
        ],
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section 1: Boutons accessibles
              _buildSection(
                title: 'Boutons Accessibles',
                child: Column(
                  children: [
                    AccessibleButton(
                      text: 'Bouton Principal',
                      onPressed: () => _handleButtonPress('Principal'),
                      icon: Icons.star,
                      semanticLabel: 'Bouton principal avec icône étoile',
                    ),
                    const SizedBox(height: 16),
                    AccessibleButton(
                      text: 'Bouton Secondaire',
                      onPressed: () => _handleButtonPress('Secondaire'),
                      type: ButtonType.secondary,
                      semanticLabel: 'Bouton secondaire',
                    ),
                    const SizedBox(height: 16),
                    AccessibleButton(
                      text: 'Bouton Outline',
                      onPressed: () => _handleButtonPress('Outline'),
                      type: ButtonType.outline,
                      semanticLabel: 'Bouton avec contour',
                    ),
                    const SizedBox(height: 16),
                    AccessibleButton(
                      text: 'Bouton Texte',
                      onPressed: () => _handleButtonPress('Texte'),
                      type: ButtonType.text,
                      semanticLabel: 'Bouton texte uniquement',
                    ),
                    const SizedBox(height: 16),
                    AccessibleButton(
                      text: 'Bouton Chargement',
                      onPressed: null,
                      isLoading: true,
                      semanticLabel: 'Bouton en cours de chargement',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Section 2: Champs de texte accessibles
              _buildSection(
                title: 'Champs de Texte Accessibles',
                child: Column(
                  children: [
                    AccessibleEmailField(
                      label: 'Adresse Email',
                      hint: 'Entrez votre adresse email',
                      controller: _emailController,
                      semanticLabel: 'Champ pour l\'adresse email',
                    ),
                    const SizedBox(height: 16),
                    AccessiblePasswordField(
                      label: 'Mot de Passe',
                      hint: 'Entrez votre mot de passe',
                      controller: _passwordController,
                      semanticLabel: 'Champ pour le mot de passe',
                    ),
                    const SizedBox(height: 16),
                    AccessibleTextField(
                      label: 'Nom Complet',
                      hint: 'Entrez votre nom complet',
                      semanticLabel: 'Champ pour le nom complet',
                      required: true,
                    ),
                    const SizedBox(height: 16),
                    AccessibleTextField(
                      label: 'Téléphone',
                      hint: 'Entrez votre numéro de téléphone',
                      keyboardType: TextInputType.phone,
                      semanticLabel: 'Champ pour le numéro de téléphone',
                    ),
                    const SizedBox(height: 24),
                    AccessibleButton(
                      text: 'Soumettre le Formulaire',
                      onPressed: _handleFormSubmit,
                      icon: Icons.send,
                      semanticLabel: 'Soumettre le formulaire de contact',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Section 3: Navigation par sections
              _buildSection(
                title: 'Navigation par Sections',
                child: Column(
                  children: [
                    _buildDemoSection('Section 1', Colors.blue),
                    _buildDemoSection('Section 2', Colors.green),
                    _buildDemoSection('Section 3', Colors.orange),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Section 4: Informations d'accessibilité
              _buildSection(
                title: 'Informations d\'Accessibilité',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoCard(
                      icon: Icons.contrast,
                      title: 'Contraste des Couleurs',
                      description:
                          'Tous les éléments respectent le ratio de contraste WCAG 2.1 AA (4.5:1 minimum)',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.touch_app,
                      title: 'Touch Targets',
                      description:
                          'Tous les éléments interactifs ont une taille minimale de 44x44 points',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.keyboard,
                      title: 'Navigation au Clavier',
                      description:
                          'Utilisez Tab, Shift+Tab, et les flèches pour naviguer',
                    ),
                    const SizedBox(height: 16),
                    _buildInfoCard(
                      icon: Icons.hearing,
                      title: 'Lecteurs d\'Écran',
                      description:
                          'Tous les éléments sont annoncés aux lecteurs d\'écran',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        child,
      ],
    );
  }

  Widget _buildDemoSection(String title, Color color) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, size: 48, color: color),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Contenu de la $title',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAccessibilityHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Aide sur l\'Accessibilité'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Cette démonstration montre les fonctionnalités d\'accessibilité implémentées selon les standards WCAG 2.1 AA:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text('• Contraste des couleurs (4.5:1 minimum)'),
              Text('• Touch targets de 44x44 points minimum'),
              Text('• Navigation au clavier complète'),
              Text('• Support des lecteurs d\'écran'),
              Text('• Labels sémantiques appropriés'),
              Text('• Animations respectant les limites WCAG'),
              SizedBox(height: 16),
              Text(
                'Utilisez Tab pour naviguer, Entrée pour activer, et Échap pour revenir.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScreenReaderService.announce('Aide fermée');
              Navigator.of(context).pop();
            },
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}
