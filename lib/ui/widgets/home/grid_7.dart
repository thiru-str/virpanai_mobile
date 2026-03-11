import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/app_utils.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/redirect_utils.dart';

class Grid7 extends StatelessWidget {
  final Content content;

  const Grid7({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    final items = (content.layoutData ?? []).take(7).toList();

    return Container(
      decoration: backgroundDecoration,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0F1F8),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, bottom: 14),
                child: Text(
                  content.layoutTitle ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.secondaryFontStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textColor,
                  ),
                ),
              ),
              StaggeredGrid.count(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                children: [
                  for (int i = 0; i < items.length; i++)
                    StaggeredGridTile.count(
                      crossAxisCellCount: _spanForIndex(i).$1,
                      mainAxisCellCount: _spanForIndex(i).$2,
                      child: _Grid7Card(
                        layoutData: items[i],
                        onTap: () {
                          RedirectUtils.handleContentRedirect(
                            context: context,
                            layoutOption: content.layoutOption ?? "",
                            layoutData: items[i],
                          );
                        },
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  (int, int) _spanForIndex(int index) {
    switch (index) {
      case 0:
        return (1, 2);
      case 1:
      case 2:
        return (1, 1);
      case 3:
        return (2, 1);
      case 4:
      case 5:
        return (1, 1);
      case 6:
        return (2, 1);
      default:
        return (1, 1);
    }
  }
}

class _Grid7Card extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Grid7Card({
    required this.layoutData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Container(
          color: const Color(0xFFD9DBE6),
          child: imageUrl.isNotEmpty
              ? CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) => const ImageFallbackWidget(
                    w: 40,
                    h: 40,
                    fit: BoxFit.contain,
                  ),
                )
              : const ImageFallbackWidget(
                  w: 40,
                  h: 40,
                  fit: BoxFit.contain,
                ),
        ),
      ),
    );
  }
}
