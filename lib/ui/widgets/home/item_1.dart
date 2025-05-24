import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';

class Item1 extends StatefulWidget {
  final Content content;
  final double height;
  final double indicatorSize;

  const Item1({
    Key? key,
    required this.content,
    this.height = 320,
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
      color: Colors.transparent, // Background color
      child: Column(
        children: [
          // PageView takes up most of the space
          Expanded(
            child: PageView.builder(
              itemCount: widget.content.layoutData!.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                LayoutDatum layoutdata = widget.content.layoutData![index];
                return CachedNetworkImage(
                  imageUrl: layoutdata.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),
          // Indicators container with some padding
          const SizedBox(height: 5,),
          Container(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(widget.content.layoutData!.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  width: widget.indicatorSize,
                  height: widget.indicatorSize,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary,width: 1),
                    color: _currentIndex == index
                        ? AppColors.primary
                        : Colors.transparent,
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
