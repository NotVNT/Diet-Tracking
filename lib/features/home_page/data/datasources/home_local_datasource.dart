/// Local data source for home page data
class HomeLocalDataSource {
  int _currentIndex = 0;
  
  /// Get current page index
  int getCurrentIndex() {
    return _currentIndex;
  }
  
  /// Set current page index
  void setCurrentIndex(int index) {
    _currentIndex = index;
  }
}
