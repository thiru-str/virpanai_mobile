import 'package:cached_network_image/cached_network_image.dart';
import 'cms_text_color.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';
import 'package:waioz/utility/image_fallback_widget.dart';
import 'package:waioz/utility/redirect_utils.dart';

class Grid11 extends StatelessWidget {
  final Content content;

  const Grid11({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final bgImage = (content.layoutBgImage ?? '').trim();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Container(
        constraints: const BoxConstraints(minHeight: 360),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          image: bgImage.isNotEmpty
              ? DecorationImage(
                  image: NetworkImage(Uri.encodeFull(bgImage)),
                  fit: BoxFit.fill,
                )
              : null,
          color: bgImage.isEmpty ? cmsCard(context, const Color(0xFFE7E9F3)) : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 148, 16, 20),
          child: GridView.builder(
            itemCount: items.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.72,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _Grid11Item(
                layoutData: item,
                onTap: () {
                  RedirectUtils.handleContentRedirect(
                    context: context,
                    layoutOption: content.layoutOption ?? "",
                    layoutData: item,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Grid11Item extends StatelessWidget {
  final LayoutDatum layoutData;
  final VoidCallback onTap;

  const _Grid11Item({
    required this.layoutData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = layoutData.image ?? '';
    final safeUrl = imageUrl.isNotEmpty ? Uri.encodeFull(imageUrl) : '';

    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: safeUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: safeUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => const ImageFallbackWidget(
                        w: 28,
                        h: 28,
                        fit: BoxFit.contain,
                      ),
                    )
                  : const ImageFallbackWidget(
                      w: 28,
                      h: 28,
                      fit: BoxFit.contain,
                    ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: Text(
              layoutData.title ?? '',
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: cmsCardText(context, AppColors.textColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
