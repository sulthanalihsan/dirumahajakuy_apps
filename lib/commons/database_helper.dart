import 'dart:io';

import 'package:dirumahajakuy/models/challenge_response.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

class DatabaseHelper {
  Database _database;

  DatabaseHelper._();

  //attribut yang di akses class luar
  static final DatabaseHelper db = DatabaseHelper._();

  Future<Database> get database async {
    if (_database != null) {
      return _database;
    } else {
      _database = await getDatabaseInstance();
      return _database;
    }
  }

  //membuat instance database sqlite
  Future<Database> getDatabaseInstance() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, 'challenge.db');

    return openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      await db.execute("CREATE TABLE Challenge("
          "id integer ,"
          "brand_sponsor TEXT ,"
          "brand_image TEXT ,"
          "challenge_name TEXT ,"
          "challenge_duration_hour integer ,"
          "prize_title TEXT,"
          "prize TEXT,"
          "prize_description TEXT,"
          "status integer,"
          "challenge_ended TEXT,"
          "challenge_ended_str TEXT"
          ")");
    });
  }

  Future<int> insertChallenge(Challenge challenge) async {
    final db = await database;
    var raw = await db.insert('Challenge', challenge.toJson());
    return raw;
  }

  Future<List<Challenge>> getAllChallange(int status) async {
    final db = await database;
    var data = await db.query(
        'Challenge  where status = $status order by challenge_ended asc');

    List<Challenge> list =
        data.map((item) => Challenge.fromJson(item)).toList();

    return list;
  }

//  Future<List<Challenge>> getChallenge(int status) async {
//    final db = await database;
//    var data = await db.query(
//        'Challenge  where status = $status order by challenge_ended asc');
//
//    List<Challenge> list =
//    data.map((item) => Challenge.fromJson(item)).toList();
//
//    return list;
//  }

  //Delete client with id
  Future<int> deleteChallengeById(int id) async {
    final db = await database;
    return db.delete("Challenge", where: "id = ?", whereArgs: [id]);
  }

  Future<int> setChallenge(Challenge challenge, int status) async {
    challenge.status = status;
    final db = await database;
    var response = await db.update("Challenge", challenge.toJson(),
        where: "id = ?", whereArgs: [challenge.id]);
    return response;
  }

  Future<int> deleteAllChallenge() async {
    final db = await database;
    return db.delete("Challenge", where: "status = ?", whereArgs: [1]);
  }

//
//  //Update
//  updateClient(ModelClient client) async {
//    final db = await database;
//    var response = await db.update("Client", client.toMap(),
//        where: "id = ?", whereArgs: [client.id]);
//    return response;
//  }

}
