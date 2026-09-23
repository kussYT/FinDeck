import 'package:findeck/app/router.dart';
import 'package:findeck/app/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FinDeckApp extends ConsumerWidget {
  const FinDeckApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'FinDeck',
      theme: AppTheme.light,
      routerConfig: router,
    );
  }
}
