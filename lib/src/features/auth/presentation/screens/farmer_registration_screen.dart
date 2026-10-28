import 'package:flutter/material.dart';

import '../../../farmer/data/models/farmer_profile_model.dart';
import '../../../farmer/domain/entities/farmer_profile.dart';
import '../../data/repositories/auth_local_repository.dart';
import '../../../../components/components.dart';

class FarmerRegistrationScreen extends StatefulWidget {
  const FarmerRegistrationScreen({
    super.key,
    required this.repository,
    required this.onBack,
    required this.onRegistered,
  });

  final AuthLocalRepository repository;
  final VoidCallback onBack;
  final VoidCallback onRegistered;

  @override
  State<FarmerRegistrationScreen> createState() =>
      _FarmerRegistrationScreenState();
}

class _FarmerRegistrationScreenState extends State<FarmerRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController(text: '+255 ');
  final _emailController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _villageController = TextEditingController();
  final _passwordController = TextEditingController();
  FarmerSex _sex = FarmerSex.male;
  FarmerIdentityDocumentType _identityType = FarmerIdentityDocumentType.nida;
  DateTime _dateOfBirth = DateTime(1990, 1, 1);
  bool _submitting = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _idNumberController.dispose();
    _villageController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: context.appText('Back'),
          onPressed: widget.onBack,
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(context.appText('Create Farmer Account')),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      context.appText('Farmer Details'),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      context.appText(
                        'Register farmers locally now. Other roles will sign in through backend authentication later.',
                      ),
                    ),
                    const SizedBox(height: 22),
                    _RequiredTextField(
                      controller: _firstNameController,
                      label: context.appText('First name'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _middleNameController,
                      decoration: InputDecoration(
                        labelText: context.appText('Middle name (optional)'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RequiredTextField(
                      controller: _lastNameController,
                      label: context.appText('Last name'),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<FarmerSex>(
                      initialValue: _sex,
                      decoration: InputDecoration(
                        labelText: context.appText('Sex'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: FarmerSex.female,
                          child: Text(context.appText('Female')),
                        ),
                        DropdownMenuItem(
                          value: FarmerSex.male,
                          child: Text(context.appText('Male')),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) setState(() => _sex = value);
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<FarmerIdentityDocumentType>(
                      initialValue: _identityType,
                      decoration: InputDecoration(
                        labelText: context.appText('ID type'),
                      ),
                      items: [
                        for (final type in FarmerIdentityDocumentType.values)
                          DropdownMenuItem(
                            value: type,
                            child: Text(type.label),
                          ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _identityType = value);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    _RequiredTextField(
                      controller: _idNumberController,
                      label: context.appText('ID number'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _pickDateOfBirth,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(
                        'Date of birth: ${_formatDate(_dateOfBirth)}',
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RequiredTextField(
                      controller: _phoneController,
                      label: context.appText('Phone number'),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: context.appText('Email (optional)'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _villageController,
                      decoration: InputDecoration(
                        labelText: context.appText('Village (optional)'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _RequiredTextField(
                      controller: _passwordController,
                      label: context.appText('Password'),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),
                    FilledButton(
                      onPressed: _submitting ? null : _register,
                      child: AppButtonContent(
                        loading: _submitting,
                        loadingLabel: context.appText('Creating Account...'),
                        label: context.appText('Create Account'),
                        icon: Icons.person_add_alt_1_outlined,
                        progressColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateOfBirth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateOfBirth,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);

    final farmerModel = FarmerProfileModel.newLocal(
      firstName: _firstNameController.text.trim(),
      middleName: _middleNameController.text.trim().isEmpty
          ? null
          : _middleNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      email: _emailController.text.trim().isEmpty
          ? null
          : _emailController.text.trim(),
      village: _villageController.text.trim().isEmpty
          ? null
          : _villageController.text.trim(),
      sex: _sex,
      identityDocumentType: _identityType,
      identityNumber: _idNumberController.text.trim(),
      dateOfBirth: _dateOfBirth,
    );

    await widget.repository.registerFarmer(
      farmerProfile: farmerModel.toEntity(),
      password: _passwordController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    widget.onRegistered();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _RequiredTextField extends StatelessWidget {
  const _RequiredTextField({
    required this.controller,
    required this.label,
    this.obscureText = false,
  });

  final TextEditingController controller;
  final String label;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label),
      validator: (value) {
        if (value == null || value.trim().isEmpty) return 'Required';
        return null;
      },
    );
  }
}
