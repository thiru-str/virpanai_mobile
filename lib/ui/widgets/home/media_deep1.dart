import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import '../../../utility/app_colors.dart';
import '../../../utility/app_utils.dart';
import '../../../utility/font_utils.dart';
import 'grocery_shared.dart';
import 'homepage_merch_shared.dart';

// Instagram1 — shoppable Instagram feed grid.
class Instagram1 extends StatelessWidget {
  final Content content;
  const Instagram1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '', centered: true),
        const SizedBox(height: 12),
        GridView.builder(
          itemCount: items.length > 6 ? 6 : items.length, shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1),
          itemBuilder: (context, i) => ClipRRect(borderRadius: BorderRadius.circular(12),
            child: merchImageOrFallback(merchImage(items[i]), fit: BoxFit.cover)),
        ),
        const SizedBox(height: 12),
        Center(child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.camera_alt, size: 16, color: AppColors.textColor),
          const SizedBox(width: 6),
          Text(content.layoutRedirectTitle?.isNotEmpty == true ? content.layoutRedirectTitle! : '@yourbrand',
            style: FontUtils.primaryFontStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textColor)),
        ])),
      ]),
    );
  }
}

// Ugc1 — customer photo wall ("tag us to be featured").
class Ugc1 extends StatelessWidget {
  final Content content;
  const Ugc1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '')),
        const SizedBox(height: 12),
        SizedBox(height: 150, child: ListView.separated(
          scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: items.length, separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, i) => ClipRRect(borderRadius: BorderRadius.circular(14),
            child: SizedBox(width: 120, child: merchImageOrFallback(merchImage(items[i]), fit: BoxFit.cover))))),
      ]),
    );
  }
}

// Gallery1 — editorial masonry image gallery.
class Gallery1 extends StatelessWidget {
  final Content content;
  const Gallery1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    if (items.isEmpty) return const SizedBox.shrink();
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? ''),
        const SizedBox(height: 12),
        SizedBox(height: 320, child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(children: [
            Expanded(flex: 3, child: _cell(_imgAt(items, 0))), const SizedBox(height: 10),
            Expanded(flex: 2, child: _cell(_imgAt(items, 1))),
          ])),
          const SizedBox(width: 10),
          Expanded(child: Column(children: [
            Expanded(flex: 2, child: _cell(_imgAt(items, 2))), const SizedBox(height: 10),
            Expanded(flex: 3, child: _cell(_imgAt(items, 3))),
          ])),
        ])),
      ]),
    );
  }
  String _imgAt(List<LayoutDatum> items, int i) => i < items.length ? merchImage(items[i]) : '';
  Widget _cell(String url) => ClipRRect(borderRadius: BorderRadius.circular(14),
    child: SizedBox.expand(child: merchImageOrFallback(url, fit: BoxFit.cover)));
}

// BeforeAfter1 — before / after comparison panels.
class BeforeAfter1 extends StatelessWidget {
  final Content content;
  const BeforeAfter1({super.key, required this.content});
  @override
  Widget build(BuildContext context) {
    final items = content.layoutData ?? [];
    final beforeImage = items.isNotEmpty ? merchImage(items[0]) : '';
    final afterImage = items.length > 1 ? merchImage(items[1]) : '';
    return Container(
      decoration: AppUtils.buildLayoutBackground(content),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        HomeMerchSectionHeader(title: content.layoutTitle ?? '', subtitle: content.layoutSubTitle ?? '', centered: true),
        const SizedBox(height: 12),
        ClipRRect(borderRadius: BorderRadius.circular(18), child: AspectRatio(aspectRatio: 3 / 2,
          child: Row(children: [
            Expanded(child: Stack(children: [
              Positioned.fill(child: merchImageOrFallback(beforeImage, fit: BoxFit.cover)),
              Positioned(left: 10, top: 10, child: _tag('BEFORE')),
            ])),
            Container(width: 2, color: Colors.white),
            Expanded(child: Stack(children: [
              Positioned.fill(child: merchImageOrFallback(afterImage, fit: BoxFit.cover)),
              Positioned(left: 10, top: 10, child: _tag('AFTER')),
            ])),
          ]))),
      ]),
    );
  }
  Widget _tag(String s) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: kInk, borderRadius: BorderRadius.circular(6)),
    child: Text(s, style: FontUtils.primaryFontStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)));
}
