import 'package:shared_preferences/shared_preferences.dart';

enum OnlineMode {
  OFFLINE, // not online at all
  MANUAL, // manually check if updates are available, and manually update
  AUTOMATIC, // automatically check if updates are available, but update manually
  ON_DEMAND, // manually check if updates are available, but update automatically if this is the case
  ONLINE // automatically load updates if available
}

class OnlineService {
  static const _ONLINE_MODE = "onlineMode";

  SharedPreferences _prefs;
  OnlineMode _mode;

  List<Function(OnlineMode)> _listeners = List();

  void init() {
    SharedPreferences.getInstance().then((prefs) => this._prefs = prefs).then((__) {
      final String onlineModeString = _prefs.get(_ONLINE_MODE);
      setOnlineMode(OnlineMode.values.firstWhere((mode) => mode.toString() == onlineModeString, orElse: () => OnlineMode.OFFLINE));
    });
  }

  void registerModeListener(Function(OnlineMode) listener) {
    _listeners.add(listener);
    listener.call(_mode);
  }

  void setOnlineMode(OnlineMode mode) {
    _mode = mode;
    _prefs.setString(_ONLINE_MODE, mode.toString());
    _listeners.forEach((listener) {
      listener.call(_mode);
    });
  }

  String getDescription(OnlineMode mode) {
    switch (mode) {
      case OnlineMode.OFFLINE:
        return "Die App geht gar nicht online. Keine mobilen Daten werden verwendet.";
      case OnlineMode.MANUAL:
        return "Die App geht nicht von alleine online. Du hast die volle Kontrolle. Du kannst prüfen, ob Aktualisierungen vorliegen, wann es dir passt, und diese auch dann herunterladen, wann es dir passt.";
      case OnlineMode.ON_DEMAND:
        return "Die App geht nicht von alleine online. Du kannst prüfen, ob Aktualisierungen vorliegen, wann es dir passt. Sollte es welche geben, werden diese automatisch heruntergeladen.";
      case OnlineMode.AUTOMATIC:
        return "Die App geht von Zeit zu Zeit online, um zu prüfen, ob Aktualisierungen vorliegen. Dies benötigt nur minimal mobile Daten. Du kannst die Aktualisierungen dann herunterladen, wann es dir passt.";
      case OnlineMode.ONLINE:
        return "Die App geht von Zeit zu Zeit online, um zu prüfen, ob Aktualisierungen vorliegen, und wird diese automatisch herunterladen. Dies ist die maximale Automatisierung; sie verbraucht allerdings auch am meisten mobile Daten.";
    }
    return "";
  }
}
