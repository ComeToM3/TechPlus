import 'package:flutter/material.dart';
// import 'package:flutter/semantics.dart'; // Unnecessary - already in material.dart
// import '../../../core/accessibility/accessibility_constants.dart'; // Unused
import '../../../core/accessibility/accessibility_utils.dart';

/// Champ de texte accessible respectant WCAG 2.1 AA
class AccessibleTextField extends StatefulWidget {
  final String? label;
  final String? hint;
  final String? helperText;
  final String? errorText;
  final TextEditingController? controller;
  final String? initialValue;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool enabled;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onSubmitted;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? semanticLabel;
  final String? semanticHint;
  final bool required;
  final bool showFocusRing;
  final Color? focusColor;
  final Color? errorColor;

  const AccessibleTextField({
    super.key,
    this.label,
    this.hint,
    this.helperText,
    this.errorText,
    this.controller,
    this.initialValue,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.enabled = true,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.semanticLabel,
    this.semanticHint,
    this.required = false,
    this.showFocusRing = true,
    this.focusColor,
    this.errorColor,
  });

  @override
  State<AccessibleTextField> createState() => _AccessibleTextFieldState();
}

class _AccessibleTextFieldState extends State<AccessibleTextField> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _isFocused = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);

    _controller =
        widget.controller ?? TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();

    if (widget.controller == null) {
      _controller.removeListener(_onTextChanged);
      _controller.dispose();
    }

    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = _focusNode.hasFocus;
    });
  }

  void _onTextChanged() {
    // Vérifier la validation en temps réel
    if (widget.validator != null) {
      final error = widget.validator!(_controller.text);
      setState(() {
        _hasError = error != null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Vérifier le contraste des couleurs
    final textColor = colorScheme.onSurface;
    final backgroundColor = colorScheme.surface;

    if (!AccessibilityUtils.isContrastCompliant(textColor, backgroundColor)) {
      debugPrint(
        'Warning: Text field color contrast may not meet WCAG standards',
      );
    }

    return Semantics(
      label: widget.semanticLabel ?? widget.label,
      hint: widget.semanticHint ?? widget.hint,
      textField: true,
      enabled: widget.enabled,
      focusable: true,
      // required: widget.required, // Deprecated parameter
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null) ...[
            Row(
              children: [
                Text(
                  widget.label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (widget.required) ...[
                  const SizedBox(width: 4),
                  Text(
                    '*',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
          ],
          Focus(
            focusNode: _focusNode,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                  color: _hasError
                      ? (widget.errorColor ?? colorScheme.error)
                      : _isFocused
                      ? (widget.focusColor ?? colorScheme.primary)
                      : colorScheme.outline,
                  width: _isFocused ? 2.0 : 1.0,
                ),
                color: backgroundColor,
              ),
              child: TextFormField(
                controller: _controller,
                obscureText: widget.obscureText,
                keyboardType: widget.keyboardType,
                textInputAction: widget.textInputAction,
                enabled: widget.enabled,
                readOnly: widget.readOnly,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                maxLength: widget.maxLength,
                validator: widget.validator,
                onChanged: widget.onChanged,
                onFieldSubmitted: widget.onSubmitted,
                onTap: widget.onTap,
                style: theme.textTheme.bodyLarge?.copyWith(color: textColor),
                decoration: InputDecoration(
                  hintText: widget.hint,
                  helperText: widget.helperText,
                  errorText: widget.errorText,
                  prefixIcon: widget.prefixIcon,
                  suffixIcon: widget.suffixIcon,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 16.0,
                  ),
                  counterText: '', // Masquer le compteur par défaut
                ),
              ),
            ),
          ),
          if (widget.helperText != null && !_hasError) ...[
            const SizedBox(height: 4),
            Text(
              widget.helperText!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (widget.errorText != null && _hasError) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: colorScheme.error,
                  semanticLabel: AccessibilityUtils.getAccessibilityMessage(
                    'error',
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    widget.errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
          if (widget.maxLength != null) ...[
            const SizedBox(height: 4),
            Text(
              '${_controller.text.length}/${widget.maxLength}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Champ de texte spécialisé pour les emails
class AccessibleEmailField extends StatelessWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? semanticLabel;

  const AccessibleEmailField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return AccessibleTextField(
      label: label ?? 'Email',
      hint: hint ?? 'Entrez votre adresse email',
      controller: controller,
      initialValue: initialValue,
      enabled: enabled,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      prefixIcon: const Icon(Icons.email_outlined),
      semanticLabel: semanticLabel ?? 'Adresse email',
      validator: validator ?? _validateEmail,
      onChanged: onChanged,
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'adresse email est requise';
    }

    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegex.hasMatch(value)) {
      return 'Veuillez entrer une adresse email valide';
    }

    return null;
  }
}

/// Champ de texte spécialisé pour les mots de passe
class AccessiblePasswordField extends StatefulWidget {
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? semanticLabel;

  const AccessiblePasswordField({
    super.key,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.validator,
    this.onChanged,
    this.semanticLabel,
  });

  @override
  State<AccessiblePasswordField> createState() =>
      _AccessiblePasswordFieldState();
}

class _AccessiblePasswordFieldState extends State<AccessiblePasswordField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return AccessibleTextField(
      label: widget.label ?? 'Mot de passe',
      hint: widget.hint ?? 'Entrez votre mot de passe',
      controller: widget.controller,
      initialValue: widget.initialValue,
      enabled: widget.enabled,
      obscureText: _obscureText,
      textInputAction: TextInputAction.done,
      prefixIcon: const Icon(Icons.lock_outlined),
      suffixIcon: IconButton(
        icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
        onPressed: () {
          setState(() {
            _obscureText = !_obscureText;
          });
        },
      ),
      // semanticLabel: widget.semanticLabel ?? 'Mot de passe', // Deprecated parameter
      validator: widget.validator ?? _validatePassword,
      onChanged: widget.onChanged,
    );
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }

    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }

    return null;
  }
}
