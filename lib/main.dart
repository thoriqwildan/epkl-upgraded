import 'package:epkl/presentation/providers/theme_provider.dart';
import 'package:epkl/presentation/ui/pages/auth_checker_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting('id_ID', null);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeTheme = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Aplikasi EPKL',
      debugShowCheckedModeBanner: false,
      theme: activeTheme.themeData,
      home: const AuthCheckerPage(),
    );
  }
}
