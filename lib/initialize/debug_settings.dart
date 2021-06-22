class DebugSettings {

  static const bool debugModeAvailable = true;

  bool _isDebugModeActive = false;
  String? simulatedCalendarUpdate;
  String? simulatedCalendar;

  set activateDebugMode(bool setActive) {
    _isDebugModeActive = setActive;
  }

  bool isDebugModeActive() {
    return debugModeAvailable && _isDebugModeActive;
  }
}