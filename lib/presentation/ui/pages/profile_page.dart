import 'package:epkl/data/models/jurusan.dart';
import 'package:epkl/data/models/kelas.dart';
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:epkl/presentation/providers/master_data_provider.dart';
import 'package:epkl/presentation/ui/pages/login_page.dart';
import 'package:epkl/utils/snackbar_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    final success = await ref
        .read(authNotifierProvider.notifier)
        .updateProfile(
          name: _nameController.text,
          jurusanId: _selectedJurusanId!,
          kelasId: _selectedKelasId!,
          phone: _phoneController.text,
        );

    setState(() {
      _isSaving = false;
    });

    if (mounted) {
      // Cek apakah widget masih ada di tree
      if (success) {
        showAppSnackBar(context, message: 'Profil berhasil diperbarui!');
        setState(() {
          _isEditing = false;
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
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginPage()),
                (route) => false,
              );
            },
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
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: user.avatar != null
                        ? NetworkImage(user.avatar!)
                        : null,
                    child: user.avatar == null
                        ? const Icon(Icons.person, size: 50)
                        : null,
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
        value: _selectedJurusanId,

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
        value: _selectedKelasId,

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
          fillColor: Colors.grey.shade200,
          disabledBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
