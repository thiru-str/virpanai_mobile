import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';

import '../../../utility/redirect_utils.dart';

class Item8 extends StatefulWidget {
  final Content content;
  final double height;
  final double indicatorSize;

  const Item8({
    Key? key,
    required this.content,
    this.height = 420,
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
      color: AppColors.secondary, // Background color
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
              LayoutDatum layoutData = widget.content.layoutData![index];
              return GestureDetector(
                onTap: (){
                  RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: widget.content.layoutOption!,
                    layoutData: layoutData,
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: layoutData.image!,
                  fit: BoxFit.cover,
                  width: double.infinity,
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
                  decoration: (widget.content.layoutData?.length ?? 0) > 1
                      ? BoxDecoration(
                    shape: BoxShape.circle,
                    color: _currentIndex == index
                        ? Colors.black
                        : Colors.black.withOpacity(0.3),
                  ):null,
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
