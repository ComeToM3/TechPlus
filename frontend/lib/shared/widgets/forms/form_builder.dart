import 'package:flutter/material.dart';

/// Constructeur de formulaire avec validation
class FormBuilder extends StatefulWidget {
  final List<FormFieldConfig> fields;
  final Function(Map<String, dynamic>) onSubmit;
  final String? submitText;
  final bool isLoading;
  final EdgeInsets? padding;
  final double? spacing;

  const FormBuilder({
    super.key,
    required this.fields,
    required this.onSubmit,
    this.submitText,
    this.isLoading = false,
    this.padding,
    this.spacing,
  });

  @override
  State<FormBuilder> createState() => _FormBuilderState();
}

class _FormBuilderState extends State<FormBuilder> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    for (final field in widget.fields) {
      _controllers[field.name] = TextEditingController(text: field.initialValue);
      _formData[field.name] = field.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          ...widget.fields.map((field) => _buildField(field)),
          
          SizedBox(height: widget.spacing ?? 24),
          
          _buildSubmitButton(),
        ],
      ),
    );
  }

  Widget _buildField(FormFieldConfig field) {
    switch (field.type) {
      case FormFieldType.text:
        return _buildTextField(field);
      case FormFieldType.email:
        return _buildEmailField(field);
      case FormFieldType.password:
        return _buildPasswordField(field);
      case FormFieldType.phone:
        return _buildPhoneField(field);
      case FormFieldType.multiline:
        return _buildMultilineField(field);
      case FormFieldType.dropdown:
        return _buildDropdownField(field);
      case FormFieldType.date:
        return _buildDateField(field);
      case FormFieldType.time:
        return _buildTimeField(field);
      case FormFieldType.checkbox:
        return _buildCheckboxField(field);
      case FormFieldType.radio:
        return _buildRadioField(field);
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(FormFieldConfig field) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing ?? 16),
      child: TextFormField(
        controller: _controllers[field.name],
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.hint,
          prefixIcon: field.prefixIcon != null ? Icon(field.prefixIcon) : null,
          suffixIcon: field.suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: field.validator,
        onChanged: (value) => _formData[field.name] = value,
        enabled: !widget.isLoading,
      ),
    );
  }

  Widget _buildEmailField(FormFieldConfig field) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing ?? 16),
      child: TextFormField(
        controller: _controllers[field.name],
        keyboardType: TextInputType.emailAddress,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.hint,
          prefixIcon: const Icon(Icons.email_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: field.validator ?? _validateEmail,
        onChanged: (value) => _formData[field.name] = value,
        enabled: !widget.isLoading,
      ),
    );
  }

  Widget _buildPasswordField(FormFieldConfig field) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing ?? 16),
      child: TextFormField(
        controller: _controllers[field.name],
        obscureText: true,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.hint,
          prefixIcon: const Icon(Icons.lock_outlined),
          suffixIcon: const Icon(Icons.visibility_off),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: field.validator ?? _validatePassword,
        onChanged: (value) => _formData[field.name] = value,
        enabled: !widget.isLoading,
      ),
    );
  }

  Widget _buildPhoneField(FormFieldConfig field) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing ?? 16),
      child: TextFormField(
        controller: _controllers[field.name],
        keyboardType: TextInputType.phone,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.hint,
          prefixIcon: const Icon(Icons.phone_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: field.validator ?? _validatePhone,
        onChanged: (value) => _formData[field.name] = value,
        enabled: !widget.isLoading,
      ),
    );
  }

  Widget _buildMultilineField(FormFieldConfig field) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing ?? 16),
      child: TextFormField(
        controller: _controllers[field.name],
        maxLines: field.maxLines ?? 3,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.hint,
          prefixIcon: field.prefixIcon != null ? Icon(field.prefixIcon) : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        validator: field.validator,
        onChanged: (value) => _formData[field.name] = value,
        enabled: !widget.isLoading,
      ),
    );
  }

  Widget _buildDropdownField(FormFieldConfig field) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing ?? 16),
      child: DropdownButtonFormField<String>(
        value: _formData[field.name] as String?,
        decoration: InputDecoration(
          labelText: field.label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        items: field.options?.map((option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: widget.isLoading ? null : (value) {
          setState(() {
            _formData[field.name] = value;
          });
        },
        validator: field.validator,
      ),
    );
  }

  Widget _buildDateField(FormFieldConfig field) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing ?? 16),
      child: TextFormField(
        controller: _controllers[field.name],
        readOnly: true,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.hint,
          prefixIcon: const Icon(Icons.calendar_today),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onTap: widget.isLoading ? null : () => _selectDate(field),
        validator: field.validator,
      ),
    );
  }

  Widget _buildTimeField(FormFieldConfig field) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing ?? 16),
      child: TextFormField(
        controller: _controllers[field.name],
        readOnly: true,
        decoration: InputDecoration(
          labelText: field.label,
          hintText: field.hint,
          prefixIcon: const Icon(Icons.access_time),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onTap: widget.isLoading ? null : () => _selectTime(field),
        validator: field.validator,
      ),
    );
  }

  Widget _buildCheckboxField(FormFieldConfig field) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing ?? 16),
      child: CheckboxListTile(
        title: Text(field.label),
        subtitle: field.hint != null ? Text(field.hint!) : null,
        value: _formData[field.name] as bool? ?? false,
        onChanged: widget.isLoading ? null : (value) {
          setState(() {
            _formData[field.name] = value ?? false;
          });
        },
        controlAffinity: ListTileControlAffinity.leading,
      ),
    );
  }

  Widget _buildRadioField(FormFieldConfig field) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.spacing ?? 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            field.label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (field.hint != null) ...[
            const SizedBox(height: 4),
            Text(
              field.hint!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 8),
          ...field.options?.map((option) {
            return RadioListTile<String>(
              title: Text(option),
              value: option,
              groupValue: _formData[field.name] as String?,
              onChanged: widget.isLoading ? null : (value) {
                setState(() {
                  _formData[field.name] = value;
                });
              },
            );
          }).toList() ?? [],
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: widget.isLoading ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: widget.isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(widget.submitText ?? 'Soumettre'),
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onSubmit(_formData);
    }
  }

  void _selectDate(FormFieldConfig field) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    
    if (date != null) {
      final formattedDate = '${date.day}/${date.month}/${date.year}';
      _controllers[field.name]?.text = formattedDate;
      _formData[field.name] = formattedDate;
    }
  }

  void _selectTime(FormFieldConfig field) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    
    if (time != null) {
      final formattedTime = '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      _controllers[field.name]?.text = formattedTime;
      _formData[field.name] = formattedTime;
    }
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir un email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Veuillez saisir un email valide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Veuillez saisir un mot de passe';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^(\+33|0)[1-9](\d{8})$').hasMatch(value.replaceAll(' ', ''))) {
        return 'Veuillez saisir un numéro de téléphone valide';
      }
    }
    return null;
  }
}

/// Configuration d'un champ de formulaire
class FormFieldConfig {
  final String name;
  final String label;
  final String? hint;
  final FormFieldType type;
  final String? initialValue;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final List<String>? options;
  final int? maxLines;

  FormFieldConfig({
    required this.name,
    required this.label,
    this.hint,
    this.type = FormFieldType.text,
    this.initialValue,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.options,
    this.maxLines,
  });
}

/// Types de champs de formulaire
enum FormFieldType {
  text,
  email,
  password,
  phone,
  multiline,
  dropdown,
  date,
  time,
  checkbox,
  radio,
}
