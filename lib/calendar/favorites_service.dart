import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const FAVORITES = "favorites";

  SharedPreferences _prefs;
  List<Function> _listeners = List();
  Set<int> _favoriteEvents = Set();

  void initialize() {
    SharedPreferences.getInstance().then((prefs) => this._prefs = prefs).then((__) {
      final storedFavorites = _prefs.getStringList(FAVORITES);
      if (storedFavorites != null) {
        storedFavorites.forEach((favourite) {
          if (favourite != null) _favoriteEvents.add(int.parse(favourite));
        });
        _listeners.forEach((listener) {
          listener.call();
        });
      }
    });
  }

  void registerUpdateListener(Function runnable) {
    _listeners.add(runnable);
  }

  bool isFavorite(int eventId) {
    return _favoriteEvents.contains(eventId);
  }

  void toggleFavorite(int eventId) {
    if (_favoriteEvents.contains(eventId))
      _favoriteEvents.remove(eventId);
    else
      _favoriteEvents.add(eventId);
    _listeners.forEach((listener) {
      listener.call();
    });
    _prefs.setStringList(
        FAVORITES,
        _favoriteEvents.map((favorite) {
          favorite.toString();
        }).toList());
  }
}