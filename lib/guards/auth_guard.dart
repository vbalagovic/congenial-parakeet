import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_router.gr.dart';
import '../providers/auth_provider.dart';

class AuthGuard extends AutoRouteGuard {
  final WidgetRef ref;

  AuthGuard(this.ref) {
    debugPrint("AuthGuard constructor called with ref: $ref");
  }

  @override
  void onNavigation(NavigationResolver resolver, StackRouter router) {
    debugPrint("AuthGuard.onNavigation called");
    debugPrint("Current route: ${router.current.name}");
    debugPrint("Destination route: ${resolver.route.name}");

    try {
      debugPrint("Reading auth state from provider");
      final authState = ref.read(authProvider);
      debugPrint(
          "Auth state: isAuthenticated=${authState.isAuthenticated}, user=${authState.user}");

      if (authState.isAuthenticated) {
        debugPrint("User is authenticated, allowing navigation");
        resolver.next(true);
      } else {
        debugPrint("User is not authenticated, redirecting to login");
        resolver.next(false);
        debugPrint("Replacing current route with LoginRoute");
        router.replace(const LoginRoute());
      }
    } catch (e) {
      debugPrint("Error in AuthGuard.onNavigation: $e");
      // In case of error, redirect to login as a fallback
      resolver.next(false);
      router.replace(const LoginRoute());
    }
  }
}
