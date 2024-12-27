import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

class Item8 extends StatefulWidget {
  final Content content;
  final double height;
  final double indicatorSize;

  const Item8({
    Key? key,
    required this.content,
    this.height = 100,
    this.indicatorSize = 8.0,
  }) : super(key: key);

  @override
  _Item8State createState() => _Item8State();
}

class _Item8State extends State<Item8> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: Colors.grey[200], // Background color
      child: PageView.builder(
        itemCount: widget.content.layoutData!.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        itemBuilder: (context, index) {
          LayoutDatum layoutdata = widget.content.layoutData![index];
          return Image.network(
            layoutdata.image!,
            fit: BoxFit.cover,
            width: double.infinity,
          );
        },
      ),
    );
  }
}
