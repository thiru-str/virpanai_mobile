import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

class Item1 extends StatefulWidget {
  final Content content;
  final double height;
  final double indicatorSize;

  const Item1({
    Key? key,
    required this.content,
    this.height = 200,
    this.indicatorSize = 8.0,
  }) : super(key: key);

  @override
  _Item1State createState() => _Item1State();
}

class _Item1State extends State<Item1> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      color: Colors.grey[200], // Background color
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
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
          Positioned(
            bottom: 16.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.content.layoutData!.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4.0),
                  width: widget.indicatorSize,
                  height: widget.indicatorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.black
                        : Colors.black.withOpacity(0.3),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
