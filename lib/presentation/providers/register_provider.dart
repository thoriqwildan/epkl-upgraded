import 'package:epkl/data/models/register_request.dart';
import 'package:epkl/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterNotifier extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;
  RegisterNotifier(this._ref) : super(const AsyncValue.data(null));

  Future<void> register(RegisterRequest request) async {
    state = const AsyncValue.loading();
    try {
      final apiService = _ref.read(apiServiceProvider);
      await apiService.register(request: request);
      state = const AsyncValue.data(null);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw e;
    }
  }
}

final registerNotifierProvider =
    StateNotifierProvider<RegisterNotifier, AsyncValue<void>>((ref) {
      return RegisterNotifier(ref);
    });
