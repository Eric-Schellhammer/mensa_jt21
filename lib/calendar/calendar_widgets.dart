import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';
import 'package:mensa_jt21/calendar/calendar_settings_service.dart';
import 'package:intl/intl.dart';

import 'favorites_service.dart';

class FavoriteButton extends StatelessWidget {
  static void initialize(Function(BuildContext, CalendarEntry) toggleFavoriteState) {
    FavoriteButton._toggleFavoriteState = toggleFavoriteState;
  }

  static const brokenHeart = IconData(0xf7a9, fontFamily: "CustomIcons", fontPackage: null);

  static final FavoritesService _favoritesService = GetIt.instance.get<FavoritesService>();
  static Function(BuildContext, CalendarEntry)? _toggleFavoriteState;
  final CalendarEntry _calendarEntry;

  const FavoriteButton(this._calendarEntry);

  @override
  Widget build(BuildContext context) {
    final isFavorite = _favoritesService.isFavorite(_calendarEntry.eventId);
    return _calendarEntry.takesPlace
        ? IconButton(
            icon: Icon(
              Icons.favorite,
              color: isFavorite ? Colors.pink : Colors.grey[300],
            ),
            onPressed: () => _toggleFavoriteState!.call(context, _calendarEntry),
          )
        : IconButton(
            icon: Icon(
              brokenHeart,
              color: isFavorite ? Colors.purple : Colors.grey.withOpacity(0),
            ),
            onPressed: isFavorite ? () => _toggleFavoriteState!.call(context, _calendarEntry) : null,
          );
  }
}

class TitleAndElement extends StatelessWidget {
  final String title;
  final Widget value;
  final TextStyle? textStyle;

  const TitleAndElement({required this.title, required this.value, this.textStyle});

  static void addIfNotNull(List<Widget> entries, String title, String? value) {
    if (value != null && value.isNotEmpty) entries.add(TitleAndElement(title: title, value: Text(value)));
  }

  static void addIfNotNullWithStyle(List<Widget> entries, String title, String? value, TextStyle textStyle) {
    if (value != null && value.isNotEmpty)
      entries.add(TitleAndElement(
        title: title,
        value: Text(
          value,
          style: textStyle,
        ),
        textStyle: textStyle,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title + ": ",
            style: textStyle != null ? textStyle!.copyWith(fontWeight: FontWeight.bold) : TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: value),
        ],
      ),
    );
  }
}

class StartTimeLine extends StatelessWidget {
  static CalendarDateFormat? calendarDateFormat;

  final CalendarEntry _calendarEntry;

  const StartTimeLine(this._calendarEntry);

  @override
  Widget build(BuildContext context) {
    return Text(
      DateFormat(calendarDateFormat!.startTimeFormat).format(_calendarEntry.start),
      style: CalendarEntryTextStyle(_calendarEntry),
    );
  }
}

class CalendarEntryTextStyle extends TextStyle {
  final CalendarEntry _calendarEntry;

  CalendarEntryTextStyle(this._calendarEntry);

  @override
  Color get color => _calendarEntry.abgesagt ? Colors.grey : Colors.black;

  @override
  get decoration => _calendarEntry.abgesagt ? TextDecoration.lineThrough : super.decoration;
}
