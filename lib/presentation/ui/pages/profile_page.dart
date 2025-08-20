// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:io';

import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:epkl/presentation/providers/master_data_provider.dart';
import 'package:epkl/presentation/ui/widgets/jurusan_dropdown_field.dart';
import 'package:epkl/presentation/ui/widgets/kelas_dropdown_field.dart';
import 'package:epkl/presentation/ui/widgets/profile_text_field.dart';
import 'package:epkl/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});
  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isEditing = false;
  bool _isSaving = false;
  int? _selectedJurusanId;
  int? _selectedKelasId;

  File? _selectedImageFile;

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _nisnController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _nisnController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _nisnController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (pickedFile != null) {
      // Tampilkan dialog loading saat kompresi
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final compressedFile = await _compressImage(File(pickedFile.path));

      Navigator.of(context).pop(); // Tutup dialog loading

      if (compressedFile != null) {
        setState(() {
          _selectedImageFile = compressedFile;
        });
      }
    }
  }

  Future<File?> _compressImage(File file) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath =
        '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      file.absolute.path,
      targetPath,
      quality:
          70, // Kualitas gambar (0-100), semakin rendah semakin kecil ukurannya
      minWidth: 1024, // Resize gambar jika lebarnya lebih dari 1024px
      minHeight: 1024, // Resize gambar jika tingginya lebih dari 1024px
    );

    if (result != null) {
      return File(result.path);
    }
    return null;
  }

  void _handleEditOrSave() async {
    if (!_isEditing) {
      setState(() {
        _isEditing = true;
      });
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

    setState(() {
      _isSaving = true;
    });

    bool profileSuccess = true;
    bool avatarSuccess = true;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .updateProfile(
          name: _nameController.text,
          jurusanId: _selectedJurusanId!,
          kelasId: _selectedKelasId!,
          phone: _phoneController.text,
        );

    if (_selectedImageFile != null && profileSuccess) {
      avatarSuccess = await ref
          .read(authNotifierProvider.notifier)
          .updateAvatar(imageFile: _selectedImageFile!);
    }

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      // Cek apakah widget masih ada di tree
      if (success) {
        showAppSnackBar(context, message: 'Profil berhasil diperbarui!');
        setState(() {
          _isEditing = false;
          _selectedImageFile = null;
        }); // Kembali ke mode view
      } else {
        showAppSnackBar(
          context,
          message: 'Gagal memperbarui profil',
          isError: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final jurusanAsyncValue = ref.watch(jurusanListProvider);
    final kelasAsyncValue = ref.watch(kelasListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(12.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(color: Colors.white),
              ),
            )
          else
            authState.maybeWhen(
              success: (_) => IconButton(
                icon: Icon(
                  _isEditing ? Icons.save_alt_outlined : Icons.edit_outlined,
                ),
                tooltip: _isEditing ? 'Simpan' : 'Edit Profil',
                onPressed: _handleEditOrSave,
              ),
              orElse: () => const SizedBox.shrink(),
            ),
        ],
      ),
      body: authState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (message) =>
            Center(child: Text('Gagal memuat profil: $message')),
        initial: () => const Center(child: CircularProgressIndicator()),
        success: (user) {
          if (!_isEditing) {
            _nameController.text = user.name;
            _emailController.text = user.email;
            _nisnController.text = user.nisn;
            _phoneController.text = user.phone ?? '';
            _selectedJurusanId = user.mJurusanId;
            _selectedKelasId = user.mKelasId;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _selectedImageFile != null
                            ? FileImage(_selectedImageFile!) as ImageProvider
                            : NetworkImage(user.avatar ?? ''),
                        child: user.avatar == null && _selectedImageFile == null
                            ? const Icon(Icons.person, size: 50)
                            : null,
                      ),
                      if (_isEditing)
                        Positioned(
                          bottom: 0,
                          right: -10,
                          child: IconButton(
                            icon: const CircleAvatar(
                              radius: 15,
                              child: Icon(Icons.edit, size: 15),
                            ),
                            onPressed: _pickImage,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                ProfileTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                  isEditing: _isEditing,
                ),
                ProfileTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  isEditing: _isEditing,
                  isEnabledInEditMode: false,
                ),
                ProfileTextField(
                  controller: _nisnController,
                  label: 'NISN',
                  icon: Icons.badge_outlined,
                  isEditing: _isEditing,
                  isEnabledInEditMode: false,
                ),

                jurusanAsyncValue.when(
                  data: (jurusanList) => JurusanDropdownField(
                    isEditing: _isEditing,
                    jurusanList: jurusanList,
                    selectedJurusanId: _selectedJurusanId,
                    initialValueText: user.jurusan?.name ?? '-',
                    onChanged: (value) {
                      setState(() {
                        _selectedJurusanId = value;
                        _selectedKelasId =
                            null; // Reset kelas saat jurusan berubah
                      });
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text('Gagal memuat jurusan: $e'),
                ),

                kelasAsyncValue.when(
                  data: (kelasList) => KelasDropdownField(
                    isEditing: _isEditing,
                    kelasList: kelasList,
                    selectedJurusanId: _selectedJurusanId,
                    selectedKelasId: _selectedKelasId,
                    initialValueText: user.kelas?.name ?? '-',
                    onChanged: (value) {
                      setState(() {
                        _selectedKelasId = value;
                      });
                    },
                  ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, st) => Text('Gagal memuat kelas: $e'),
                ),

                ProfileTextField(
                  controller: _phoneController,
                  label: 'Nomor HP',
                  icon: Icons.phone_outlined,
                  isEditing: _isEditing,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
