import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waverate/src/routing/scaffold_with_navbar.dart';
import 'package:waverate/src/features/authentication/presentation/login_screen.dart';
import 'package:waverate/src/features/authentication/presentation/signup_screen.dart';
import 'package:waverate/src/features/authentication/presentation/profile_screen.dart';
import 'package:waverate/src/features/authentication/presentation/social_screen.dart';
import 'package:waverate/src/features/music/presentation/home_screen.dart';
import 'package:waverate/src/features/music/presentation/search_screen.dart';
import 'package:waverate/src/features/music/presentation/catalogs_screen.dart';
import 'package:waverate/src/features/music/presentation/artist_detail_screen.dart';
import 'package:waverate/src/features/music/presentation/album_detail_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // Auth Routes (Login/Signup)
      GoRoute(
        path: '/',
        builder: (context, state) => const LoginScreen(),
        routes: [
          GoRoute(
            path: 'signup',
            builder: (context, state) => const SignupScreen(),
          ),
        ],
      ),
      // Authenticated Shell Route (Bottom Nav)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Branch 1: Home (Dashboard)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // Branch 2: Search (Add to Catalog)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          // Branch 3: Social
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/social',
                builder: (context, state) => const SocialScreen(),
              ),
            ],
          ), // Branch 4: Catalogs
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/catalogs',
                builder: (context, state) => const CatalogsScreen(),
              ),
            ],
          ),
          // Branch 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      // Detail Routes (Push over bottom nav)
      GoRoute(
        path: '/artist/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ArtistDetailScreen(artistId: id);
        },
      ),
      GoRoute(
        path: '/album/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return AlbumDetailScreen(albumId: id);
        },
      ),
    ],
  );
});
