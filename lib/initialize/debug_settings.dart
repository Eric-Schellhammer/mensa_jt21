class DebugSettings {

  static bool debugModeAvailable = true;

  bool activateDebugMode = true;
  String simulatedCalendarUpdate;
  String simulatedCalendar;

  bool isDebugModeActive() {
    return debugModeAvailable && activateDebugMode;
  }
}