import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const _FAVORITES = "favorites";

  late final Future<SharedPreferences> _prefs;
  List<Function> _listeners = List.empty(growable: true);
  Set<int> _favoriteEvents = Set();  // TODO store into moor

  void initialize() {
    _prefs = SharedPreferences.getInstance();
    _prefs.then((prefs) {
      final List<String?>? storedFavorites = prefs.containsKey(_FAVORITES) ? prefs.getStringList(_FAVORITES) : null;
      if (storedFavorites != null) {
        storedFavorites.forEach((favourite) {
          if (favourite != null) _favoriteEvents.add(int.parse(favourite));
        });
        _callListeners();
      }
    });
  }

  void resetToInitial() {
    _prefs..then((prefs) => prefs.remove(_FAVORITES));
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
    _prefs.then((prefs) => prefs.setStringList(_FAVORITES, _favoriteEvents.map((favorite) => favorite.toString()).toList()));
    return result;
  }

  void refreshList() {
    _callListeners();
  }

  void _callListeners() {
    _listeners.forEach((listener) => listener.call());
  }
}
