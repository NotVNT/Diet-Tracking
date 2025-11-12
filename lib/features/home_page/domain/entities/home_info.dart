/// Entity representing home page information
class HomeInfo {
  final int currentIndex;
  
  HomeInfo({
    required this.currentIndex,
  });
  
  HomeInfo copyWith({
    int? currentIndex,
  }) {
    return HomeInfo(
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
