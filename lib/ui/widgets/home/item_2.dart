import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/redirect_utils.dart';

class Item2 extends StatefulWidget {
  final Content content;
  final double height;
  final double indicatorSize;

  const Item2({
    Key? key,
    required this.content,
    this.height = 200,
    this.indicatorSize = 8.0,
  }) : super(key: key);

  @override
  _Item2State createState() => _Item2State();
}

class _Item2State extends State<Item2> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
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
              return GestureDetector(
                onTap: (){
                  RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: widget.content.layoutOption!,
                    layoutData: layoutdata,
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: layoutdata.image!,
                    width: double.infinity,
                  ),
                ),
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
