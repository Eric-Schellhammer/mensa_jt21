abstract class OnlineCalendar {
  Future<String> getCalendarDateJson();

  Future<String> getCalendarJson();
}

class OnlineCalendarImpl implements OnlineCalendar {
  Future<String> getCalendarDateJson() {
    // https://event-orga.mensa.de/getAppJSON.php?jt=jt2020&changedate
    return Future.value("{\"date\":\"2020-02-23 17:30:41\"}");
  }

  Future<String> getCalendarJson() {
    // https://event-orga.mensa.de/getAppJSON.php?jt=jt2020
    return Future.value("{}");
  }
}
