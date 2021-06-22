import 'package:flutter/material.dart';
import 'package:mensa_jt21/calendar/calendar_group_entry.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_widgets.dart';
import 'package:mensa_jt21/screens/calendar_details_screen.dart';

class CalendarListEntryWidget extends StatelessWidget {
  static bool isDebugModeActive = false;

  final CalendarEntry calendarEntry;
  final CalendarEntryGroup calendarEntryGroup;

  const CalendarListEntryWidget(this.calendarEntry, this.calendarEntryGroup);

  @override
  Widget build(BuildContext context) {
    return Theme(
        data: Theme.of(context).copyWith(
          textTheme: TextTheme(
            bodyText2: CalendarEntryTextStyle(calendarEntry),
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
                        padding: EdgeInsets.fromLTRB(0, 0, 8, 0),
                        child: FavoriteButton(calendarEntry),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CalendarDetailsScreen(
                                    calendarEntry: calendarEntry,
                                    calendarEntryGroup: calendarEntryGroup,
                                  ),
                                ));
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: _getEntryElements(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ));
        }));
  }

  List<Widget> _getEntryElements(BuildContext context) {
    List<Widget> elements = List.empty(growable: true);
    if (isDebugModeActive) elements.add(Text("Veranstaltung nr #" + calendarEntry.eventId.toString()));
    elements.add(Text(
      calendarEntry.name,
      softWrap: true,
      style: Theme.of(context).textTheme.bodyText2!.copyWith(
            fontWeight: FontWeight.bold,
          ),
    ));
    elements.add(StartTimeLine(calendarEntry));
    return elements;
  }
}
