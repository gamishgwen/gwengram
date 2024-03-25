import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gwengram/post_details.dart';
import 'package:gwengram/profile_details.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart' as syspath;

import 'location_source.dart';
import 'map_page.dart';

class AddNewPost extends StatefulWidget {
  final PostDetails? postDetails;
  const AddNewPost({
    super.key, this.postDetails
  });

  @override
  State<AddNewPost> createState() => _AddNewPostState();
}

class _AddNewPostState extends State<AddNewPost> {
  late final TextEditingController postDescriptionController =
      TextEditingController(text: widget.postDetails?.description);
  late LocationData? _locationData=widget.postDetails?.location;
  late List<File> imageFileList = widget.postDetails?.images??[];


  void selectImages() async {
    final ImagePicker imagePicker = ImagePicker();
    final List<XFile>? selectedImages = await imagePicker.pickMultiImage();
    print("Image List Length:" + imageFileList.length.toString());
    if (selectedImages != null) {
      setState(() {
        List<File>selectedImageFile=[];
        for (int i = 0; i < selectedImages.length; i++) {
          selectedImageFile.add(File(selectedImages[i].path));
        }
        imageFileList=selectedImageFile;
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

  void save() async {
    if (imageFileList != null && _locationData != null) {
      final PostDetails postDetails = PostDetails(id: widget.postDetails?.id,
          userId: context.read<UserProfileDetails>().profile!.id,
          images: imageFileList,
          location: LocationData(
              address: _locationData!.address,
              latitude: _locationData!.latitude,
              longitude: _locationData!.longitude),
          description: postDescriptionController.text);


     if(widget.postDetails==null){ await context.read<UserPostDetails>().insertPost(postDetails);} else{
      await context.read<UserPostDetails>().updatePost(postDetails);}
    }
  }

  Future<File> copyFileToLocalAppDir(File file) async {
    final Directory appDir = await syspath.getApplicationDocumentsDirectory();
    final String fileName = path.basename(file.path);
    final File copiedFile = await file.copy(path.join(appDir.path, fileName));
    return copiedFile;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back),
        ),
         title: Text(widget.postDetails==null?'Add Post': 'Update Post')  ,
      ),
      body: ListenableBuilder(
        listenable: context.read<UserProfileDetails>(),
        builder: (BuildContext context, Widget? child) {
          if (context.read<UserProfileDetails>().profile == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: FileImage(
                        context.read<UserProfileDetails>().profile!.file),
                  ),
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
            ElevatedButton(
              onPressed: () {
                selectImages();
              },
              child: Text('Select Images'),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CarouselSlider(
                items: [
                  for (int i = 0; i < imageFileList.length; i++)
                    AspectRatio(
                        aspectRatio: 1,
                        child: Image.file(
                          File(imageFileList[i].path),
                          fit: BoxFit.cover,
                          alignment: Alignment.topCenter,
                        ))
                ],
                options: CarouselOptions(
                    aspectRatio: 1,
                    viewportFraction: 1,
                    enableInfiniteScroll: false),
              ),
            ),
            SizedBox(height: 10),
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
            ElevatedButton(onPressed: save, child: Text(widget.postDetails==null?'+Add post':'Update Post'))
          ],
        ),
      ),
    );
  }
}
