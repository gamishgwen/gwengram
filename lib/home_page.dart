import 'package:flutter/material.dart';
import 'package:gwengram/add_post_page.dart';
import 'package:gwengram/post_details.dart';
import 'package:gwengram/profile_details.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Feeds'),
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) {
                      return AddNewPost();
                    },
                  ));
                },
                icon: Icon(Icons.add))
          ],
        ),
        body: ListenableBuilder(
          listenable: context.read<UserPostDetails>(),
          builder: (BuildContext context, child) => ListenableBuilder(
            listenable: context.read<UserProfileDetails>(),
            builder: (BuildContext context, child) => ListenableBuilder(
              listenable: context.read<UserProfileDetails>(),
              builder: (BuildContext context, child) => ListView.builder(
                itemCount: context.read<UserPostDetails>().postDetails.length,
                itemBuilder: (BuildContext context, index) => Column(
                  children: [SizedBox(height: 8,),
                    Row(
                      children: [
                        CircleAvatar(backgroundImage:FileImage(context.read<UserProfileDetails>().profile!.file)),
                        SizedBox(
                          width: 8,
                        ),
                        Column(crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(context.read<UserProfileDetails>().profile!.userName),
                            Text(context.read<UserPostDetails>().postDetails[index].location.address),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Container(
                      height: 200,
                      width: double.infinity,
                      child: AspectRatio(aspectRatio: 1,child: Image.file(fit: BoxFit.cover,alignment: Alignment.topCenter,context.read<UserPostDetails>().postDetails[index].file,),
                      ),
                    ),SizedBox(height: 8,),
                    Align(
                        alignment: Alignment.topLeft, child: Text(context.read<UserPostDetails>().postDetails[index].description))
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
