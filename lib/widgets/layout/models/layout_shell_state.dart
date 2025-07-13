// [layout_shell_state.dart] - ESTADO DEL LAYOUT EXTRAÍDO
// 📁 Ubicación: /lib/widgets/layout/models/layout_shell_state.dart
// 🎯 CLASE DE ESTADO INMUTABLE PARA LAYOUT SHELL

class LayoutShellState {
  final bool isLoading;
  final bool showSearchOverlay;
  final bool showNotificationCenter;
  final int notificationCount;
  
  const LayoutShellState({
    this.isLoading = true,
    this.showSearchOverlay = false,
    this.showNotificationCenter = false,
    this.notificationCount = 3,
  });
  
  LayoutShellState copyWith({
    bool? isLoading,
    bool? showSearchOverlay,
    bool? showNotificationCenter,
    int? notificationCount,
  }) {
    return LayoutShellState(
      isLoading: isLoading ?? this.isLoading,
      showSearchOverlay: showSearchOverlay ?? this.showSearchOverlay,
      showNotificationCenter: showNotificationCenter ?? this.showNotificationCenter,
      notificationCount: notificationCount ?? this.notificationCount,
    );
  }
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LayoutShellState &&
          runtimeType == other.runtimeType &&
          isLoading == other.isLoading &&
          showSearchOverlay == other.showSearchOverlay &&
          showNotificationCenter == other.showNotificationCenter &&
          notificationCount == other.notificationCount;

  @override
  int get hashCode =>
      isLoading.hashCode ^
      showSearchOverlay.hashCode ^
      showNotificationCenter.hashCode ^
      notificationCount.hashCode;

  @override
  String toString() {
    return 'LayoutShellState{isLoading: $isLoading, showSearchOverlay: $showSearchOverlay, showNotificationCenter: $showNotificationCenter, notificationCount: $notificationCount}';
  }
}