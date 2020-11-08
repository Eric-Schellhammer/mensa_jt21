import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mensa_jt21/calendar/calendar_service.dart';

import 'favorites_service.dart';

class FavoriteButton extends StatelessWidget {
  static void initialize(FavoritesService favoritesService, Function(BuildContext, CalendarEntry) toggleFavoriteState) {
    FavoriteButton._favoritesService = favoritesService;
    FavoriteButton._toggleFavoriteState = toggleFavoriteState;
  }

  static const brokenHeart = IconData(0xf7a9, fontFamily: "CustomIcons", fontPackage: null);

  static FavoritesService _favoritesService;
  static Function(BuildContext, CalendarEntry) _toggleFavoriteState;
  final CalendarEntry _calendarEntry;

  const FavoriteButton(this._calendarEntry);

  @override
  Widget build(BuildContext context) {
    final isFavorite = _favoritesService.isFavorite(_calendarEntry.eventId);
    return _calendarEntry.takesPlace
        ? IconButton(
            icon: Icon(
              Icons.favorite,
              color: isFavorite ? Colors.pink : Colors.grey[200],
            ),
            onPressed: () {
              _toggleFavoriteState.call(context, _calendarEntry);
            },
          )
        : IconButton(
            icon: Icon(
              brokenHeart,
              color: isFavorite ? Colors.purple : Colors.grey.withOpacity(0),
            ),
            onPressed: isFavorite
                ? () {
                    _toggleFavoriteState.call(context, _calendarEntry);
                  }
                : null,
          );
  }
}
