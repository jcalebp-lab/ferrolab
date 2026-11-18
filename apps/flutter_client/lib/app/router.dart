import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/admin/admin_screens.dart';
import '../features/history/history_screens.dart';
import '../features/home/home_screen.dart';
import '../features/knowledge/knowledge_screens.dart';
import '../features/microscope/microscope_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/practice/practice_screen.dart';
import '../features/results/results_screen.dart';
import '../features/settings/settings_screens.dart';
import '../features/simulation/furnace_screen.dart';
import '../features/simulation/wizard_screens.dart';
import '../features/teacher/teacher_screen.dart';
import 'providers.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      if (state.matchedLocation == '/' && !ref.read(settingsProvider).onboardingSeen) return '/welcome';
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (c, s) => const HomeScreen()),
      GoRoute(path: '/welcome', builder: (c, s) => const OnboardingScreen()),
      GoRoute(path: '/lab/material', builder: (c, s) => const MaterialStepScreen()),
      GoRoute(path: '/lab/treatment', builder: (c, s) => const TreatmentStepScreen()),
      GoRoute(path: '/lab/params', builder: (c, s) => const ParamsStepScreen()),
      GoRoute(path: '/lab/review', builder: (c, s) => const ReviewStepScreen()),
      GoRoute(path: '/lab/furnace', builder: (c, s) => const FurnaceScreen()),
      GoRoute(path: '/lab/results', builder: (c, s) => const ResultsScreen()),
      GoRoute(path: '/lab/microscope', builder: (c, s) => const MicroscopeScreen()),
      GoRoute(path: '/micrographs', builder: (c, s) => const MicrographLibraryScreen()),
      GoRoute(path: '/learn', builder: (c, s) => const LearnScreen()),
      GoRoute(path: '/learn/:slug', builder: (c, s) => KnowledgeDetailScreen(slug: s.pathParameters['slug']!)),
      GoRoute(path: '/practice', builder: (c, s) => const PracticeScreen()),
      GoRoute(path: '/history', builder: (c, s) => const HistoryScreen()),
      GoRoute(path: '/compare', builder: (c, s) => const CompareScreen()),
      GoRoute(path: '/teacher', builder: (c, s) => const TeacherScreen()),
      GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
      GoRoute(path: '/sources', builder: (c, s) => const SourcesScreen()),
      GoRoute(path: '/admin', builder: (c, s) => const AdminScreen()),
    ],
  );
});
