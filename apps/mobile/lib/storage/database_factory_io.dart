import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;

DatabaseFactory createDatabaseFactory() => databaseFactory;
Future<String> databasePath() async =>
    p.join(await getDatabasesPath(), 'kombelo.sqlite');
