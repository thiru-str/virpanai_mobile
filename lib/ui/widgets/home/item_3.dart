import 'package:flutter/material.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../../model/home_page_response.dart';

class Item3 extends StatelessWidget {
  final Content content;

  const Item3({
    Key? key,
    required this.content,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                content.layoutTitle!,
                style: FontUtils.gabaritoStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor
                ),
              ),
              if (content.layoutRedirectTitle!.isNotEmpty)
                GestureDetector(
                  onTap: (){

                  },
                  child: Text(
                    content.layoutRedirectTitle!,
                    style: FontUtils.circularStdStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                        color: AppColors.textColor
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: content.layoutData!.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, index) {
              LayoutDatum layoutData = content.layoutData![index];
              return GestureDetector(
                onTap: () {
                },
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: ClipOval(child: Image.network(layoutData.image!,fit: BoxFit.contain,),),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      layoutData.title!,
                      style: FontUtils.circularStdStyle(fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
