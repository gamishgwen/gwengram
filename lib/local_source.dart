import 'dart:io';

import 'package:gwengram/profile_details.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;

class LocalSource {
  final String _tableName = 'user_details';
  Future<sql.Database> initiateProfileDB() async {
    final String dbPath = await sql.getDatabasesPath();
    final sql.Database db = await sql
        .openDatabase(path.join(dbPath, 'profile.db'), onCreate: (db, version) {
      return db.execute(
          'CREATE TABLE $_tableName(id Text PRIMARY KEY, firstname TEXT,lastname TEXT,username TEXT, dateofbirth INTEGER,gender TEXT, usertype TEXT, image TEXT, lat REAL, lng REAL, address TEXT)');
    }, version: 1);
    return db;
  }

  Future<void> insertProfile(ProfileDetails profileDetails) async {
    final sql.Database db = await initiateProfileDB();
    final int dbRow = await db.insert(_tableName, {
      'id': profileDetails.id,
      'firstname': profileDetails.firstName,
      'lastname': profileDetails.lastName,
      'username': profileDetails.userName,
      'dateofbirth': profileDetails.dateOfBirth.millisecondsSinceEpoch,
      'gender': profileDetails.gender.name,
      'usertype': profileDetails.userType.name,
      'image': profileDetails.file.path,
      'lat': profileDetails.location.latitude,
      'lng': profileDetails.location.longitude,
      'address': profileDetails.location.address,
    });

    print(dbRow);
  }

  Future<ProfileDetails> loadProfile() async {
    final sql.Database db = await initiateProfileDB();
    final List<Map<String, dynamic>> rawProfile = await db.query(_tableName);
    final List<ProfileDetails> profile = rawProfile
        .map((e) => ProfileDetails(
            e['firstname'],
            e['lastname'],
            e['username'],
            DateTime.fromMillisecondsSinceEpoch(e['dateofbirth']),
            Gender.fromString(e['gender']),
            UserType.fromString(e['usertype']),
            File(e['image']),
            LocationData(
                latitude: e['lat'],
                longitude: e['lng'],
                address: e['address'])))
        .toList();
    return profile[0];
  }

  Future<File> copyFileToLocalAppDir(File file) async {
    final Directory appDir = await syspath.getApplicationDocumentsDirectory();
    final String fileName = path.basename(file.path);
    final File copiedFile = await file.copy(path.join(appDir.path, fileName));
    return copiedFile;
  }
}
