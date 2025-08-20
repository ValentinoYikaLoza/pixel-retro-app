import 'package:flutter_riverpod/flutter_riverpod.dart';

final navigationProvider =
    StateNotifierProvider<NavigationNotifier, NavigationState>((ref) {
      return NavigationNotifier(ref);
    });

class NavigationNotifier extends StateNotifier<NavigationState> {
  NavigationNotifier(this.ref) : super(NavigationState());

  final Ref ref;

  void navigateTo(int routeId) {
    if (routeId != state.currentRoute) {
      state = state.copyWith(currentRoute: routeId);
    }
  }
}

class NavigationState {
  final int currentRoute;

  NavigationState({this.currentRoute = 0});

  NavigationState copyWith({int? currentRoute}) {
    return NavigationState(currentRoute: currentRoute ?? this.currentRoute);
  }
}
