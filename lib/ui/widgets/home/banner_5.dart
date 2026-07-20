import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';

import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import '../../../utility/image_fallback_widget.dart';
import '../../../utility/redirect_utils.dart';
import 'homepage_merch_shared.dart';

class Banner5 extends StatelessWidget {
  final Content content;

  const Banner5({
    super.key,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final hero = items.isNotEmpty ? items.first : null;
    final secondary = items.length > 1
        ? items.sublist(1, items.length > 3 ? 3 : items.length)
        : <LayoutDatum>[];
    final backgroundDecoration = AppUtils.buildLayoutBackground(content);
    if (hero == null) return const SizedBox.shrink();

    return Container(
      decoration: backgroundDecoration,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _HeroTile(
            data: hero,
            actionLabel: content.layoutRedirectTitle?.isNotEmpty == true
                ? content.layoutRedirectTitle!
                : 'Shop now',
            onTap: () => RedirectUtils.handleContentRedirect(
              context: context,
              layoutOption: content.layoutOption ?? '',
              layoutData: hero,
            ),
          ),
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                for (int i = 0; i < secondary.length; i++) ...[
                  Expanded(
                    child: _MiniBannerTile(
                      data: secondary[i],
                      onTap: () => RedirectUtils.handleContentRedirect(
                        context: context,
                        layoutOption: content.layoutOption ?? '',
                        layoutData: secondary[i],
                      ),
                    ),
                  ),
                  if (i != secondary.length - 1) const SizedBox(width: 12),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HeroTile extends StatelessWidget {
  final LayoutDatum data;
  final String actionLabel;
  final VoidCallback onTap;

  const _HeroTile({
    required this.data,
    required this.actionLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final image = merchImage(data);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 330,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(32),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 24,
              offset: Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Stack(
            children: [
              Positioned.fill(
                child: image.isEmpty
                    ? const ImageFallbackWidget(
                        h: 330,
                        w: double.infinity,
                        fit: BoxFit.contain,
                      )
                    : CachedNetworkImage(
                        imageUrl: image,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const ImageFallbackWidget(
                          h: 330,
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
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: FontUtils.primaryFontStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    if (merchSubtitle(data).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        merchSubtitle(data),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FontUtils.primaryFontStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.82),
                        ),
                      ),
                    ],
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            actionLabel,
                            style: FontUtils.primaryFontStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textColor,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniBannerTile extends StatelessWidget {
  final LayoutDatum data;
  final VoidCallback onTap;

  const _MiniBannerTile({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data.title ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: FontUtils.primaryFontStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.textColor,
              ),
            ),
            if (merchSubtitle(data).isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                merchSubtitle(data),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FontUtils.primaryFontStyle(
                  fontSize: 11,
                  color: AppColors.textColor50,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
