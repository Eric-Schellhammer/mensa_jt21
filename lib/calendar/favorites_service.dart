import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _FAVORITES = "favorites";

  SharedPreferences _prefs;
  List<Function> _listeners = List();
  Set<int> _favoriteEvents = Set();

  void initialize() {
    SharedPreferences.getInstance().then((prefs) => this._prefs = prefs).then((__) {
      final storedFavorites = _prefs.getStringList(_FAVORITES);
      if (storedFavorites != null) {
        storedFavorites.forEach((favourite) {
          if (favourite != null) _favoriteEvents.add(int.parse(favourite));
        });
        _callListeners();
      }
    });
  }

  void resetToInitial() {
    _prefs.remove(_FAVORITES);
    _favoriteEvents.clear();
    _callListeners();
  }

  void registerUpdateListener(Function runnable) {
    _listeners.add(runnable);
    _callListeners();
  }

  bool isFavorite(int eventId) {
    return _favoriteEvents.contains(eventId);
  }

  /// toggle the state, return the new state
  bool toggleFavorite(int eventId) {
    bool result;
    if (_favoriteEvents.contains(eventId)) {
      _favoriteEvents.remove(eventId);
      result = false;
    } else {
      _favoriteEvents.add(eventId);
      result = true;
    }
    _callListeners();
    _prefs.setStringList(_FAVORITES, _favoriteEvents.map((favorite) => favorite.toString()).toList());
    return result;
  }

  void _callListeners() {
    _listeners.forEach((listener) {
      listener.call();
    });
  }

  void refreshList() {
    _callListeners();
  }
}
