import 'dart:convert';

import 'package:http/http.dart' as http;

class LocationSource {
  static String apiKey = 'AIzaSyCFLbkIsDOzqWceVMPyxXM65PhnHwa_9i0';

  Future<String> getAddressFromLatLong(double lat, double long) async {
    Uri url = Uri.https("maps.googleapis.com", 'maps/api/geocode/json', {
      'latlng': '$lat,$long',
      'key': apiKey
    });
    final http.Response response = await http.get(url);
    Map<String, dynamic> map= jsonDecode(response.body);
    return map['results'][0]['formatted_address'];
  }
}
