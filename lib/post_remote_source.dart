import 'dart:convert';

import 'package:gwengram/post_details.dart';
import 'package:http/http.dart' as http;

class PostRemoteSource {
  Future<List<PostDetails>> getAllPostDetails() async {
    final url = Uri.https(
        'gwengram-3f74b-default-rtdb.europe-west1.firebasedatabase.app',
        'posts.json');
    final http.Response response = await http.get(url);
    Map<String, dynamic> map = jsonDecode((response.body));
    List<PostDetails> post = map.entries
        .map((mapValue) => PostDetails.fromJson(mapValue.key, mapValue.value))
        .toList();
    return post;
  }

  Future<void> postPost(PostDetails postDetails) async {
    final url = Uri.https(
        'gwengram-3f74b-default-rtdb.europe-west1.firebasedatabase.app',
        'posts/${postDetails.id}.json');
    final http.Response response = await http.put(url,
        headers: {'content-type': 'application/json'},
        body: jsonEncode(postDetails.toJson()));
  }

  Future<void> remove(String id) async {
    final updatedUrl = Uri.https(
        'gwengram-3f74b-default-rtdb.europe-west1.firebasedatabase.app',
        'posts/${id}.json');
    final http.Response response = await http.delete(updatedUrl);
  }
}
