// lib/presentation/providers/info_provider.dart

import 'package:epkl/data/models/info_detail.dart';
import 'package:epkl/data/models/info_summary.dart';
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider untuk mengambil daftar info (untuk HomePage)
final infoListProvider = FutureProvider<List<InfoSummary>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  // Ambil 5 item info terbaru
  final response = await apiService.getInfoList(limit: 5);
  return response.infoList;
});

// Provider untuk mengambil detail info berdasarkan ID
final infoDetailProvider = FutureProvider.family<InfoDetail, int>((
  ref,
  id,
) async {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getInfoDetail(id: id);
});
