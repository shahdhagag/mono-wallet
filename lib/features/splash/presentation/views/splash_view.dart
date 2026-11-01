import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.96, end: 1.04).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.72, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _navigationTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;

      final state = context.read<AuthCubit>().state;
      if (state is AuthAuthenticated) {
        context.go('/home');
      } else {
        context.go('/onboarding');
      }
    });
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigationTimer?.cancel();
          context.go('/home');
        } else if (state is AuthPasswordRecovery) {
          _navigationTimer?.cancel();
          context.go('/reset-password');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF76C9C2), Color(0xFF4FAFA9), Color(0xFF3EA4A0)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _SplashTexturePainter(),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: const Text(
                  'mono',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 54,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1.5,
                    height: 1,
                  ),
                ),
              ),
            ),
            const Positioned(
              left: 0,
              right: 0,
              bottom: 72,
              child: _LoadingDots(),
            ),
          ],
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
	const _LoadingDots();

	@override
	State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
		with SingleTickerProviderStateMixin {
	late final AnimationController _controller;

	@override
	void initState() {
		super.initState();
		_controller = AnimationController(
			vsync: this,
			duration: const Duration(milliseconds: 900),
		)..repeat();
	}

	@override
	void dispose() {
		_controller.dispose();
		super.dispose();
	}

	@override
	Widget build(BuildContext context) {
		return AnimatedBuilder(
			animation: _controller,
			builder: (context, child) {
				final progress = _controller.value;
				return Row(
					mainAxisAlignment: MainAxisAlignment.center,
					children: List.generate(3, (index) {
						final offset = (progress + index * 0.2) % 1.0;
						final scale = 0.7 + (1 - (offset * 2 - 1).abs()) * 0.35;
						return Padding(
							padding: const EdgeInsets.symmetric(horizontal: 4),
							child: Transform.scale(
								scale: scale,
								child: Container(
									width: 10,
									height: 10,
									decoration: const BoxDecoration(
										color: Colors.white,
										shape: BoxShape.circle,
									),
								),
							),
						);
					}),
				);
			},
		);
	}
}

class _SplashTexturePainter extends CustomPainter {
	@override
	void paint(Canvas canvas, Size size) {
		final paint = Paint()..color = Colors.white.withValues(alpha: 0.05);
		for (var index = 0; index < 140; index++) {
			final x = (index * 37.0) % size.width;
			final y = (index * 73.0) % size.height;
			canvas.drawCircle(Offset(x, y), 1.2, paint);
		}
	}

	@override
	bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
