import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../screens/home_screen.dart';
import '../screens/note_detail_screen.dart';
import '../screens/settings.dart';
import '../screens/about_app_screen.dart';
import '../screens/test_screen.dart';
import '../models/note.dart';

// SharedAxisTransition cần cả 2 màn hình dùng cùng transition type
// để animation enter/exit được phối hợp đúng.
// fillColor tránh render màn hình cũ xuyên suốt transition → nhẹ GPU hơn.
CustomTransitionPage<T> _buildTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SharedAxisTransition(
        fillColor: Theme.of(context).scaffoldBackgroundColor,
        animation: animation,
        secondaryAnimation: secondaryAnimation,
        transitionType: SharedAxisTransitionType.horizontal,
        child: child,
      );
    },
  );
}

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // Route test
    GoRoute(
      path: '/test',
      pageBuilder: (context, state) => _buildTransition(
        context: context,
        state: state,
        child: const TestScreen(),
      ),
      routes: [
        GoRoute(
          path: 'detail',
          pageBuilder: (context, state) => _buildTransition(
            context: context,
            state: state,
            child: const TestDetailScreen(),
          ),
        ),
      ],
    ),
    // Route chính
    GoRoute(
      path: '/',
      // FIX: Dùng _buildTransition thay vì NoTransitionPage
      // NoTransitionPage không có secondaryAnimation → SharedAxisTransition bị lệch
      // khi HomeScreen exit sang settings/note_detail
      pageBuilder: (context, state) => _buildTransition(
        context: context,
        state: state,
        child: const HomeScreen(),
      ),
      routes: [
        GoRoute(
          path: 'note/:id',
          pageBuilder: (context, state) => _buildTransition(
            context: context,
            state: state,
            child: NoteDetailScreen(note: state.extra as Note),
          ),
        ),
        GoRoute(
          path: 'settings',
          pageBuilder: (context, state) => _buildTransition(
            context: context,
            state: state,
            child: const SettingsScreen(),
          ),
          routes: [
            GoRoute(
              path: 'about',
              pageBuilder: (context, state) => _buildTransition(
                context: context,
                state: state,
                child: const AboutAppScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
  ],
);