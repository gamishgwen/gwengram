import 'dart:io';

import 'package:gwengram/post_details.dart';
import 'package:gwengram/profile_details.dart';
import 'package:sqflite/sqflite.dart'as sql;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;

class PostLocalSource{
  final String _tableName = 'post_details';
  Future<sql.Database> initiatePostDB() async {
    final String dbPath = await sql.getDatabasesPath();
    final sql.Database db = await sql
        .openDatabase(path.join(dbPath, 'post_db.db'), onCreate: (db, version) async {
      return await db.execute(
          'CREATE TABLE $_tableName(id Text PRIMARY KEY, userId TEXT,image TEXT, lat REAL, lng REAL, address TEXT, description TEXT)');
    }, version: 1);
    return db;
  }


  Future<void> insertPost(PostDetails postDetails) async {
    final sql.Database db = await initiatePostDB();
    final int dbRow = await db.insert(_tableName, {
      'id': postDetails.id,
      'image': postDetails.file.path,
      'lat': postDetails.location.latitude,
      'lng': postDetails.location.longitude,
      'address': postDetails.location.address,
      'description': postDetails.description,
      'userId': postDetails.userId
    });


  }

  Future<List<PostDetails>> loadPost() async {
    final sql.Database db = await initiatePostDB();
    final List<Map<String, dynamic>> rawPost= await db.query(_tableName);
    final List<PostDetails> post = rawPost
        .map((e) => PostDetails(id: e['id'],userId: (e['userId'] ?? ''),
       file: File(e['image']),
       location:  LocationData(
            latitude: e['lat'],
            longitude: e['lng'],
            address: e['address'],
        ),description: e['description']))
        .toList();
    return post;
  }

  Future<void>delete(String id) async{
    print(id);
    final posts =await loadPost();
    print(posts);
    final sql.Database db= await  initiatePostDB();
    final int dbRow = await db.delete(_tableName,where:'id=?',whereArgs: [id]);

    

  }
  Future<File> copyFileToLocalAppDir(File file) async {
    final Directory appDir = await syspath.getApplicationDocumentsDirectory();
    final String fileName = path.basename(file.path);
    final File copiedFile = await file.copy(path.join(appDir.path, fileName));
    return copiedFile;
}}