import 'dart:convert';

import 'package:gwengram/profile_details.dart';
import 'package:http/http.dart'as http;


class ProfileSource{
   Future <ProfileDetails> getAllProfileDetails() async{
 final url=Uri.https('gwengram-3f74b-default-rtdb.europe-west1.firebasedatabase.app','users.json');
 final http.Response response = await http.get(url);
 Map<String, dynamic> map = jsonDecode((response.body));
 List<ProfileDetails> profile = map.entries
     .map((mapValue) => ProfileDetails.fromJson(mapValue.key, mapValue.value))
     .toList();
 return profile[0];
  }

Future<void> postProfile(ProfileDetails profileDetails) async{
  final url=Uri.https('gwengram-3f74b-default-rtdb.europe-west1.firebasedatabase.app','users/${profileDetails.id}.json');
final http.Response response = await http.put(url,headers: {'content-type': 'application/json'},body: jsonEncode(profileDetails.toJson()));

}

}