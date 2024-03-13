import 'dart:io';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gwengram/local_source.dart';
import 'package:gwengram/profile_details.dart';
import 'package:gwengram/remote_source.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';

import 'location_source.dart';
import 'map_page.dart';

class DetailsPage extends StatefulWidget {
  final ProfileDetails? profile;
  final LocationData? locationData;
  final AllProfileDetails? allprofile;

  const DetailsPage({super.key, this.profile, this.locationData, this.allprofile});

  @override
  State<DetailsPage> createState() => _DetailsPageState();
}

class _DetailsPageState extends State<DetailsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  File? chosenImageFile;
  LocationData? _locationData;
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  late DateTime? selectedDate = widget.profile?.dateOfBirth;
  late Gender selectedGender = widget.profile?.gender ?? Gender.female;
  late UserType selectedUserType =
      widget.profile?.userType ?? UserType.business;

  void save() async {
    if (_formKey.currentState!.validate() &&
        chosenImageFile != null &&
        _locationData != null) {
    final img= await LocalSource().copyFileToLocalAppDir(chosenImageFile!);
      final ProfileDetails profileDetails = ProfileDetails(
          firstNameController.text,
          lastNameController.text,
          userNameController.text,
          selectedDate!,
          selectedGender!,
          selectedUserType!,
          img,
          LocationData(
              address: _locationData!.address,
              latitude: _locationData!.latitude,
              longitude: _locationData!.longitude));


  await AllProfileDetails().insertProfile(profileDetails);
     await ProfileSource().postProfile(profileDetails);
    }
  }

  void imageset() async {
    final XFile? image =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        chosenImageFile = File(image.path);
      });
    }
  }

  void myLocation(double latitude, double longitude) async {
    String address =
        await LocationSource().getAddressFromLatLong(latitude, longitude);
    setState(() {
      _locationData = LocationData(
          latitude: latitude, longitude: longitude, address: address);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('User Details'),
        ),
        body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(children: [
                  GestureDetector(
                    onTap: imageset,
                    child: CircleAvatar(
                      radius: 100,
                      child: Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              image: chosenImageFile != null
                                  ? DecorationImage(
                                      image: FileImage(chosenImageFile!),
                                      fit: BoxFit.fill)
                                  : null,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.white30)),
                          child: Center(
                            child: chosenImageFile == null
                                ? ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.camera),
                                    label: const Text('Take Picture'))
                                : null,
                          )),
                    ),
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  TextFormField(
                    controller: firstNameController,
                    decoration:
                        const InputDecoration(label: Text('Enter firstName')),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 50) {
                        return 'Enter words between 1 and 50';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: lastNameController,
                    decoration:
                        const InputDecoration(label: Text('Enter lastName')),
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          value.trim().length <= 1 ||
                          value.trim().length > 50) {
                        return 'Enter words between 1 and 50';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: userNameController,
                    decoration:
                        const InputDecoration(label: Text('Enter userName')),
                    validator: (name) {
                      String pattern = r'^[a-z]+$'; // Regex for lowercase only
                      RegExp regex = new RegExp(pattern);
                      if (!regex.hasMatch(name!))
                        return 'Username must be lowercase, this will be changed when saved';
                      else
                        return null;
                    },
                  ),
                  TextFormField(
                      decoration: InputDecoration(
                          label: Text(selectedDate == null
                              ? 'no date selected'
                              : DateFormat('dd/MM/yyyy').format(selectedDate!)),
                          icon: TextButton.icon(
                              onPressed: () async {
                                DateTime? updatedDate = await showDatePicker(
                                    context: context,
                                    firstDate: DateTime(1990),
                                    lastDate: DateTime.now(),
                                    currentDate: selectedDate);
                                if (updatedDate != null) {
                                  setState(() {
                                    selectedDate = updatedDate;
                                  });
                                }
                              },
                              icon: Icon(Icons.date_range),
                              label: Text('select date')))),
                  DropdownButtonFormField(
                      value: selectedGender,
                      items: Gender.values.map((e) {
                        return DropdownMenuItem(child: Text(e.name), value: e);
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGender = value!;
                        });
                      }),
                  DropdownButtonFormField(
                      value: selectedUserType,
                      items: UserType.values.map((element) {
                        return DropdownMenuItem(
                            child: Text(element.name), value: element);
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedUserType = value!;
                        });
                      }),
                  const SizedBox(height: 10),
                  Container(
                    height: 200,
                    width: double.infinity,
                    child: _locationData == null
                        ? const Center(child: Text('No location chosen'))
                        : Image.network(
                            "https://maps.googleapis.com/maps/api/staticmap?center=${_locationData!.latitude},${_locationData!.longitude}&zoom=13&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&markers=color:green%7Clabel:G%7C40.711614,-74.012318&markers=color:green%7Clabel:A%7C${_locationData!.latitude},${_locationData!.longitude}&key=${LocationSource.apiKey}"),
                  ),
                  Row(children: [
                    Row(
                      children: [
                        TextButton.icon(
                            onPressed: () async {
                              bool serviceEnabled =
                                  await Geolocator.isLocationServiceEnabled();
                              if (!serviceEnabled) {
                                return;
                              }
                              LocationPermission permission =
                                  await Geolocator.checkPermission();
                              if (permission == LocationPermission.denied) {
                                permission =
                                    await Geolocator.requestPermission();
                                if (permission == LocationPermission.denied) {
                                  return;
                                }
                              }

                              if (permission ==
                                  LocationPermission.deniedForever) {
                                return;
                              }

                              final Position updatedLocation =
                                  await Geolocator.getCurrentPosition();
                              String address = await LocationSource()
                                  .getAddressFromLatLong(
                                      updatedLocation.latitude,
                                      updatedLocation.longitude);
                              setState(() {
                                _locationData = LocationData(
                                    latitude: updatedLocation.latitude,
                                    longitude: updatedLocation.longitude,
                                    address: address);
                              });
                            },
                            icon: const Icon(Icons.location_on_outlined),
                            label: const Text('Get current location'))
                      ],
                    ),
                    Row(
                      children: [
                        TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) {
                                  return MapPage(
                                      latitude:
                                          _locationData?.latitude ?? 40.7142484,
                                      longitude: _locationData?.longitude ??
                                          -73.9614103,
                                      myLocation: myLocation);
                                },
                              ));
                            },
                            icon: const Icon(Icons.map),
                            label: const Text('select on Map'))
                      ],
                    ),
                  ]),
                  ElevatedButton(
                      onPressed: save, child: const Text('Save details'))
                ]),
              ),
            )));
  }
}
