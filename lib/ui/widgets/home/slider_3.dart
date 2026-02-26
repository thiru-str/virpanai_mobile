import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/redirect_utils.dart';

class Slider3 extends StatefulWidget {
  final Content content;
  final double height;
  final double indicatorSize;

  const Slider3({
    Key? key,
    required this.content,
    this.height = 420,
    this.indicatorSize = 8.0,
  }) : super(key: key);

  @override
  _Slider3State createState() => _Slider3State();
}

class _Slider3State extends State<Slider3> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(widget.content);
    final containerPadding = backgroundDecoration == null
        ? const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0)
        : const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: containerPadding,
        child: Container(
          height: widget.height,
          color: AppColors.secondary,
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
                    onTap: () {
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
                  children: List.generate(widget.content.layoutData!.length, (
                    index,
                  ) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      width: widget.indicatorSize,
                      height: widget.indicatorSize,
                      decoration: (widget.content.layoutData?.length ?? 0) > 1
                          ? BoxDecoration(
                              shape: BoxShape.circle,
                              color: _currentIndex == index
                                  ? Colors.black
                                  : Colors.black.withValues(alpha: 0.3),
                            )
                          : null,
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
