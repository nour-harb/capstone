import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'navigation_notifier.g.dart';

class NavigationState {
  final int selectedIndex;
  final bool isBottomBarVisible;

  NavigationState({
    required this.selectedIndex,
    this.isBottomBarVisible = true,
  });

  NavigationState copyWith({int? selectedIndex, bool? isBottomBarVisible}) {
    return NavigationState(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isBottomBarVisible: isBottomBarVisible ?? this.isBottomBarVisible,
    );
  }
}

@Riverpod(keepAlive: true)
class NavigationNotifier extends _$NavigationNotifier {
  @override
  NavigationState build() {
    return NavigationState(selectedIndex: 0);
  }

  void setSelectedIndex(int index) {
    state = state.copyWith(selectedIndex: index);
  }

  void setBottomBarVisible(bool visible) {
    if (state.isBottomBarVisible == visible) return;
    state = state.copyWith(isBottomBarVisible: visible);
  }
}
