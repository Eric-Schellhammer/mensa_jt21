import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_settings_service.dart';
import 'package:mensa_jt21/calendar/favorites_service.dart';
import 'package:mensa_jt21/initialize/debug_settings.dart';
import 'package:mensa_jt21/initialize/storage_service.dart';
import 'package:mensa_jt21/online/online_calendar.dart';
import 'package:mensa_jt21/online/online_service.dart';

class Application extends InheritedWidget {
  Application({@required Widget child}) : super(child: child) {
    GetIt.instance.registerSingleton<StorageService>(StorageService());
    GetIt.instance.registerSingleton<DebugSettings>(DebugSettings());
    GetIt.instance.registerSingleton<CalendarSettingsService>(CalendarSettingsService());
    GetIt.instance.registerSingleton<FavoritesService>(FavoritesService());
    GetIt.instance.registerSingleton<OnlineService>(OnlineService());
    GetIt.instance.registerSingleton<OnlineCalendar>(_getOnlineCalendarImpl());
    GetIt.instance.registerSingleton<CalendarService>(CalendarService());
  }

  OnlineCalendar _getOnlineCalendarImpl() {
    final debugSettings = GetIt.instance.get<DebugSettings>();
    final impl = OnlineCalendarImpl();
    return debugSettings.activateDebugMode ? _OnlineCalendarWithDebug(debugSettings, impl) : impl;
  }

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return false;
  }
}

class _OnlineCalendarWithDebug implements OnlineCalendar {
  final DebugSettings debugSettings;
  final OnlineCalendar proxy;

  _OnlineCalendarWithDebug(this.debugSettings, this.proxy);

  Future<String> getCalendarDateJson() {
    if (debugSettings.simulatedCalendarUpdate != null) return Future.value(debugSettings.simulatedCalendarUpdate);
    return proxy.getCalendarDateJson();
  }

  Future<String> getCalendarJson() {
    if (debugSettings.simulatedCalendar != null) return Future.value(debugSettings.simulatedCalendar);
    return proxy.getCalendarJson();
  }
}
