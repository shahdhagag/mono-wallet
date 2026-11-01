import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/bills/data/repositories/bill_repository_impl.dart';
import 'features/bills/presentation/cubit/bills_cubit.dart';
import 'features/transactions/data/repositories/transaction_repository_impl.dart';
import 'features/transactions/presentation/cubit/transaction_cubit.dart';
import 'features/wallet/data/repositories/wallet_repository_impl.dart';
import 'features/wallet/presentation/cubit/accounts_cubit.dart';
import 'service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kjxffcmjpiaapqihnesz.supabase.co',
    publishableKey: 'sb_publishable_BNx0s8oq_3OR-p2tTLztoA_o6RmA2MV',
  );

  await AuthCubit.initialize();
  setupServiceLocator();
  runApp(const MonoWalletApp());
}

class MonoWalletApp extends StatelessWidget {
  const MonoWalletApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit()..checkAuthStatus(),
        ),
        BlocProvider(
          create: (_) => AccountsCubit(WalletRepositoryImpl()),
        ),
        BlocProvider(
          create: (_) => TransactionCubit(TransactionRepositoryImpl()),
        ),
        BlocProvider(
          create: (_) => BillsCubit(BillRepositoryImpl()),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Mono Wallet',
        theme: AppTheme.lightTheme,
        routerConfig: appRouter,
      ),
    );
  }
}