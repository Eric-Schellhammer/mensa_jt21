import 'package:get_it/get_it.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum OnlineMode {
  INITIAL, // not specified yet
  OFFLINE, // not online at all
  MANUAL, // manually check if updates are available, and manually update
  AUTOMATIC, // automatically check if updates are available, but update manually
  ON_DEMAND, // manually check if updates are available, but update automatically if this is the case
  ONLINE // automatically load updates if available
}

class OnlineService {
  static const _ONLINE_MODE = "onlineMode";

  late final Future<SharedPreferences> _prefs;
  final List<Function(OnlineMode)> _listeners = List.empty(growable: true);
  OnlineMode _mode = OnlineMode.INITIAL;

  void init() {
    _prefs = SharedPreferences.getInstance();
    _prefs.then((prefs) {
      final String? onlineModeString = prefs.getString(_ONLINE_MODE);
      setOnlineMode(OnlineMode.values.firstWhere((mode) => mode.toString() == onlineModeString, orElse: () => OnlineMode.INITIAL));
    });
  }

  void resetToInitial() {
    setOnlineMode(OnlineMode.INITIAL);
  }

  void registerModeListener(Function(OnlineMode) listener) {
    _listeners.add(listener);
    listener.call(_mode);
  }

  void setOnlineMode(OnlineMode mode) {
    _mode = mode;
    _prefs.then((prefs) => prefs.setString(_ONLINE_MODE, mode.toString()));
    _listeners.forEach((listener) {
      listener.call(_mode);
    });
  }

  OnlineMode getOnlineModeOnce() {
    return _mode;
  }

  String getDescription(OnlineMode mode) {
    switch (mode) {
      case OnlineMode.OFFLINE:
        return "Die App geht gar nicht online. "
            "Keine mobilen Daten werden verwendet.";
      case OnlineMode.MANUAL:
        return "Die App geht nicht von alleine online. "
            "Du hast die volle Kontrolle. "
            "Du kannst prüfen, ob Aktualisierungen vorliegen, wann es dir passt, "
            "und diese auch dann herunterladen, wann es dir passt. "
            "Es werden keine Bilder nachgeladen.";
      case OnlineMode.ON_DEMAND:
        return "Die App geht nicht von alleine online. "
            "Du kannst prüfen, ob Aktualisierungen vorliegen, wann es dir passt. "
            "Sollte es welche geben, werden diese automatisch heruntergeladen. "
            "Es werden keine Bilder nachgeladen.";
      case OnlineMode.AUTOMATIC:
        return "Die App geht von Zeit zu Zeit online, um zu prüfen, ob Aktualisierungen vorliegen. "
            "Dies benötigt nur minimal mobile Daten. "
            "Du kannst die Aktualisierungen dann herunterladen, wann es dir passt. "
            "Es werden keine Bilder nachgeladen.";
      case OnlineMode.ONLINE:
        return "Die App geht von Zeit zu Zeit online, um zu prüfen, ob Aktualisierungen vorliegen, "
            "und wird diese automatisch herunterladen. "
            "Bilder (z. B. in den detaillierten Beschreibungen der Veranstaltungen) werden automatisch nachgeladen. "
            "Dies ist die maximale Automatisierung; sie verbraucht allerdings auch am meisten mobile Daten.";
      case OnlineMode.INITIAL:
      // fall-through in this illegal case
    }
    return "";
  }

  void performAutomaticPollingIfActive() {
    switch (_mode) {
      case OnlineMode.AUTOMATIC:
        GetIt.instance.get<CalendarService>().checkIfUpdateAvailable();
        break;
      case OnlineMode.ONLINE:
        GetIt.instance.get<CalendarService>().checkForUpdateAndLoad();
        break;
      default:
        // do nothing in other cases
        break;
    }
  }
}
