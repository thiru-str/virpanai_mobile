import 'package:flutter/material.dart';
import 'package:waioz/model/home_page_response.dart';
import 'package:waioz/utility/font_utils.dart';

import '../../../utility/app_colors.dart';

class Item6 extends StatelessWidget {
  final Content content;

  const Item6({
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
              if (true)
                GestureDetector(
                  onTap: (){

                  },
                  child: Text(
                    'See All',
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
              final layoutData = content.layoutData![index];
              return GestureDetector(
                onTap: () {},
                child: Container(
                  width: 200,
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.grey[300],
                        child: Image.network(
                          layoutData.image!,
                          height: 30,
                          width: 30,
                        ),
                      ),
                      const SizedBox(width: 8), // Horizontal spacing
                      Flexible( // Constrain the Text widget
                        child: Text(
                          layoutData.title!,
                          style: FontUtils.circularStdStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis, // Adds ellipsis
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}

