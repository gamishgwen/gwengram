import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:uuid/uuid.dart';

import 'local_source.dart';

class ProfileDetails {
  late final String id;
  final String firstName;
  final String lastName;
  final String userName;
  final DateTime dateOfBirth;
  final Gender gender;
  final UserType userType;
  final File file;
  final LocationData location;

  ProfileDetails(this.firstName, this.lastName, this.userName, this.dateOfBirth,
      this.gender, this.userType, this.file, this.location,{String? id})
      : id = id ?? const Uuid().v4();

  factory ProfileDetails.fromJson(String id, Map<String, dynamic> map) {
    return ProfileDetails(
        map['firstname'],
        map['lastname'],
        map['username'],
        DateTime.fromMillisecondsSinceEpoch(map['dateofbirth']),
        Gender.fromString(map['gender']),
        UserType.fromString(map['usertype']),
        File(map['image']),
        LocationData(
            latitude: map['lat'],
            longitude: map['lng'],
            address: map['address']),id: id);
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'firstname': firstName,
      'lastname': lastName,
      'username': userName,
      'dateofbirth': dateOfBirth.millisecondsSinceEpoch,
      'gender': gender.name,
      'usertype': userType.name,
      'image': file.path,
      'lat': location.latitude,
      'lng': location.longitude,
      'address': location.address,
    };
  }

  @override
  String toString() {
    return 'ProfileDetails{id: $id, firstName: $firstName, lastName: $lastName, userName: $userName, dateOfBirth: $dateOfBirth, gender: $gender, userType: $userType, file: $file, location: $location}';
  }
}

enum Gender {
  male,
  female,
  both,
  none;

  static Gender fromString(String gender) {
    if (gender == 'male') {
      return Gender.male;
    } else if (gender == 'female') {
      return Gender.female;
    } else if (gender == 'both') {
      return Gender.both;
    } else if (gender == 'none') {
      return Gender.none;
    }
    throw Exception('Gender type $gender not found');
  }
}

enum UserType {
  creator,
  consumer,
  business,
  entrepreneur;

  static UserType fromString(String userType) {
    if (userType == 'creator') {
      return UserType.creator;
    } else if (userType == 'consumer') {
      return UserType.consumer;
    } else if (userType == 'business') {
      return UserType.business;
    } else if (userType == 'entrepreneur') {
      return UserType.entrepreneur;
    }
    throw Exception('User type $userType not found');
  }
}

class LocationData {
  final double latitude;
  final double longitude;
  final String address;

  LocationData(
      {required this.latitude, required this.longitude, required this.address});

  @override
  String toString() {
    return 'LocationData{latitude: $latitude, longitude: $longitude, address: $address}';
  }
}

class UserProfileDetails with ChangeNotifier {
  ProfileDetails? profile;
  Future<void> loadProfile() async {
    final LocalSource localSource = LocalSource();
    profile = await localSource.loadProfile();
    notifyListeners();
  }

  Future<void> insertProfile(ProfileDetails NewProfile) async {
    final LocalSource localSource = LocalSource();
    await localSource.insertProfile(NewProfile);
    loadProfile();
  }
}
