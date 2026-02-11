import 'package:flutter/material.dart';

class RatingDialog extends StatefulWidget {
  final String songTitle;
  final String artistName;
  final double? initialRating;
  final bool? initialFavorite;
  final String? initialReview;

  const RatingDialog({
    super.key,
    required this.songTitle,
    required this.artistName,
    this.initialRating,
    this.initialFavorite,
    this.initialReview,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  late double _rating;
  late bool _isFavorite;
  late TextEditingController _reviewController;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating ?? 0.0;
    _isFavorite = widget.initialFavorite ?? false;
    _reviewController = TextEditingController(text: widget.initialReview);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Rate "${widget.songTitle}"'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.artistName,
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 24),

            // Rating Value Display
            Text(
              _rating.toStringAsFixed(2),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const Text(' / 10.0', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            // Slider (0 to 10, divisions for 0.25 steps = 40 divisions)
            Slider(
              value: _rating,
              min: 0.0,
              max: 10.0,
              divisions: 40,
              label: _rating.toStringAsFixed(2),
              onChanged: (value) => setState(() => _rating = value),
              onChangeEnd: (value) {
                // Apply auto-favorite logic on release
                if (value >= 8.0) {
                  setState(() => _isFavorite = true);
                }
              },
            ),

            const SizedBox(height: 16),

            // Favorite Toggle
            SwitchListTile(
              title: const Text('Add to Favorites'),
              subtitle: const Text('Auto-enabled for 8.0+'),
              value: _isFavorite,
              onChanged: (val) => setState(() => _isFavorite = val),
            ),

            const SizedBox(height: 16),

            // Review Text
            TextField(
              controller: _reviewController,
              decoration: const InputDecoration(
                labelText: 'Review (Optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context, {
              'value': _rating,
              'isFavorite': _isFavorite,
              'review': _reviewController.text.trim().isEmpty
                  ? null
                  : _reviewController.text.trim(),
            });
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
