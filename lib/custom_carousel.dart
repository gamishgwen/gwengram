import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class Carousel extends StatelessWidget {
  final List<File>? imageFileList;
  const Carousel({super.key, required this.imageFileList});

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      items: [
        for (int i = 0; i < imageFileList!.length; i++)
          AspectRatio(aspectRatio: 1,child: Image.file(File(imageFileList![i].path),fit: BoxFit.cover,alignment: Alignment.topCenter,))
      ],
      options: CarouselOptions(aspectRatio: 1,viewportFraction: 1,enableInfiniteScroll: false),
    );
  }
}
