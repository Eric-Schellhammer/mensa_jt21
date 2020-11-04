import 'dart:async';

import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class StorageService { // TODO if this remains unused, remove it
  Future<Database> database;

  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();
    database = openDatabase(
      join(await getDatabasesPath(), 'jt_settings.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE config(key STRING PRIMARY KEY, value TEXT)",
        );
      },
      version: 1,
    );
  }

  Future<void> set(String key, String value) async {
    final Database db = await database;
    await db.insert(
      'config',
      {'key': key, 'value': value},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String> get(String key) async {
    final Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('config');
    final Map<String, dynamic> entry = maps.firstWhere((entry) => entry['key'] == key);
    return entry != null ? entry['value'].toString() : null;
  }
}
