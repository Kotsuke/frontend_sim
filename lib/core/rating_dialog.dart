import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'rating_service.dart';

class RatingDialog extends StatefulWidget {
  const RatingDialog({super.key});

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  double _rating = 5;
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Rate Our App'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enjoying the app? Please take a moment to rate us and leave a comment!',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            RatingBar.builder(
              initialRating: 5,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: false,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Leave a comment (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
             Navigator.of(context).pop();
             // Optionally set 'has_rated' to true even if they skip, to avoid annoying them?
             // Or maybe just ask later. existing logic won't show again if we don't set flag, 
             // except it counts opens. So it will show every time after 3rd open if not rated.
             // We can set a 'snooze' timestamp if we wanted complex logic.
             // For now, allow cancel without marking as rated.
          },
          child: const Text('Maybe Later'),
        ),
        ElevatedButton(
          onPressed: _isSubmitting
              ? null
              : () async {
                  setState(() {
                    _isSubmitting = true;
                  });

                  final success = await RatingService.submitReview(
                    _rating.toInt(),
                    _commentController.text,
                  );

                  if (mounted) {
                    setState(() {
                      _isSubmitting = false;
                    });

                    if (success) {
                      await RatingService.setRated();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thank you for your review!')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to submit review. Please try again.')),
                      );
                    }
                  }
                },
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit'),
        ),
      ],
    );
  }
}
