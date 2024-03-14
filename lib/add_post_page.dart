import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gwengram/post_details.dart';
import 'package:gwengram/post_local_source.dart';
import 'package:gwengram/post_remote_source.dart';
import 'package:gwengram/profile_details.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import 'location_source.dart';
import 'map_page.dart';

class AddNewPost extends StatefulWidget {
  const AddNewPost({super.key});

  @override
  State<AddNewPost> createState() => _AddNewPostState();
}

class _AddNewPostState extends State<AddNewPost> {
  final TextEditingController postDescriptionController =
      TextEditingController();
  LocationData? _locationData;
  File? chosenImageFile;


  void myLocation(double latitude, double longitude) async {
    String address =
        await LocationSource().getAddressFromLatLong(latitude, longitude);
    setState(() {
      _locationData = LocationData(
          latitude: latitude, longitude: longitude, address: address);
    });
  }

  void save() async{
    if (chosenImageFile != null && _locationData != null) {
      final PostDetails postDetails = PostDetails(userId:context.read<UserProfileDetails>().profile!.id ,
          file: chosenImageFile!,
          location: LocationData(
              address: _locationData!.address,
              latitude: _locationData!.latitude,
              longitude: _locationData!.longitude),
          description: postDescriptionController.text);


      await UserPostDetails().insertPost(postDetails);
      await PostRemoteSource().postPost(postDetails);


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {},
          icon: Icon(Icons.arrow_back),
        ),
        title: Text('Add Post'),
      ),
      body: ListenableBuilder(
        listenable: context.read<UserProfileDetails>(),
        builder: (BuildContext context, Widget? child) {
          if(context.read<UserProfileDetails>().profile==null){
            return Center(child: CircularProgressIndicator(),);

          }
          return ListView(
            children: [
              Row(
                children: [
                  CircleAvatar(backgroundImage: FileImage(context.read<UserProfileDetails>().profile!.file),),
                  SizedBox(
                    width: 16,
                  ),
                  Text(context.read<UserProfileDetails>().profile!.userName),
                ],
              ),
              child!
            ],
          );
        },
        child: Column(
          children: [
            GestureDetector(
              onTap: imageset,
              child: Container(
                decoration: BoxDecoration(
                    image: chosenImageFile != null
                        ? DecorationImage(
                            image: FileImage(chosenImageFile!),
                            fit: BoxFit.cover,
                            alignment: Alignment.topCenter)
                        : null,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white30)),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Center(
                    child: chosenImageFile == null
                        ? ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.camera),
                            label: Text('Add Image'))
                        : null,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              height: 200,
              width: double.infinity,
              child: _locationData == null
                  ? const Center(child: Text('No location chosen'))
                  : Image.network(
                      "https://maps.googleapis.com/maps/api/staticmap?center=${_locationData!.latitude},${_locationData!.longitude}&zoom=13&size=600x300&maptype=roadmap&markers=color:blue%7Clabel:S%7C40.702147,-74.015794&markers=color:green%7Clabel:G%7C40.711614,-74.012318&markers=color:green%7Clabel:A%7C${_locationData!.latitude},${_locationData!.longitude}&key=${LocationSource.apiKey}"),
            ),
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
                        permission = await Geolocator.requestPermission();
                        if (permission == LocationPermission.denied) {
                          return;
                        }
                      }

                      if (permission == LocationPermission.deniedForever) {
                        return;
                      }

                      final Position updatedLocation =
                          await Geolocator.getCurrentPosition();
                      String address = await LocationSource()
                          .getAddressFromLatLong(updatedLocation.latitude,
                              updatedLocation.longitude);
                      setState(() {
                        _locationData = LocationData(
                            latitude: updatedLocation.latitude,
                            longitude: updatedLocation.longitude,
                            address: address);
                      });
                    },
                    icon: Icon(Icons.maps_ugc_rounded),
                    label: Text('Get current location')),
                Spacer(),
                TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) {
                          return MapPage(
                              latitude: _locationData?.latitude ?? 40.7142484,
                              longitude:
                                  _locationData?.longitude ?? -73.9614103,
                              myLocation: myLocation);
                        },
                      ));
                    },
                    icon: Icon(Icons.map),
                    label: Text('Select location '))
              ],
            ),
            TextField(
              controller: postDescriptionController,
              decoration: InputDecoration(label: Text('Enter descritpion')),
            ),
            ElevatedButton(onPressed: save, child: Text('+Add post'))
          ],
        ),
      ),
    );
  }
}
