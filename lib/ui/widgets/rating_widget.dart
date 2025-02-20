import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:waioz/utility/app_colors.dart';
import 'package:waioz/utility/font_utils.dart';

class RatingWidget extends StatelessWidget {
  final void Function(double)? onRatingChanged;
  final TextEditingController reviewController = TextEditingController();
  final VoidCallback onSubmit;

  RatingWidget({Key? key, required this.onSubmit, this.onRatingChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double rating = 0.0; // Initial rating value

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.secondary,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Add your rating and review!',
            style: FontUtils.circularStdStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          RatingBar.builder(
            initialRating: rating,
            minRating: 1,
            direction: Axis.horizontal,
            allowHalfRating: false,
            itemCount: 5,
            itemBuilder: (context, _) =>  Icon(
              Icons.star,
              color: AppColors.primary, // Purple color for filled stars
            ),
            unratedColor: Colors.grey.shade300, // Color for unfilled stars
            itemSize: 48,
            onRatingUpdate: (newRating) {
              rating = newRating;
              if (onRatingChanged != null) {
                onRatingChanged!(rating);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Write your review',
              fillColor: Colors.grey.shade300,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onSubmit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary, // Purple color for button
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
            ),
            child: const Text(
              'Submit Review',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
