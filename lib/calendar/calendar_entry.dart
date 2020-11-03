import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_settings_service.dart';
import 'package:mensa_jt21/calendar/favorites_service.dart';

class CalendarListEntryWidget extends StatelessWidget {
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
                        child: IconButton(
                          icon: Icon(
                            Icons.favorite,
                            color: isFavorite ? Colors.pink : Colors.grey[200],
                          ),
                          onPressed: () {
                            GetIt.instance.get<FavoritesService>().toggleFavorite(calendarEntry.eventId);
                          },
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(calendarEntry.eventId.toString() + " (" + calendarEntry.eventGroupId.toString() + ")"),
                            Text(
                              calendarEntry.name,
                              softWrap: true,
                              style: Theme.of(context).textTheme.bodyText2.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            Text(
                              DateFormat(calendarDateFormat.startTimeFormat).format(calendarEntry.start),
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ));
        }));
  }
}
