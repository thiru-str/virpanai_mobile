import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/image_fallback_widget.dart';

import '../../../utility/redirect_utils.dart';

class Item2 extends StatefulWidget {
  final Content? content;
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: SizedBox(
        height: widget.height,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageView.builder(
              itemCount: widget.content?.layoutData?.length ?? 0,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                LayoutDatum? layoutData = widget.content?.layoutData?[index];
                return GestureDetector(
                  onTap: () {
                    RedirectUtils.handleContentRedirect(
                      context: context,
                      layoutOption: widget.content?.layoutOption ?? "",
                      layoutData: layoutData,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: (layoutData?.image == null ||
                            (layoutData?.image?.isEmpty ?? false))
                        ? const ImageFallbackWidget(h: 120, w: 120)
                        : CachedNetworkImage(
                            fit: BoxFit.cover,
                            imageUrl: layoutData!.image!,
                            width: double.infinity,
                            errorWidget: (context, url, error) =>
                              const  ImageFallbackWidget(
                              h: 120,
                              w: 120,
                            ),
                          ),
                  ),
                );
              },
            ),
            Positioned(
              bottom: 16.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(widget.content?.layoutData?.length ?? 0,
                    (index) {
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
      ),
    );
  }
}
