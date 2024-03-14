import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:gwengram/post_local_source.dart';
import 'package:gwengram/post_remote_source.dart';
import 'package:gwengram/profile_details.dart';
import 'package:uuid/uuid.dart';

class PostDetails{
  late final String id;
  final File file;
  final LocationData location;
  final String description;
  final String userId;

  PostDetails({required this.userId,required this.file, required this.location, required this.description}) : id = const Uuid().v4();

  factory PostDetails.fromJson(String id, Map<String, dynamic> map) {
    return PostDetails(userId:(map['userId']??''),

        file: File(map['image']),
        location: LocationData(
            latitude: map['lat'],
            longitude: map['lng'],
            address: map['address']),
        description: map['description']);
  }
  Map<String, dynamic> toJson() {
    return {
'userId': userId,
      'image': file.path,
      'lat': location.latitude,
      'lng': location.longitude,
      'address': location.address,
      'description':description,
    };}

  @override
  String toString() {
    return 'PostDetails{id: $id, file: $file, location: $location, description: $description, userId: $userId}';
  }
}


class UserPostDetails with ChangeNotifier {

  List<PostDetails> postDetails=[];
  Future<void> loadPost() async {
    final PostRemoteSource localSource = PostRemoteSource();
    postDetails = await localSource.getAllPostDetails();

    notifyListeners();
  }

  Future<void> insertPost(PostDetails newPost) async {
    final PostLocalSource localSource = PostLocalSource();
    await localSource.insertPost(newPost);
    loadPost();
  }
}