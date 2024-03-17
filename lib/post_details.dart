import 'dart:io';


import 'package:flutter/cupertino.dart';
import 'package:gwengram/post_local_source.dart';
import 'package:gwengram/post_remote_source.dart';
import 'package:gwengram/profile_details.dart';
import 'package:uuid/uuid.dart';

class PostDetails {
  late final String id;
  final List<File> images;
  final LocationData location;
  final String description;
  final String userId;

  PostDetails(
      {required this.userId,
      required this.images,
      required this.location,
      required this.description,
      String? id})
      : id = id ?? const Uuid().v4();

  factory PostDetails.fromJson(String id, Map<String, dynamic> map) {
    return PostDetails(
        id: id,
        userId: (map['userId'] ?? ''),
        images: (map['images'] as List).map((e) => File(e)).toList(),
        location: LocationData(
            latitude: map['lat'],
            longitude: map['lng'],
            address: map['address']),
        description: map['description']);
  }
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'images': images.map((e) => e.path).toList(),
      'lat': location.latitude,
      'lng': location.longitude,
      'address': location.address,
      'description': description,
    };
  }

  @override
  String toString() {
    return 'PostDetails{id: $id, images: $images, location: $location, description: $description, userId: $userId}';
  }
}

class UserPostDetails with ChangeNotifier {
  List<PostDetails> postDetails = [];
  Future<void> loadPost() async {
    final PostRemoteSource localSource = PostRemoteSource();
    // final PostLocalSource localSource = PostLocalSource();
    postDetails = await localSource.getAllPostDetails();

    notifyListeners();
  }

  Future<void> insertPost(PostDetails newPost) async {
    final PostLocalSource localSource = PostLocalSource();
    await localSource.insertPost(newPost);
    await PostRemoteSource().postPost(newPost);
    loadPost();
  }
  Future<void> remove(String id) async{
    final PostLocalSource localSource=PostLocalSource();
    await localSource.delete(id);
    await PostRemoteSource().remove(id);

   loadPost();
  }
}
