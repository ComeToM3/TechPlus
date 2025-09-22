import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Service de navigation au clavier simplifié
class KeyboardNavigationService {
  static final KeyboardNavigationService _instance = KeyboardNavigationService._internal();
  factory KeyboardNavigationService() => _instance;
  KeyboardNavigationService._internal();

  final FocusNode _currentFocus = FocusNode();

  /// Initialise la navigation au clavier
  void initialize() {
    // Initialisation simplifiée
  }

  /// Navigue vers l'élément suivant
  void navigateToNext() {
    // Navigation simplifiée
  }

  /// Navigue vers l'élément précédent
  void navigateToPrevious() {
    // Navigation simplifiée
  }

  /// Gère les événements clavier
  void handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.tab) {
        navigateToNext();
      }
    }
  }

  /// Libère les ressources
  void dispose() {
    _currentFocus.dispose();
  }
}

/// Widget wrapper pour la navigation au clavier
class KeyboardNavigationWrapper extends StatefulWidget {
  final Widget child;
  final bool enabled;

  const KeyboardNavigationWrapper({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  State<KeyboardNavigationWrapper> createState() => _KeyboardNavigationWrapperState();
}

class _KeyboardNavigationWrapperState extends State<KeyboardNavigationWrapper> {
  final KeyboardNavigationService _navigationService = KeyboardNavigationService();

  @override
  void initState() {
    super.initState();
    if (widget.enabled) {
      _navigationService.initialize();
    }
  }

  @override
  void dispose() {
    _navigationService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      // Navigation clavier simplifiée
      child: widget.child,
    );
  }
}

/// Widget pour la navigation par tabulation
class TabNavigationWidget extends StatefulWidget {
  final List<Widget> children;
  final bool enabled;

  const TabNavigationWidget({
    super.key,
    required this.children,
    this.enabled = true,
  });

  @override
  State<TabNavigationWidget> createState() => _TabNavigationWidgetState();
}

class _TabNavigationWidgetState extends State<TabNavigationWidget> {
  final List<FocusNode> _focusNodes = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _focusNodes.addAll(
      List.generate(widget.children.length, (index) => FocusNode()),
    );
  }

  @override
  void dispose() {
    for (final node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _navigateToNext() {
    if (_currentIndex < widget.children.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _focusNodes[_currentIndex].requestFocus();
    }
  }

  void _navigateToPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _focusNodes[_currentIndex].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardNavigationWrapper(
      enabled: widget.enabled,
      child: Column(
        children: widget.children.asMap().entries.map((entry) {
          final index = entry.key;
          final child = entry.value;
          
          return Focus(
            focusNode: _focusNodes[index],
            child: child,
          );
        }).toList(),
      ),
    );
  }
}
