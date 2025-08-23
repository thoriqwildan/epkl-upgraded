// lib/presentation/ui/pages/register_page.dart

import 'package:epkl/data/models/register_request.dart';
import 'package:epkl/presentation/providers/master_data_provider.dart';
import 'package:epkl/presentation/providers/register_provider.dart';
import 'package:epkl/presentation/ui/widgets/jurusan_dropdown_field.dart';
import 'package:epkl/presentation/ui/widgets/kelas_dropdown_field.dart';
import 'package:epkl/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _nisnController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _semesterController = TextEditingController();
  final _yearController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();

  int? _selectedJurusanId;
  int? _selectedKelasId;
  bool _isLoading = false;

  // State untuk fitur lihat password
  bool _isPasswordObscured = true;
  bool _isConfirmPasswordObscured = true;

  @override
  void dispose() {
    _nameController.dispose();
    _nisnController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _semesterController.dispose();
    _yearController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _passwordConfirmationController.text) {
      showAppSnackBar(
        context,
        message: 'Konfirmasi password tidak cocok!',
        isError: true,
      );
      return;
    }
    if (_selectedJurusanId == null || _selectedKelasId == null) {
      showAppSnackBar(
        context,
        message: 'Jurusan dan Kelas harus dipilih',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    final request = RegisterRequest(
      email: _emailController.text,
      mJurusanId: _selectedJurusanId!,
      mKelasId: _selectedKelasId!,
      name: _nameController.text,
      nisn: _nisnController.text,
      password: _passwordController.text,
      passwordConfirmation: _passwordConfirmationController.text,
      phone: _phoneController.text,
      semester: _semesterController.text,
      year: _yearController.text,
    );

    try {
      await ref.read(registerNotifierProvider.notifier).register(request);
      showAppSnackBar(context, message: 'Registrasi berhasil! Silakan login.');
      Navigator.of(context).pop();
    } catch (e) {
      showAppSnackBar(context, message: e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final jurusanAsyncValue = ref.watch(jurusanListProvider);
    final kelasAsyncValue = ref.watch(kelasListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          children: [
            Text(
              'Selamat Datang!',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Silakan isi data diri Anda untuk melanjutkan.',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 32),

            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nama Lengkap',
                prefixIcon: Icon(Icons.person_outline),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nisnController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'NISN',
                prefixIcon: Icon(Icons.badge_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || !v.contains('@')) ? 'Email tidak valid' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'No. Telepon',
                prefixIcon: Icon(Icons.phone_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            jurusanAsyncValue.when(
              data: (list) => JurusanDropdownField(
                isEditing: true,
                jurusanList: list,
                selectedJurusanId: _selectedJurusanId,
                onChanged: (val) => setState(() {
                  _selectedJurusanId = val;
                  _selectedKelasId = null;
                }),
                initialValueText: '',
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error memuat jurusan: $e'),
            ),
            const SizedBox(height: 16),
            kelasAsyncValue.when(
              data: (list) => KelasDropdownField(
                isEditing: true,
                kelasList: list,
                selectedJurusanId: _selectedJurusanId,
                selectedKelasId: _selectedKelasId,
                onChanged: (val) => setState(() => _selectedKelasId = val),
                initialValueText: '',
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Text('Error memuat kelas: $e'),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _semesterController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Semester',
                      prefixIcon: Icon(Icons.school_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _yearController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Tahun Ajaran',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
                    textInputAction: TextInputAction.next,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: _isPasswordObscured,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(
                    () => _isPasswordObscured = !_isPasswordObscured,
                  ),
                ),
              ),
              validator: (v) => v!.length < 6 ? 'Minimal 6 karakter' : null,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordConfirmationController,
              obscureText: _isConfirmPasswordObscured,
              decoration: InputDecoration(
                labelText: 'Konfirmasi Password',
                prefixIcon: const Icon(Icons.lock_person_outlined),
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordObscured
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                  onPressed: () => setState(
                    () => _isConfirmPasswordObscured =
                        !_isConfirmPasswordObscured,
                  ),
                ),
              ),
              validator: (v) => v!.isEmpty ? 'Wajib diisi' : null,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Daftar Akun'),
            ),
          ],
        ),
      ),
    );
  }
}
