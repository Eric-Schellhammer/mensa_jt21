import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_settings_service.dart';
import 'package:mensa_jt21/calendar/favorites_service.dart';

class CalendarListEntryWidget extends StatelessWidget {

  static const brokenHeart = IconData(0xf7a9, fontFamily: "CustomIcons", fontPackage: null);

  static bool isDebugModeActive;

  final CalendarEntry calendarEntry;
  final CalendarDateFormat calendarDateFormat;
  final bool isFavorite;

  const CalendarListEntryWidget(this.calendarEntry, this.calendarDateFormat, this.isFavorite);

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          textTheme: TextTheme(
            bodyText2: TextStyle(
              color: calendarEntry.abgesagt ? Colors.grey : Colors.black,
              decoration: calendarEntry.abgesagt ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
        // additional Builder to transfer the Theme defined above
        child: Builder(builder: (BuildContext context) {
          return Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 8, 8, 8),
                        child: _getIconButton(calendarEntry),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: _getEntryElements(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ));
        }));
  }

  List<Widget> _getEntryElements(BuildContext context) {
    List<Widget> elements = List();
    if (isDebugModeActive) elements.add(Text(calendarEntry.eventId.toString() + " (" + calendarEntry.eventGroupId.toString() + ")"));
    elements.add(Text(
      calendarEntry.name,
      softWrap: true,
      style: Theme.of(context).textTheme.bodyText2.copyWith(
            fontWeight: FontWeight.bold,
          ),
    ));
    elements.add(Text(
      DateFormat(calendarDateFormat.startTimeFormat).format(calendarEntry.start),
      style: Theme.of(context).textTheme.bodyText2,
    ));
    return elements;
  }

  Widget _getIconButton(CalendarEntry calendarEntry) {
    return calendarEntry.takesPlace
        ? IconButton(
            icon: Icon(
              Icons.favorite,
              color: isFavorite ? Colors.pink : Colors.grey[200],
            ),
            onPressed: () {
              GetIt.instance.get<FavoritesService>().toggleFavorite(calendarEntry.eventId);
            },
          )
        : IconButton(
            icon: Icon(
              brokenHeart,
              color: isFavorite ? Colors.purple : Colors.grey.withOpacity(0),
            ),
            onPressed: isFavorite
                ? () {
                    GetIt.instance.get<FavoritesService>().toggleFavorite(calendarEntry.eventId);
                  }
                : null,
          );
  }
}

class CalendarEntryGroup implements Comparable<CalendarEntryGroup> {
  final List<CalendarEntry> entries = List();

  @override
  int compareTo(CalendarEntryGroup other) {
    return entries[0].name.compareTo(other.entries[0].name);
  }
}

class CalendarGroupListWidget extends StatelessWidget {
  final CalendarEntryGroup group;

  const CalendarGroupListWidget(this.group);

  @override
  Widget build(BuildContext context) {
    final CalendarEntry calendarEntry = group.entries[0];
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(calendarEntry.eventGroupId.toString()),
          Text(
            calendarEntry.name,
            softWrap: true,
            style: TextStyle(fontWeight: FontWeight.bold).copyWith(fontSize: 20),
          ),
          Html(
            data: calendarEntry.eventtext,
          ),
        ],
      ),
    );
  }
}
