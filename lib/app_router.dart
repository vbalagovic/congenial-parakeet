import 'package:auto_route/auto_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:real_social/app_router.gr.dart';
import 'guards/auth_guard.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  final WidgetRef ref;
  late final AuthGuard _authGuard;

  AppRouter({required this.ref}) : super() {
    _authGuard = AuthGuard(ref);
  }

  @override
  RouteType get defaultRouteType {
    return const RouteType.material();
  }

  @override
  List<AutoRoute> get routes {
    try {
      final routes = [
        AutoRoute(
          page: LoginRoute.page,
          initial: true,
          path: '/',
        ),
        AutoRoute(
          page: AppRoute.page,
          path: '/app',
          guards: [_authGuard],
        ),
      ];
      return routes;
    } catch (e) {
      // Return a minimal route configuration in case of error
      return [
        AutoRoute(page: LoginRoute.page, initial: true, path: '/'),
      ];
    }
  }
}
