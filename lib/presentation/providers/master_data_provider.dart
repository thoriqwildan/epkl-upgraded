import 'package:epkl/data/models/jurusan.dart';
import 'package:epkl/data/models/kelas.dart';
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final jurusanListProvider = FutureProvider<List<Jurusan>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getJurusanList();
});

final kelasListProvider = FutureProvider<List<Kelas>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getKelasList();
});
