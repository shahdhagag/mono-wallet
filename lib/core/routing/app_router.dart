import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/views/login_view.dart';
import '../../features/auth/presentation/views/forgot_password_view.dart';
import '../../features/auth/presentation/views/reset_password_view.dart';
import '../../features/auth/presentation/views/signup_view.dart';
import '../../features/bills/presentation/views/bill_details_view.dart';
import '../../features/home/presentation/views/home_view.dart';
import '../../features/onboarding/presentation/views/onboarding_view.dart';
import '../../features/transactions/presentation/views/add_transaction_view.dart';
import '../../features/wallet/presentation/views/connect_wallet_view.dart';
import '../../features/splash/presentation/views/splash_view.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/',
      redirect: (context, state) => '/splash',
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashView(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingView(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginView(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordView(),
    ),
    GoRoute(
      path: '/reset-password',
      builder: (context, state) => const ResetPasswordView(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupView(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeView(),
    ),
    GoRoute(
      name: 'connect-wallet',
      path: '/connect-wallet',
      builder: (context, state) => const ConnectWalletView(),
    ),
    GoRoute(
      name: 'add-transaction',
      path: '/add-transaction',
      builder: (context, state) => const AddTransactionView(),
    ),
    GoRoute(
      name: 'bill-details',
      path: '/bill-details',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? const {};
        return BillDetailsView(
          billId: extra['billId'] as String?,
          billName: extra['billName'] as String?,
          amount: (extra['amount'] as num?)?.toDouble() ?? 0.0,
          dueDate: extra['dueDate'] as String?,
          status: extra['status'] as String?,
        );
      },
    ),
    GoRoute(
      name: 'bill-payment',
      path: '/bill-payment',
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>? ?? const {};
        return BillPaymentView(
          billId: extra['billId'] as String?,
          billName: extra['billName'] as String?,
          amount: (extra['amount'] as num?)?.toDouble() ?? 0.0,
          dueDate: extra['dueDate'] as String?,
        );
      },
    ),
  ],
);