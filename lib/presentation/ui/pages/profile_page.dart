// ignore_for_file: use_build_context_synchronously, unused_local_variable

import 'dart:io';

import 'package:epkl/data/models/jurusan.dart';
import 'package:epkl/data/models/kelas.dart';
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:epkl/presentation/providers/master_data_provider.dart';
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

                _buildProfileTextField(
                  controller: _nameController,
                  label: 'Nama Lengkap',
                  icon: Icons.person_outline,
                ),
                _buildProfileTextField(
                  controller: _emailController,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  enabled: false,
                ),
                _buildProfileTextField(
                  controller: _nisnController,
                  label: 'NISN',
                  icon: Icons.badge_outlined,
                  enabled: false,
                ),

                jurusanAsyncValue.when(
                  data: (jurusanList) => _isEditing
                      ? _buildJurusanDropdown(jurusanList)
                      : _buildProfileTextField(
                          controller: TextEditingController(
                            text: user.jurusan?.name ?? '-',
                          ),
                          label: 'Jurusan',
                          icon: Icons.school_outlined,
                          enabled: false,
                        ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, st) => Text('Gagal memuat jurusan: $e'),
                ),

                kelasAsyncValue.when(
                  data: (kelasList) => _isEditing
                      ? _buildKelasDropdown(kelasList)
                      : _buildProfileTextField(
                          controller: TextEditingController(
                            text: user.kelas?.name ?? '-',
                          ),
                          label: 'Kelas',
                          icon: Icons.class_outlined,
                          enabled: false,
                        ),
                  loading: () => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                  error: (e, st) => Text('Gagal memuat kelas: $e'),
                ),

                _buildProfileTextField(
                  controller: _phoneController,
                  label: 'Nomor HP',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildJurusanDropdown(List<Jurusan> jurusanList) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        initialValue: _selectedJurusanId,

        // --- PROPERTI BARU UNTUK STYLING ---
        menuMaxHeight: 300.0, // Batasi tinggi menu maksimal 300 pixel
        dropdownColor: Colors.white, // Warna background menu
        borderRadius: BorderRadius.circular(12), // Sudut melengkung
        // ------------------------------------
        items: jurusanList.map((jurusan) {
          return DropdownMenuItem<int>(
            value: jurusan.id,
            child: Expanded(
              child: Text(jurusan.name, overflow: TextOverflow.ellipsis),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedJurusanId = value;
            _selectedKelasId = null;
          });
        },
        decoration: const InputDecoration(
          labelText: 'Jurusan',
          prefixIcon: Icon(Icons.school_outlined),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
        ),
      ),
    );
  }

  Widget _buildKelasDropdown(List<Kelas> kelasList) {
    final filteredKelasList = kelasList
        .where((kelas) => kelas.mJurusanId == _selectedJurusanId)
        .toList();

    if (_selectedKelasId != null &&
        !filteredKelasList.any((kelas) => kelas.id == _selectedKelasId)) {
      _selectedKelasId = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<int>(
        isExpanded: true,
        initialValue: _selectedKelasId,

        // --- PROPERTI BARU (DITERAPKAN JUGA DI SINI) ---
        menuMaxHeight: 300.0,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(12),

        // ---------------------------------------------
        items: filteredKelasList.map((kelas) {
          return DropdownMenuItem<int>(
            value: kelas.id,
            child: Expanded(
              child: Text(kelas.name, overflow: TextOverflow.ellipsis),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _selectedKelasId = value;
          });
        },
        decoration: InputDecoration(
          labelText: 'Kelas',
          prefixIcon: const Icon(Icons.class_outlined),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          hintText: _selectedJurusanId == null
              ? 'Pilih Jurusan terlebih dahulu'
              : 'Pilih Kelas',
        ),
      ),
    );
  }

  Widget _buildProfileTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        enabled: _isEditing && enabled,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
          ),
          filled: !_isEditing || !enabled,
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
