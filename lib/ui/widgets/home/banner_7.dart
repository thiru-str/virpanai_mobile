import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';
import 'cms_text_color.dart';

class Banner7 extends StatelessWidget {
  final Content content;

  const Banner7({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: backgroundDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          if ((content.layoutTitle ?? '').isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: HomeMerchSectionHeader(
                title: content.layoutTitle ?? '',
                subtitle: content.layoutSubTitle ?? '',
                centered: true,
              ),
            ),
          _PromoTile(
            data: items.first,
            height: 260,
            onTap: () => RedirectUtils.handleContentRedirect(
              context: context,
              layoutOption: content.layoutOption ?? '',
              layoutData: items.first,
            ),
          ),
          if (items.length > 1) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (int i = 1; i < items.length && i < 3; i++) ...[
                  Expanded(
                    child: _PromoTile(
                      data: items[i],
                      height: 160,
                      onTap: () => RedirectUtils.handleContentRedirect(
                        context: context,
                        layoutOption: content.layoutOption ?? '',
                        layoutData: items[i],
                      ),
                    ),
                  ),
                  if (i == 1 && items.length > 2) const SizedBox(width: 12),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PromoTile extends StatelessWidget {
  final LayoutDatum data;
  final double height;
  final VoidCallback onTap;

  const _PromoTile({
    required this.data,
    required this.height,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: SizedBox(
          height: height,
          child: Stack(
            children: [
              Positioned.fill(
                child: image.isEmpty
                    ? ImageFallbackWidget(
                        h: height,
                        w: double.infinity,
                        fit: BoxFit.contain,
                      )
                    : CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => ImageFallbackWidget(
                          h: height,
                          w: double.infinity,
                          fit: BoxFit.contain,
                        ),
                      ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.70),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Text(
                  data.title ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: FontUtils.primaryFontStyle(
                    fontSize: height > 200 ? 24 : 17,
                    fontWeight: FontWeight.w800,
                    color: cmsCard(context, Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
