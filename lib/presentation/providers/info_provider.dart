// lib/presentation/providers/info_provider.dart

import 'package:epkl/data/models/info_detail.dart';
import 'package:epkl/data/models/info_summary.dart';
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:epkl/presentation/providers/auth_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final infoListProvider = FutureProvider<List<InfoSummary>>((ref) async {
  final authState = ref.watch(authNotifierProvider);
  final apiService = ref.watch(apiServiceProvider);

  final user = authState.maybeWhen(success: (user) => user, orElse: () => null);

  if (user != null) {
    final response = await apiService.getInfoList(limit: 5);
    return response.infoList;
  }

  return [];
});

final infoDetailProvider = FutureProvider.family<InfoDetail, int>((
  ref,
  id,
) async {
  final authState = ref.watch(authNotifierProvider);
  final apiService = ref.watch(apiServiceProvider);

  final user = authState.maybeWhen(success: (user) => user, orElse: () => null);

  if (user != null) {
    return apiService.getInfoDetail(id: id);
  }

  throw Exception('User not authenticated');
});
